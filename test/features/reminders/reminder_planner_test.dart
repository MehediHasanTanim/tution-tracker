import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/features/reminders/domain/reminder_planner.dart';

// 2026-03-15 is a Sunday.
final _now = DateTime(2026, 3, 15, 10);

const _math = ClassOwner.batch('b1', 'Math 9');
const _solo = ClassOwner.student('s1', 'Rahim');

ScheduleRule _rule(
  ClassOwner owner,
  List<int> days, {
  ClockTime? time = const ClockTime(17, 0),
  bool active = true,
}) => ScheduleRule(owner: owner, days: days, startTime: time, active: active);

List<PlannedReminder> _plan({
  ReminderConfig config = const ReminderConfig(
    feeReminders: false,
    weeklySummary: false,
    backupReminders: false,
  ),
  List<ScheduleRule> rules = const [],
  List<SessionRecord> records = const [],
  List<DueEntry> dues = const [],
  DateTime? now,
}) => planReminders(
  now: now ?? _now,
  config: config,
  rules: rules,
  records: records,
  dues: dues,
);

Iterable<PlannedReminder> _of(List<PlannedReminder> l, ReminderKind k) =>
    l.where((r) => r.kind == k);

void main() {
  group('class reminders', () {
    test('one per scheduled class in the 14-day window, 30 min before', () {
      // Sundays and Wednesdays: 15, 18, 22, 25, 29 Mar, 1, 5, 8 Apr...
      final plan = _plan(
        rules: [
          _rule(_math, [7, 3]),
        ],
      );
      final classes = _of(plan, ReminderKind.classStart).toList();
      // Window is 15 Mar to 28 Mar: Sun 15, Wed 18, Sun 22, Wed 25.
      expect(classes.map((r) => r.date), [
        const LocalDate(2026, 3, 15),
        const LocalDate(2026, 3, 18),
        const LocalDate(2026, 3, 22),
        const LocalDate(2026, 3, 25),
      ]);
      expect(classes.first.at, DateTime(2026, 3, 15, 16, 30));
      expect(classes.first.owner, _math);
      expect(classes.first.time, const ClockTime(17, 0));
    });

    test('a reminder time already past is not planned', () {
      final plan = _plan(
        rules: [
          _rule(_math, [7]),
        ],
        now: DateTime(2026, 3, 15, 16, 45), // 16:30 has gone by
      );
      expect(_of(plan, ReminderKind.classStart).map((r) => r.date), [
        const LocalDate(2026, 3, 22),
      ]);
    });

    test('the lead time follows the setting', () {
      final plan = _plan(
        config: const ReminderConfig(
          classMinutesBefore: 10,
          feeReminders: false,
          weeklySummary: false,
          backupReminders: false,
        ),
        rules: [
          _rule(_math, [7]),
        ],
      );
      expect(_of(plan, ReminderKind.classStart).first.at.minute, 50);
    });

    test('cancelled, holiday and already-taken classes are skipped', () {
      SessionRecord rec(LocalDate d, SessionStatus s) => SessionRecord(
        id: d.toIso(),
        owner: _math,
        date: d,
        startTime: const ClockTime(17, 0),
        status: s,
        attendanceCount: s == SessionStatus.held ? 5 : 0,
        attendedCount: s == SessionStatus.held ? 5 : 0,
      );
      final plan = _plan(
        rules: [
          _rule(_math, [7, 3]),
        ],
        records: [
          rec(const LocalDate(2026, 3, 15), SessionStatus.held),
          rec(const LocalDate(2026, 3, 18), SessionStatus.cancelled),
          rec(const LocalDate(2026, 3, 22), SessionStatus.holiday),
        ],
      );
      expect(_of(plan, ReminderKind.classStart).map((r) => r.date), [
        const LocalDate(2026, 3, 25),
      ]);
    });

    test('classes without a start time and inactive rules get none', () {
      final plan = _plan(
        rules: [
          _rule(_math, [7], time: null),
          _rule(_solo, [7], active: false),
        ],
      );
      expect(_of(plan, ReminderKind.classStart), isEmpty);
    });

    test('one-to-one classes are included', () {
      final plan = _plan(
        rules: [
          _rule(_solo, [1]),
        ],
      );
      expect(_of(plan, ReminderKind.classStart), hasLength(2));
    });

    test('an extra class on the day is reminded too', () {
      final plan = _plan(
        records: const [
          SessionRecord(
            id: 'x',
            owner: _math,
            date: LocalDate(2026, 3, 20),
            startTime: ClockTime(9, 0),
            status: SessionStatus.held,
          ),
        ],
      );
      // An extra class added but not yet marked is still ahead of the tutor.
      final r = _of(plan, ReminderKind.classStart).single;
      expect(r.at, DateTime(2026, 3, 20, 8, 30));
    });

    test('switched off, none are planned', () {
      final plan = _plan(
        config: const ReminderConfig(
          classReminders: false,
          feeReminders: false,
          weeklySummary: false,
          backupReminders: false,
        ),
        rules: [
          _rule(_math, [7]),
        ],
      );
      expect(plan, isEmpty);
    });
  });

  group('fee reminders', () {
    const config = ReminderConfig(
      classReminders: false,
      weeklySummary: false,
      backupReminders: false,
    );

    test('are grouped: one per day with the right counts', () {
      final plan = _plan(
        config: config,
        dues: const [
          DueEntry(
            studentId: 'a',
            dueDate: LocalDate(2026, 3, 16),
            balance: 1500,
          ),
          DueEntry(
            studentId: 'b',
            dueDate: LocalDate(2026, 3, 16),
            balance: 1000,
          ),
          // A second open due of the same student counts the student once.
          DueEntry(
            studentId: 'a',
            dueDate: LocalDate(2026, 3, 16),
            balance: 200,
          ),
          DueEntry(
            studentId: 'c',
            dueDate: LocalDate(2026, 3, 20),
            balance: 700,
          ),
        ],
      );
      final fees = _of(plan, ReminderKind.feesDue).toList();
      expect(fees, hasLength(2));
      expect(fees[0].at, DateTime(2026, 3, 16, 8));
      expect(fees[0].count, 2);
      expect(fees[0].amount, 2700);
      expect(fees[1].count, 1);
      expect(fees[1].amount, 700);
    });

    test('a due beyond the window or already past is not planned', () {
      final plan = _plan(
        config: config,
        dues: const [
          DueEntry(
            studentId: 'a',
            dueDate: LocalDate(2026, 3, 10),
            balance: 100,
          ),
          DueEntry(
            studentId: 'b',
            dueDate: LocalDate(2026, 4, 30),
            balance: 100,
          ),
        ],
      );
      expect(_of(plan, ReminderKind.feesDue), isEmpty);
    });

    test('today is planned only while the morning time is ahead', () {
      const due = [
        DueEntry(studentId: 'a', dueDate: LocalDate(2026, 3, 15), balance: 100),
      ];
      expect(
        _of(_plan(config: config, dues: due), ReminderKind.feesDue),
        isEmpty,
      );
      expect(
        _of(
          _plan(config: config, dues: due, now: DateTime(2026, 3, 15, 6)),
          ReminderKind.feesDue,
        ),
        hasLength(1),
      );
    });
  });

  group('weekly summary', () {
    test('falls on the chosen weekday with the total owed', () {
      final plan = _plan(
        config: const ReminderConfig(
          classReminders: false,
          feeReminders: false,
          backupReminders: false,
        ),
        dues: const [
          DueEntry(
            studentId: 'a',
            dueDate: LocalDate(2026, 3, 1),
            balance: 1500,
          ),
          DueEntry(
            studentId: 'b',
            dueDate: LocalDate(2026, 3, 1),
            balance: 500,
          ),
        ],
      );
      final weekly = _of(plan, ReminderKind.weeklySummary).toList();
      // Fridays 20 Mar and 27 Mar at 18:00.
      expect(weekly.map((r) => r.at), [
        DateTime(2026, 3, 20, 18),
        DateTime(2026, 3, 27, 18),
      ]);
      expect(weekly.first.amount, 2000);
      expect(weekly.first.count, 2);
    });

    test('nothing owed, nothing to summarise', () {
      final plan = _plan(
        config: const ReminderConfig(
          classReminders: false,
          feeReminders: false,
          backupReminders: false,
        ),
      );
      expect(_of(plan, ReminderKind.weeklySummary), isEmpty);
    });
  });

  group('backup reminder', () {
    const only = ReminderConfig(
      classReminders: false,
      feeReminders: false,
      weeklySummary: false,
    );

    test('comes N days after the last backup', () {
      final plan = _plan(
        config: ReminderConfig(
          classReminders: only.classReminders,
          feeReminders: false,
          weeklySummary: false,
          backupAfterDays: 14,
          lastBackup: DateTime(2026, 3, 5, 12),
        ),
      );
      expect(
        _of(plan, ReminderKind.backup).single.at,
        DateTime(2026, 3, 19, 10),
      );
    });

    test('overdue: one nudge tomorrow morning', () {
      final plan = _plan(
        config: ReminderConfig(
          classReminders: false,
          feeReminders: false,
          weeklySummary: false,
          lastBackup: DateTime(2026, 1, 1),
        ),
      );
      expect(
        _of(plan, ReminderKind.backup).single.at,
        DateTime(2026, 3, 16, 10),
      );
    });

    test('never backed up counts from now', () {
      final plan = _plan(
        config: const ReminderConfig(
          classReminders: false,
          feeReminders: false,
          weeklySummary: false,
          backupAfterDays: 7,
        ),
      );
      expect(
        _of(plan, ReminderKind.backup).single.at,
        DateTime(2026, 3, 22, 10),
      );
    });

    test('too far ahead to plan yet', () {
      final plan = _plan(
        config: ReminderConfig(
          classReminders: false,
          feeReminders: false,
          weeklySummary: false,
          backupAfterDays: 60,
          lastBackup: _now,
        ),
      );
      expect(_of(plan, ReminderKind.backup), isEmpty);
    });
  });

  group('window and identity', () {
    final rules = [
      _rule(_math, [7, 3]),
      _rule(_solo, [2, 4]),
    ];
    const dues = [
      DueEntry(studentId: 'a', dueDate: LocalDate(2026, 3, 17), balance: 900),
    ];

    test('the last reminder asks the tutor to open the app', () {
      final plan = _plan(
        config: const ReminderConfig(),
        rules: rules,
        dues: dues,
      );
      final keepOn = _of(plan, ReminderKind.keepOn).single;
      expect(keepOn.at, DateTime(2026, 3, 28, 9));
    });

    test('everything is inside the window and in time order', () {
      final plan = _plan(
        config: const ReminderConfig(),
        rules: rules,
        dues: dues,
      );
      for (final r in plan) {
        expect(r.at.isAfter(_now), isTrue);
        expect(r.at.isBefore(DateTime(2026, 3, 29)), isTrue);
      }
      final times = plan.map((r) => r.at).toList();
      expect([...times]..sort(), times);
    });

    test('ids are unique and identical across re-plans', () {
      final a = _plan(config: const ReminderConfig(), rules: rules, dues: dues);
      final b = _plan(config: const ReminderConfig(), rules: rules, dues: dues);
      expect(a.map((r) => r.id).toSet(), hasLength(a.length));
      expect(a.map((r) => r.id), b.map((r) => r.id));
      expect(a.every((r) => r.id >= 0 && r.id <= 0x7fffffff), isTrue);
    });

    test('a changed schedule changes only the affected reminders', () {
      final before = _plan(rules: rules);
      final after = _plan(rules: [rules.first]);
      final shared = before
          .map((r) => r.id)
          .toSet()
          .intersection(after.map((r) => r.id).toSet());
      expect(shared, isNotEmpty);
      expect(after.length, lessThan(before.length));
    });

    test('is capped well under the Android alarm limit', () {
      final many = [
        for (var i = 0; i < 60; i++)
          _rule(ClassOwner.batch('b$i', 'B$i'), [1, 2, 3, 4, 5, 6, 7]),
      ];
      final plan = _plan(rules: many);
      expect(plan.length, lessThanOrEqualTo(maxPlannedReminders));
      expect(plan.map((r) => r.id).toSet(), hasLength(plan.length));
    });
  });
}
