import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';
import 'package:tution_tracker/features/students/domain/student_filter.dart';
import 'package:tution_tracker/features/students/domain/student_status.dart';

import '../../support/db_fixtures.dart';

void main() {
  late AppDatabase db;
  late StudentRepository repo;
  var idCounter = 0;
  var clock = DateTime.utc(2026, 10, 1, 12);

  StudentDraft draft(
    String name, {
    int fee = 1500,
    String? classLevel,
    String? school,
    String? guardianName,
    String? guardianPhone,
    String? studentPhone,
    List<String> subjects = const [],
  }) => StudentDraft(
    name: name,
    monthlyFee: fee,
    joinedOn: const LocalDate(2026, 10, 1),
    classLevel: classLevel,
    school: school,
    guardianName: guardianName,
    guardianPhone: guardianPhone,
    studentPhone: studentPhone,
    subjects: subjects,
  );

  setUp(() {
    idCounter = 0;
    clock = DateTime.utc(2026, 10, 1, 12);
    db = openInMemoryDatabase();
    repo = StudentRepository(
      db,
      now: () => clock,
      newId: () => 'id${++idCounter}',
    );
  });

  tearDown(() => db.close());

  Future<List<String>> names([StudentFilter f = const StudentFilter()]) async =>
      [for (final s in await repo.list(f)) s.name];

  group('create', () {
    test('stores normalized fields and the initial fee change', () async {
      final s = await repo.create(
        draft(
          '  রহিম   উদ্দিন ',
          classLevel: 'Class 9',
          guardianPhone: '+880 1712-345678',
          studentPhone: '',
          subjects: ['Math', ' ', 'Physics'],
        ),
      );
      expect(s.name, 'রহিম উদ্দিন');
      expect(s.guardianPhone, '01712345678');
      expect(s.studentPhone, isNull);
      expect(s.subjectList, ['Math', 'Physics']);
      expect(s.statusValue, StudentStatus.active);
      expect(s.joinedOn, '2026-10-01');
      expect(s.createdAt, clock.millisecondsSinceEpoch);

      final changes = await db.select(db.feeChanges).get();
      expect(changes, hasLength(1));
      expect(changes.single.studentId, s.id);
      expect(changes.single.effectiveMonth, '2026-10');
      expect(changes.single.newAmount, 1500);
    });

    test('quick-add needs only a name and a fee', () async {
      final s = await repo.create(
        const StudentDraft.quick(
          name: 'Karim',
          monthlyFee: 1000,
          joinedOn: LocalDate(2026, 10, 3),
          feeDueDay: 5,
        ),
      );
      expect(s.feeDueDay, 5);
      expect(s.guardianPhone, isNull);
      expect(s.subjectList, isEmpty);
    });

    test('rejects invalid drafts and writes nothing', () async {
      await expectLater(
        repo.create(
          draft('  ', fee: -1, guardianPhone: '12345', studentPhone: 'abc'),
        ),
        throwsA(
          isA<StudentValidationException>().having(
            (e) => e.errors,
            'errors',
            containsAll([
              StudentFieldError.nameRequired,
              StudentFieldError.feeInvalid,
              StudentFieldError.guardianPhoneInvalid,
              StudentFieldError.studentPhoneInvalid,
            ]),
          ),
        ),
      );
      expect(await db.select(db.students).get(), isEmpty);
      expect(await db.select(db.feeChanges).get(), isEmpty);
    });

    test('due day must be 1 to 31', () {
      expect(
        const StudentDraft.quick(
          name: 'A',
          monthlyFee: 1,
          joinedOn: LocalDate(2026, 1, 1),
          feeDueDay: 32,
        ).validate(),
        [StudentFieldError.dueDayInvalid],
      );
    });
  });

  group('update', () {
    test('changes fields but never the monthly fee', () async {
      final s = await repo.create(draft('Rahim', fee: 1500));
      clock = DateTime.utc(2026, 10, 2);
      final updated = await repo.update(
        s.id,
        draft('Rahim Uddin', fee: 9999, school: 'Dhaka College'),
      );
      expect(updated.name, 'Rahim Uddin');
      expect(updated.school, 'Dhaka College');
      expect(updated.monthlyFee, 1500);
      expect(updated.updatedAt, clock.millisecondsSinceEpoch);
      expect(updated.createdAt, s.createdAt);
    });

    test('unknown id fails', () async {
      await expectLater(repo.update('nope', draft('X')), throwsStateError);
    });
  });

  group('search', () {
    setUp(() async {
      await repo.create(
        draft(
          'Rahim Uddin',
          school: 'Dhaka College',
          guardianName: 'Abdul Karim',
          guardianPhone: '01712345678',
        ),
      );
      await repo.create(draft('রহিম উদ্দিন', studentPhone: '01898765432'));
      await repo.create(draft('করিম আহমেদ', guardianName: 'রহিম মিয়া'));
      await repo.create(draft('Sara 100%_Fan'));
    });

    test('English is case-insensitive and matches anywhere', () async {
      expect(await names(const StudentFilter(query: 'RAHIM')), ['Rahim Uddin']);
      expect(
        await names(const StudentFilter(query: 'uddin')),
        contains('Rahim Uddin'),
      );
    });

    test('Bangla substring matches names and guardians', () async {
      expect(
        await names(const StudentFilter(query: 'রহিম')),
        unorderedEquals(['রহিম উদ্দিন', 'করিম আহমেদ']),
      );
    });

    test(
      'same word typed with a different Unicode sequence still matches',
      () async {
        await repo.create(draft('মোহাম্মদ'));
        // Stored with precomposed ো; search typed as ে + া.
        expect(await names(const StudentFilter(query: 'মোহা')), ['মোহাম্মদ']);
        await repo.create(draft('আসাদড়'));
        expect(await names(const StudentFilter(query: 'আসাদড়')), ['আসাদড়']);
      },
    );

    test('matches guardian name and school', () async {
      expect(await names(const StudentFilter(query: 'abdul')), ['Rahim Uddin']);
      expect(await names(const StudentFilter(query: 'dhaka coll')), [
        'Rahim Uddin',
      ]);
    });

    test('matches phone numbers in any accepted format', () async {
      for (final q in ['01712', '1712345', '+8801712', '০১৭১২']) {
        expect(await names(StudentFilter(query: q)), [
          'Rahim Uddin',
        ], reason: q);
      }
      expect(await names(const StudentFilter(query: '98765')), ['রহিম উদ্দিন']);
    });

    test('LIKE wildcards in the query are literal', () async {
      expect(await names(const StudentFilter(query: '100%')), [
        'Sara 100%_Fan',
      ]);
      expect(await names(const StudentFilter(query: '%')), ['Sara 100%_Fan']);
      expect(await names(const StudentFilter(query: '_')), ['Sara 100%_Fan']);
    });

    test('blank or whitespace query returns everyone', () async {
      expect(await names(const StudentFilter(query: '   ')), hasLength(4));
    });

    test('no match gives an empty list', () async {
      expect(await names(const StudentFilter(query: 'zzz')), isEmpty);
    });
  });

  group('filters', () {
    test('status: archived students are hidden by default', () async {
      final a = await repo.create(draft('Active'));
      final b = await repo.create(draft('Paused'));
      final c = await repo.create(draft('Gone'));
      await repo.setStatus(b.id, StudentStatus.paused);
      await repo.archive(c.id);

      expect(await names(), unorderedEquals(['Active', 'Paused']));
      expect(await names(const StudentFilter(statuses: {StudentStatus.left})), [
        'Gone',
      ]);
      expect(
        await names(StudentFilter(statuses: StudentStatus.values.toSet())),
        hasLength(3),
      );
      expect(a.statusValue, StudentStatus.active);
    });

    test('class level', () async {
      await repo.create(draft('A', classLevel: 'Class 9'));
      await repo.create(draft('B', classLevel: 'Class 10'));
      await repo.create(draft('C'));
      expect(await names(const StudentFilter(classLevel: 'Class 9')), ['A']);
    });

    test('batch: only current members', () async {
      final a = await repo.create(draft('In batch'));
      final b = await repo.create(draft('Left batch'));
      await repo.create(draft('No batch'));
      await insertBatch(db, 'b1');
      Future<void> join(String id, String studentId, {String? leftOn}) => db
          .into(db.batchMembers)
          .insert(
            BatchMembersCompanion.insert(
              id: id,
              batchId: 'b1',
              studentId: studentId,
              joinedOn: '2026-10-01',
              leftOn: Value(leftOn),
            ),
          );
      await join('m1', a.id);
      await join('m2', b.id, leftOn: '2026-10-05');
      expect(await names(const StudentFilter(batchId: 'b1')), ['In batch']);
    });

    test('filters combine', () async {
      await repo.create(draft('Rahim', classLevel: 'Class 9'));
      await repo.create(draft('Rahima', classLevel: 'Class 10'));
      await repo.create(draft('Karim', classLevel: 'Class 9'));
      expect(
        await names(const StudentFilter(query: 'rahim', classLevel: 'Class 9')),
        ['Rahim'],
      );
    });

    test('results are sorted by name, case-insensitively', () async {
      await repo.create(draft('banana'));
      await repo.create(draft('Apple'));
      await repo.create(draft('cherry'));
      expect(await names(), ['Apple', 'banana', 'cherry']);
    });

    test('copyWith can clear nullable filters', () {
      const f = StudentFilter(classLevel: 'Class 9', batchId: 'b1');
      final cleared = f.copyWith(classLevel: () => null, batchId: () => null);
      expect(cleared.classLevel, isNull);
      expect(cleared.batchId, isNull);
      expect(f.copyWith(query: 'x').classLevel, 'Class 9');
    });
  });

  group('archive and restore', () {
    test('archive keeps the row and history; restore brings it back', () async {
      final s = await repo.create(draft('Rahim'));
      await insertPayment(db, 'p1', s.id);

      await repo.archive(s.id);
      expect(await names(), isEmpty);
      expect((await repo.getById(s.id))!.statusValue, StudentStatus.left);
      expect(await db.select(db.payments).get(), hasLength(1));

      await repo.restore(s.id);
      expect(await names(), ['Rahim']);
    });
  });

  group('delete forever', () {
    test(
      'removes the student and all their records, returns the photo',
      () async {
        final s = await repo.create(
          const StudentDraft(
            name: 'Rahim',
            monthlyFee: 1500,
            joinedOn: LocalDate(2026, 10, 1),
            photoPath: '/photos/s.jpg',
          ),
        );
        final other = await repo.create(draft('Other'));
        await insertBatch(db, 'b1');
        await insertFee(db, 'f1', s.id, '2026-10');
        await insertFee(db, 'f2', other.id, '2026-10');
        await insertPayment(db, 'p1', s.id, receiptNo: 1);
        await insertPayment(db, 'p2', other.id, receiptNo: 2);
        await db
            .into(db.paymentAllocations)
            .insert(
              PaymentAllocationsCompanion.insert(
                id: 'al1',
                paymentId: 'p1',
                feeRecordId: const Value('f1'),
                studentId: s.id,
                amount: 1500,
              ),
            );
        await db
            .into(db.classSessions)
            .insert(
              ClassSessionsCompanion.insert(
                id: 'c1',
                batchId: const Value('b1'),
                date: '2026-10-05',
              ),
            );
        await db
            .into(db.attendance)
            .insert(
              AttendanceCompanion.insert(
                id: 'a1',
                sessionId: 'c1',
                studentId: s.id,
                status: 'present',
              ),
            );
        await db
            .into(db.attendance)
            .insert(
              AttendanceCompanion.insert(
                id: 'a2',
                sessionId: 'c1',
                studentId: other.id,
                status: 'present',
              ),
            );

        final photo = await repo.deleteForever(s.id);

        expect(photo, '/photos/s.jpg');
        expect(await repo.getById(s.id), isNull);
        expect(await db.select(db.feeChanges).get(), hasLength(1)); // other's
        expect(
          [for (final f in await db.select(db.feeRecords).get()) f.id],
          ['f2'],
        );
        expect(
          [for (final p in await db.select(db.payments).get()) p.id],
          ['p2'],
        );
        expect(await db.select(db.paymentAllocations).get(), isEmpty);
        expect(
          [for (final a in await db.select(db.attendance).get()) a.id],
          ['a2'],
        );
        expect(await repo.getById(other.id), isNotNull);

        final audit = await db.select(db.auditLog).get();
        expect(audit.single.action, 'delete');
        expect(audit.single.entityId, s.id);
      },
    );

    test('unknown id is a no-op', () async {
      expect(await repo.deleteForever('nope'), isNull);
    });
  });

  group('reactive streams', () {
    test('watch emits on create, update and archive', () async {
      final emissions = <List<String>>[];
      final sub = repo.watch().listen(
        (list) => emissions.add([for (final s in list) s.name]),
      );
      await pumpEventQueue();
      expect(emissions.last, isEmpty);

      final s = await repo.create(draft('Rahim'));
      await pumpEventQueue();
      expect(emissions.last, ['Rahim']);

      await repo.update(s.id, draft('Rahim Uddin'));
      await pumpEventQueue();
      expect(emissions.last, ['Rahim Uddin']);

      await repo.archive(s.id);
      await pumpEventQueue();
      expect(emissions.last, isEmpty);

      await sub.cancel();
    });

    test('a filtered watch updates when batch membership changes', () async {
      final s = await repo.create(draft('Rahim'));
      await insertBatch(db, 'b1');
      final emissions = <int>[];
      final sub = repo
          .watch(const StudentFilter(batchId: 'b1'))
          .listen((l) => emissions.add(l.length));
      await pumpEventQueue();
      expect(emissions.last, 0);

      await db
          .into(db.batchMembers)
          .insert(
            BatchMembersCompanion.insert(
              id: 'm1',
              batchId: 'b1',
              studentId: s.id,
              joinedOn: '2026-10-01',
            ),
          );
      await pumpEventQueue();
      expect(emissions.last, 1);
      await sub.cancel();
    });

    test('watchById follows one student', () async {
      final s = await repo.create(draft('Rahim'));
      final seen = <String?>[];
      final sub = repo.watchById(s.id).listen((r) => seen.add(r?.name));
      await pumpEventQueue();
      await repo.update(s.id, draft('Rahim Uddin'));
      await pumpEventQueue();
      await sub.cancel();
      expect(seen, ['Rahim', 'Rahim Uddin']);
    });

    test('watchClassLevels lists distinct levels in use', () async {
      await repo.create(draft('A', classLevel: 'Class 9'));
      await repo.create(draft('B', classLevel: 'Class 9'));
      await repo.create(draft('C', classLevel: 'Class 10'));
      await repo.create(draft('D'));
      expect(await repo.watchClassLevels().first, ['Class 10', 'Class 9']);
    });
  });
}
