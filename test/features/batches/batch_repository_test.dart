import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/features/batches/data/batch_repository.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';

const _today = LocalDate(2026, 10, 7);

void main() {
  late AppDatabase db;
  late BatchRepository repo;
  late StudentRepository students;
  var ids = 0;

  BatchDraft draft(
    String name, {
    List<int> days = const [1, 3, 5],
    int fee = 1500,
    String? subject,
    String? classLevel,
    ClockTime? time,
    int? duration,
  }) => BatchDraft(
    name: name,
    scheduleDays: days,
    defaultFee: fee,
    subject: subject,
    classLevel: classLevel,
    startTime: time,
    durationMin: duration,
  );

  Future<Student> student(String name) => students.create(
    StudentDraft.quick(
      name: name,
      monthlyFee: 1000,
      joinedOn: const LocalDate(2026, 10, 1),
    ),
  );

  setUp(() {
    ids = 0;
    db = openInMemoryDatabase();
    repo = BatchRepository(db, newId: () => 'b${++ids}');
    students = StudentRepository(db);
  });

  tearDown(() => db.close());

  group('create and update', () {
    test('stores a normalized batch', () async {
      final b = await repo.create(
        draft(
          '  Math   9 ',
          days: [5, 1, 3, 3],
          subject: ' Math ',
          classLevel: 'Class 9',
          time: const ClockTime(17, 0),
          duration: 90,
          fee: 2000,
        ),
      );
      expect(b.name, 'Math 9');
      expect(b.scheduleDayList, [1, 3, 5]); // sorted, de-duplicated
      expect(b.subject, 'Math');
      expect(b.startTimeValue, const ClockTime(17, 0));
      expect(b.durationMin, 90);
      expect(b.defaultFee, 2000);
      expect(b.isArchived, isFalse);
    });

    test('rejects invalid drafts and writes nothing', () async {
      await expectLater(
        repo.create(draft(' ', days: [], fee: -1, duration: 0)),
        throwsA(
          isA<BatchValidationException>().having(
            (e) => e.errors,
            'errors',
            containsAll([
              BatchFieldError.nameRequired,
              BatchFieldError.scheduleRequired,
              BatchFieldError.feeInvalid,
              BatchFieldError.durationInvalid,
            ]),
          ),
        ),
      );
      expect(await db.select(db.batches).get(), isEmpty);
    });

    test('weekdays outside 1 to 7 do not count as a schedule', () {
      expect(draft('X', days: [0, 8]).validate(), [
        BatchFieldError.scheduleRequired,
      ]);
    });

    test('update changes fields; unknown id fails', () async {
      final b = await repo.create(draft('Math 9'));
      final u = await repo.update(b.id, draft('Math 10', days: [2], fee: 900));
      expect(u.name, 'Math 10');
      expect(u.scheduleDayList, [2]);
      expect(u.defaultFee, 900);
      expect(u.createdAt, b.createdAt);
      await expectLater(repo.update('nope', draft('X')), throwsStateError);
    });
  });

  group('archive', () {
    test('archived batches leave the default list but keep members', () async {
      final b = await repo.create(draft('Math 9'));
      final s = await student('Rahim');
      await repo.addMembers(b.id, [s.id], _today);

      await repo.archive(b.id);
      expect(await repo.watchSummaries().first, isEmpty);
      final all = await repo.watchSummaries(includeArchived: true).first;
      expect(all.single.batch.isArchived, isTrue);
      expect(all.single.memberCount, 1);

      await repo.restore(b.id);
      expect(
        (await repo.watchSummaries().first).single.batch.isArchived,
        isFalse,
      );
    });
  });

  group('members', () {
    late Batch math;
    late Batch physics;
    late Student rahim;
    late Student karim;

    setUp(() async {
      math = await repo.create(draft('Math 9', fee: 1500));
      physics = await repo.create(draft('Physics 9', fee: 1200));
      rahim = await student('Rahim');
      karim = await student('Karim');
    });

    test('a student can be in several batches', () async {
      await repo.addMembers(math.id, [rahim.id, karim.id], _today);
      await repo.addMembers(physics.id, [rahim.id], _today);

      final mathMembers = await repo.watchMembers(math.id).first;
      expect(mathMembers.map((m) => m.student.name), ['Karim', 'Rahim']);
      final physicsMembers = await repo.watchMembers(physics.id).first;
      expect(physicsMembers.map((m) => m.student.name), ['Rahim']);

      final batches = await repo.watchBatchesOfStudent(rahim.id).first;
      expect(batches.map((b) => b.name), ['Math 9', 'Physics 9']);
      expect(
        (await repo.watchBatchesOfStudent(karim.id).first).map((b) => b.name),
        ['Math 9'],
      );
    });

    test('records the join date', () async {
      await repo.addMembers(math.id, [rahim.id], const LocalDate(2026, 9, 15));
      final m = (await repo.watchMembers(math.id).first).single.member;
      expect(m.joinedOn, '2026-09-15');
      expect(m.leftOn, isNull);
      expect(m.feeOverride, isNull);
    });

    test(
      'adding an existing member is skipped and counted correctly',
      () async {
        expect(await repo.addMembers(math.id, [rahim.id], _today), 1);
        expect(await repo.addMembers(math.id, [rahim.id, karim.id], _today), 1);
        expect(await repo.watchMembers(math.id).first, hasLength(2));
      },
    );

    test('removing sets the leave date and keeps the row', () async {
      await repo.addMembers(math.id, [rahim.id, karim.id], _today);
      await repo.removeMember(math.id, rahim.id, const LocalDate(2026, 10, 20));

      expect(
        (await repo.watchMembers(math.id).first).map((m) => m.student.name),
        ['Karim'],
      );
      final row = await (db.select(
        db.batchMembers,
      )..where((t) => t.studentId.equals(rahim.id))).getSingle();
      expect(row.leftOn, '2026-10-20');
      expect(await repo.watchBatchesOfStudent(rahim.id).first, isEmpty);
    });

    test('a student who left can be added back', () async {
      await repo.addMembers(math.id, [rahim.id], const LocalDate(2026, 9, 1));
      await repo.removeMember(math.id, rahim.id, const LocalDate(2026, 9, 20));
      expect(await repo.addMembers(math.id, [rahim.id], _today), 1);

      final members = await repo.watchMembers(math.id).first;
      expect(members, hasLength(1));
      expect(members.single.member.leftOn, isNull);
      expect(members.single.member.joinedOn, '2026-09-01'); // original kept
    });

    test(
      'fee override is saved, used as the effective fee, and clearable',
      () async {
        await repo.addMembers(math.id, [rahim.id, karim.id], _today);
        await repo.setFeeOverride(math.id, rahim.id, 1000);

        var members = await repo.watchMembers(math.id).first;
        final r = members.firstWhere((m) => m.student.id == rahim.id);
        final k = members.firstWhere((m) => m.student.id == karim.id);
        expect(r.member.feeOverride, 1000);
        expect(r.effectiveFee(math), 1000);
        expect(k.member.feeOverride, isNull);
        expect(k.effectiveFee(math), 1500); // batch default

        await repo.setFeeOverride(math.id, rahim.id, null);
        members = await repo.watchMembers(math.id).first;
        expect(
          members
              .firstWhere((m) => m.student.id == rahim.id)
              .effectiveFee(math),
          1500,
        );
      },
    );

    test('an override is per batch', () async {
      await repo.addMembers(math.id, [rahim.id], _today);
      await repo.addMembers(physics.id, [rahim.id], _today);
      await repo.setFeeOverride(math.id, rahim.id, 800);
      final p = (await repo.watchMembers(physics.id).first).single;
      expect(p.member.feeOverride, isNull);
    });

    test('a negative override is rejected', () async {
      await repo.addMembers(math.id, [rahim.id], _today);
      expect(
        () => repo.setFeeOverride(math.id, rahim.id, -1),
        throwsArgumentError,
      );
    });
  });

  group('summaries', () {
    test('count only current members and sort by name', () async {
      final b = await repo.create(draft('banana'));
      final a = await repo.create(draft('Apple'));
      final s1 = await student('One');
      final s2 = await student('Two');
      await repo.addMembers(b.id, [s1.id, s2.id], _today);
      await repo.removeMember(b.id, s2.id, _today);

      final list = await repo.watchSummaries().first;
      expect(list.map((s) => s.batch.name), ['Apple', 'banana']);
      expect(list.map((s) => s.memberCount), [0, 1]);
      expect(a.id, isNotEmpty);
    });

    test('streams update on membership changes', () async {
      final b = await repo.create(draft('Math 9'));
      final s = await student('Rahim');
      final counts = <int>[];
      final sub = repo.watchSummaries().listen(
        (l) => counts.add(l.single.memberCount),
      );
      await pumpEventQueue();
      await repo.addMembers(b.id, [s.id], _today);
      await pumpEventQueue();
      await repo.removeMember(b.id, s.id, _today);
      await pumpEventQueue();
      await sub.cancel();
      expect(counts, [0, 1, 0]);
    });
  });
}
