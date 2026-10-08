import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/features/attendance/data/attendance_repository.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_stats.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/features/batches/data/batch_repository.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';
import 'package:tution_tracker/features/students/domain/student_status.dart';

const mar2 = LocalDate(2026, 3, 2);
const mar9 = LocalDate(2026, 3, 9);
const mar = YearMonth(2026, 3);
const present = AttendanceStatus.present;
const absent = AttendanceStatus.absent;
const late = AttendanceStatus.late;
const excused = AttendanceStatus.excused;

void main() {
  late AppDatabase db;
  late AttendanceRepository repo;
  late StudentRepository students;
  late BatchRepository batches;
  late Batch math;
  late ClassOwner mathOwner;

  Future<Student> student(String name, {List<int> classDays = const []}) =>
      students.create(
        StudentDraft(
          name: name,
          monthlyFee: 1000,
          joinedOn: const LocalDate(2026, 1, 1),
          classDays: classDays,
        ),
      );

  Future<void> join(
    Student s, {
    LocalDate joined = const LocalDate(2026, 1, 1),
  }) => batches.addMembers(math.id, [s.id], joined);

  Future<int> rows(String table) async =>
      (await db.customSelect('SELECT COUNT(*) c FROM $table').getSingle())
          .read<int>('c');

  setUp(() async {
    db = openInMemoryDatabase();
    repo = AttendanceRepository(db);
    students = StudentRepository(db);
    batches = BatchRepository(db);
    math = await batches.create(
      const BatchDraft(
        name: 'Math 9',
        scheduleDays: [1, 3],
        startTime: ClockTime(17, 0),
        durationMin: 90,
      ),
    );
    mathOwner = ClassOwner.batch(math.id, math.name);
  });

  tearDown(() => db.close());

  group('roster', () {
    test('lists enrolled students sorted by name, all unmarked', () async {
      final b = await student('Bijoy');
      final a = await student('aman');
      await join(b);
      await join(a);
      final roster = await repo.roster(mathOwner, mar2, null);
      expect(roster.map((e) => e.student.name), ['aman', 'Bijoy']);
      expect(roster.every((e) => e.status == null), isTrue);
    });

    test('a student who joined after the date is not listed', () async {
      final s = await student('Late Joiner');
      await join(s, joined: const LocalDate(2026, 3, 5));
      expect(await repo.roster(mathOwner, mar2, null), isEmpty);
      expect(await repo.roster(mathOwner, mar9, null), hasLength(1));
    });

    test('a student who left before the date is not listed', () async {
      final s = await student('Leaver');
      await join(s);
      await batches.removeMember(math.id, s.id, const LocalDate(2026, 3, 5));
      expect(
        await repo.roster(mathOwner, mar2, null),
        hasLength(1),
      ); // still in on the 2nd
      expect(
        await repo.roster(mathOwner, const LocalDate(2026, 3, 5), null),
        isEmpty,
      );
      expect(await repo.roster(mathOwner, mar9, null), isEmpty);
    });

    test('archived students are not on a new sheet', () async {
      final s = await student('Archived');
      await join(s);
      await students.archive(s.id);
      expect(await repo.roster(mathOwner, mar2, null), isEmpty);
    });

    test(
      'but a student who was marked stays on that class even after leaving',
      () async {
        final s = await student('Marked');
        final t = await student('Other');
        await join(s);
        await join(t);
        await repo.saveAttendance(
          owner: mathOwner,
          date: mar2,
          marks: {s.id: present, t.id: absent},
        );
        await batches.removeMember(math.id, s.id, const LocalDate(2026, 3, 3));
        await students.archive(s.id);

        final roster = await repo.roster(mathOwner, mar2, null);
        expect(roster.map((e) => e.student.name), ['Marked', 'Other']);
        expect(roster.map((e) => e.status), [present, absent]);
      },
    );

    test('a one-to-one class lists just that student', () async {
      final s = await student('Solo', classDays: [1]);
      final roster = await repo.roster(
        ClassOwner.student(s.id, s.name),
        mar2,
        null,
      );
      expect(roster.map((e) => e.student.id), [s.id]);
    });

    test('another batch\'s students are not listed', () async {
      final other = await batches.create(
        const BatchDraft(name: 'Physics', scheduleDays: [1]),
      );
      final s = await student('Elsewhere');
      await batches.addMembers(other.id, [s.id], const LocalDate(2026, 1, 1));
      expect(await repo.roster(mathOwner, mar2, null), isEmpty);
    });
  });

  group('saving attendance', () {
    test('creates the class and one mark per student', () async {
      final a = await student('A');
      final b = await student('B');
      await join(a);
      await join(b);
      final saved = await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        startTime: const ClockTime(17, 0),
        topic: '  Algebra  ',
        marks: {a.id: present, b.id: late},
      );
      expect(saved.status, SessionStatus.held);
      expect(saved.topic, 'Algebra');
      expect(saved.attendanceCount, 2);
      expect(saved.attendedCount, 2); // late counts as attended
      expect(await rows('class_sessions'), 1);
      expect(await rows('attendance'), 2);
    });

    test(
      'saving the same class again updates it and never duplicates',
      () async {
        final a = await student('A');
        final b = await student('B');
        await join(a);
        await join(b);
        for (var i = 0; i < 3; i++) {
          await repo.saveAttendance(
            owner: mathOwner,
            date: mar2,
            marks: {a.id: present, b.id: present},
          );
        }
        final second = await repo.saveAttendance(
          owner: mathOwner,
          date: mar2,
          topic: 'Geometry',
          marks: {a.id: absent, b.id: excused},
        );
        expect(await rows('class_sessions'), 1);
        expect(await rows('attendance'), 2);
        expect(second.topic, 'Geometry');
        final roster = await repo.roster(mathOwner, mar2, null);
        expect(roster.map((e) => e.status), [absent, excused]);
      },
    );

    test('marks for students not submitted are left as they were', () async {
      final a = await student('A');
      final b = await student('B');
      await join(a);
      await join(b);
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: present, b.id: present},
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: absent},
      );
      final roster = await repo.roster(mathOwner, mar2, null);
      expect(roster.map((e) => e.status), [absent, present]);
    });

    test('classes at different times on one day are separate', () async {
      final a = await student('A');
      await join(a);
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        startTime: const ClockTime(9, 0),
        marks: {a.id: present},
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        startTime: const ClockTime(17, 0),
        marks: {a.id: absent},
      );
      expect(await rows('class_sessions'), 2);
      expect(
        (await repo.roster(
          mathOwner,
          mar2,
          const ClockTime(9, 0),
        )).single.status,
        present,
      );
      expect(
        (await repo.roster(
          mathOwner,
          mar2,
          const ClockTime(17, 0),
        )).single.status,
        absent,
      );
    });

    test(
      'a class with no time and one with a time are different classes',
      () async {
        final a = await student('A');
        await join(a);
        await repo.saveAttendance(
          owner: mathOwner,
          date: mar2,
          marks: {a.id: present},
        );
        expect(
          await repo.findSession(mathOwner, mar2, const ClockTime(17, 0)),
          isNull,
        );
        expect(await repo.findSession(mathOwner, mar2, null), isNotNull);
      },
    );

    test('is atomic: a failure part-way saves nothing', () async {
      final a = await student('A');
      await join(a);
      await expectLater(
        repo.saveAttendance(
          owner: mathOwner,
          date: mar2,
          marks: {a.id: present, 'no-such-student': present},
        ),
        throwsA(anything),
      );
      expect(await rows('class_sessions'), 0);
      expect(await rows('attendance'), 0);
    });

    test('a one-to-one class saves against the student', () async {
      final s = await student('Solo', classDays: [1]);
      final owner = ClassOwner.student(s.id, s.name);
      final saved = await repo.saveAttendance(
        owner: owner,
        date: mar2,
        marks: {s.id: present},
      );
      expect(saved.owner, owner);
      final row = await db.select(db.classSessions).getSingle();
      expect(row.batchId, isNull);
      expect(row.studentId, s.id);
    });
  });

  group('cancel, holiday and extra classes', () {
    test('cancelling records the reason and shows as cancelled', () async {
      final r = await repo.markOff(
        owner: mathOwner,
        date: mar2,
        status: SessionStatus.cancelled,
        reason: '  Teacher sick ',
      );
      expect(r.status, SessionStatus.cancelled);
      expect(r.note, 'Teacher sick');
    });

    test('a holiday is its own status', () async {
      final r = await repo.markOff(
        owner: mathOwner,
        date: mar2,
        status: SessionStatus.holiday,
      );
      expect(r.status, SessionStatus.holiday);
      expect(r.note, isNull);
    });

    test(
      'cancelled classes are excluded from the attendance percentage',
      () async {
        final a = await student('A');
        await join(a);
        await repo.saveAttendance(
          owner: mathOwner,
          date: mar2,
          marks: {a.id: present},
        );
        await repo.saveAttendance(
          owner: mathOwner,
          date: mar9,
          marks: {a.id: absent},
        );
        expect((await repo.watchStudentMonth(a.id, mar).first).percent, 50);

        await repo.markOff(
          owner: mathOwner,
          date: mar9,
          status: SessionStatus.cancelled,
        );
        final counts = await repo.watchStudentMonth(a.id, mar).first;
        expect(
          counts,
          const AttendanceCounts(present: 1),
        ); // the absence no longer counts
        expect(counts.percent, 100);
      },
    );

    test('reopening makes the class held and its marks count again', () async {
      final a = await student('A');
      await join(a);
      final saved = await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: absent},
      );
      await repo.markOff(
        owner: mathOwner,
        date: mar2,
        status: SessionStatus.holiday,
        reason: 'x',
      );
      await repo.reopen(saved.id);
      final again = (await repo.sessionById(saved.id))!;
      expect(again.status, SessionStatus.held);
      expect(again.note, isNull);
      expect((await repo.watchStudentMonth(a.id, mar).first).absent, 1);
    });

    test(
      'saving attendance on a cancelled class makes it held again',
      () async {
        final a = await student('A');
        await join(a);
        await repo.markOff(
          owner: mathOwner,
          date: mar2,
          status: SessionStatus.cancelled,
          reason: 'x',
        );
        final saved = await repo.saveAttendance(
          owner: mathOwner,
          date: mar2,
          marks: {a.id: present},
        );
        expect(saved.status, SessionStatus.held);
        expect(saved.note, isNull);
        expect(await rows('class_sessions'), 1);
      },
    );

    test('an extra class is added once and appears for its date', () async {
      final first = await repo.addExtraClass(
        owner: mathOwner,
        date: mar9,
        startTime: const ClockTime(19, 0),
      );
      final again = await repo.addExtraClass(
        owner: mathOwner,
        date: mar9,
        startTime: const ClockTime(19, 0),
      );
      expect(again.id, first.id);
      expect(await rows('class_sessions'), 1);

      final onDay = await repo.watchSessionsOn(mar9).first;
      expect(onDay.single.attendanceCount, 0);
      expect(await repo.watchSessionsOn(mar2).first, isEmpty);
    });

    test('an extra class shows in the monthly history once marked', () async {
      final a = await student('A');
      await join(a);
      await repo.addExtraClass(
        owner: mathOwner,
        date: const LocalDate(2026, 3, 14),
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: const LocalDate(2026, 3, 14),
        marks: {a.id: present},
      );
      expect(await repo.batchHeldClasses(math.id, mar), 1);
      expect((await repo.watchStudentMonth(a.id, mar).first).present, 1);
    });

    test('deleting a class removes its marks too', () async {
      final a = await student('A');
      await join(a);
      final saved = await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: present},
      );
      await repo.deleteSession(saved.id);
      expect(await rows('class_sessions'), 0);
      expect(await rows('attendance'), 0);
    });
  });

  group('sessions on a date', () {
    test('report how many were marked and how many came', () async {
      final a = await student('A');
      final b = await student('B');
      final c = await student('C');
      for (final s in [a, b, c]) {
        await join(s);
      }
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: present, b.id: late, c.id: absent},
      );
      final r = (await repo.watchSessionsOn(mar2).first).single;
      expect(r.owner, mathOwner);
      expect(r.attendanceCount, 3);
      expect(r.attendedCount, 2);
    });

    test('stream updates when attendance is saved', () async {
      final a = await student('A');
      await join(a);
      final counts = <int>[];
      final sub = repo
          .watchSessionsOn(mar2)
          .listen((l) => counts.add(l.isEmpty ? -1 : l.single.attendanceCount));
      await pumpEventQueue();
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: present},
      );
      await pumpEventQueue();
      await sub.cancel();
      expect(counts.first, -1);
      expect(counts.last, 1);
    });
  });

  group('aggregation', () {
    late Student a;
    late Student b;

    setUp(() async {
      a = await student('A');
      b = await student('B');
      await join(a);
      await join(b);
    });

    test('a student\'s counts and percentage follow (present + late) / (held - excused)', () async {
      // Six classes for A: P, P, L, A, E, E.
      final marks = [present, present, late, absent, excused, excused];
      for (var i = 0; i < marks.length; i++) {
        await repo.saveAttendance(
          owner: mathOwner,
          date: LocalDate(2026, 3, 2 + i),
          marks: {a.id: marks[i]},
        );
      }
      final c = await repo.watchStudentMonth(a.id, mar).first;
      expect((c.present, c.late, c.absent, c.excused), (2, 1, 1, 2));
      expect(c.percent, 75); // 3 / (6 - 2)
    });

    test('only the requested month counts', () async {
      await repo.saveAttendance(
        owner: mathOwner,
        date: const LocalDate(2026, 2, 28),
        marks: {a.id: absent},
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: const LocalDate(2026, 3, 1),
        marks: {a.id: present},
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: const LocalDate(2026, 3, 31),
        marks: {a.id: present},
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: const LocalDate(2026, 4, 1),
        marks: {a.id: absent},
      );
      expect(
        await repo.watchStudentMonth(a.id, mar).first,
        const AttendanceCounts(present: 2),
      );
      expect(
        (await repo.watchStudentMonth(a.id, const YearMonth(2026, 4)).first)
            .absent,
        1,
      );
    });

    test(
      'a month with no classes gives empty counts and no percentage',
      () async {
        final c = await repo.watchStudentMonth(a.id, mar).first;
        expect(c, AttendanceCounts.none);
        expect(c.percent, isNull);
      },
    );

    test(
      'per batch: summed over students, with the number of held classes',
      () async {
        await repo.saveAttendance(
          owner: mathOwner,
          date: mar2,
          marks: {a.id: present, b.id: absent},
        );
        await repo.saveAttendance(
          owner: mathOwner,
          date: mar9,
          marks: {a.id: present, b.id: late},
        );
        final c = await repo.batchMonth(math.id, mar);
        expect((c.present, c.absent, c.late), (2, 1, 1));
        expect(c.percent, 75);
        expect(await repo.batchHeldClasses(math.id, mar), 2);
      },
    );

    test('a batch\'s figures do not include another batch', () async {
      final other = await batches.create(
        const BatchDraft(name: 'Physics', scheduleDays: [2]),
      );
      await repo.saveAttendance(
        owner: ClassOwner.batch(other.id, other.name),
        date: mar2,
        marks: {a.id: absent},
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: present},
      );
      expect((await repo.batchMonth(math.id, mar)).total, 1);
      expect((await repo.batchMonth(other.id, mar)).absent, 1);
    });

    test('editing last week\'s class updates the monthly totals', () async {
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: absent},
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar9,
        marks: {a.id: present},
      );
      expect((await repo.watchStudentMonth(a.id, mar).first).percent, 50);

      // The tutor corrects the first class.
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: present},
      );
      expect((await repo.watchStudentMonth(a.id, mar).first).percent, 100);
    });

    test('the monthly stream updates live', () async {
      final seen = <int?>[];
      final sub = repo
          .watchStudentMonth(a.id, mar)
          .listen((c) => seen.add(c.percent));
      await pumpEventQueue();
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: present},
      );
      await pumpEventQueue();
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: absent},
      );
      await pumpEventQueue();
      await sub.cancel();
      expect(seen, [null, 100, 0]);
    });
  });

  group('calendar', () {
    late Student a;

    setUp(() async {
      a = await student('A');
      await join(a);
    });

    Future<Map<String, DayStatus>> marks() async => {
      for (final m in await repo.watchStudentCalendar(a.id, mar).first)
        m.date.toIso(): m.status,
    };

    test('shows each marked day with its status', () async {
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        marks: {a.id: present},
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar9,
        marks: {a.id: absent},
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: const LocalDate(2026, 3, 11),
        marks: {a.id: late},
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: const LocalDate(2026, 3, 13),
        marks: {a.id: excused},
      );
      expect(await marks(), {
        '2026-03-02': DayStatus.present,
        '2026-03-09': DayStatus.absent,
        '2026-03-11': DayStatus.late,
        '2026-03-13': DayStatus.excused,
      });
    });

    test('two classes in a day show the most telling status', () async {
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        startTime: const ClockTime(9, 0),
        marks: {a.id: present},
      );
      await repo.saveAttendance(
        owner: mathOwner,
        date: mar2,
        startTime: const ClockTime(17, 0),
        marks: {a.id: absent},
      );
      expect(await marks(), {'2026-03-02': DayStatus.absent});
    });

    test(
      'cancelled and holiday classes of the student\'s batch show too',
      () async {
        await repo.markOff(
          owner: mathOwner,
          date: mar2,
          status: SessionStatus.cancelled,
        );
        await repo.markOff(
          owner: mathOwner,
          date: mar9,
          status: SessionStatus.holiday,
        );
        expect(await marks(), {
          '2026-03-02': DayStatus.cancelled,
          '2026-03-09': DayStatus.holiday,
        });
      },
    );

    test('but not those of a batch the student is not in, or outside their time there', () async {
      final other = await batches.create(
        const BatchDraft(name: 'Physics', scheduleDays: [1]),
      );
      await repo.markOff(
        owner: ClassOwner.batch(other.id, other.name),
        date: mar2,
        status: SessionStatus.cancelled,
      );
      final late = await student('Late');
      await batches.addMembers(math.id, [late.id], const LocalDate(2026, 3, 5));
      await repo.markOff(
        owner: mathOwner,
        date: mar2,
        status: SessionStatus.cancelled,
      );

      final lateMarks = await repo.watchStudentCalendar(late.id, mar).first;
      expect(lateMarks, isEmpty); // cancelled on the 2nd, before they joined
      expect(await marks(), {
        '2026-03-02': DayStatus.cancelled,
      }); // A, but not Physics
    });

    test(
      'a cancelled class with marks still shows the marks only when held',
      () async {
        await repo.saveAttendance(
          owner: mathOwner,
          date: mar2,
          marks: {a.id: present},
        );
        await repo.markOff(
          owner: mathOwner,
          date: mar2,
          status: SessionStatus.holiday,
        );
        expect(await marks(), {'2026-03-02': DayStatus.holiday});
      },
    );

    test('an empty month gives an empty calendar', () async {
      expect(await marks(), isEmpty);
    });
  });

  group('schedule rules', () {
    test('batches become rules; archived ones are inactive', () async {
      final archived = await batches.create(
        const BatchDraft(name: 'Old', scheduleDays: [2]),
      );
      await batches.archive(archived.id);
      final rules = await repo.watchBatchRules().first;
      final byName = {for (final r in rules) r.owner.name: r};
      expect(byName['Math 9']!.days, [1, 3]);
      expect(byName['Math 9']!.startTime, const ClockTime(17, 0));
      expect(byName['Math 9']!.durationMin, 90);
      expect(byName['Math 9']!.active, isTrue);
      expect(byName['Old']!.active, isFalse);
    });

    test('students with class days become one-to-one rules', () async {
      await student('Plain');
      final solo = await student('Solo', classDays: [6, 1]);
      await db.customStatement(
        "UPDATE students SET class_time = '16:30' WHERE id = '${solo.id}'",
      );
      final rules = await repo.watchOneToOneRules().first;
      expect(rules, hasLength(1));
      expect(rules.single.owner.name, 'Solo');
      expect(rules.single.days, [1, 6]);
      expect(rules.single.startTime, const ClockTime(16, 30));
      await students.setStatus(solo.id, StudentStatus.left);
      expect((await repo.watchOneToOneRules().first).single.active, isFalse);
    });
  });
}
