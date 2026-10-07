import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/features/attendance/domain/expected_sessions.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';

/// What a reminder is about (design 9.1).
enum ReminderKind {
  /// Shortly before a scheduled class.
  classStart,

  /// Morning of a day on which one or more fees fall due.
  feesDue,

  /// Weekly total of what is still owed.
  weeklySummary,

  /// Nudge to export a backup.
  backup,

  /// Last in the window: opening the app plans the next two weeks.
  keepOn,
}

/// One notification to schedule. Texts are not here: they depend on the
/// language at scheduling time and are filled in by the scheduler.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.kind,
    required this.at,
    this.owner,
    this.date,
    this.time,
    this.count = 0,
    this.amount = 0,
  });

  /// Stable across re-plans: the same reminder always gets the same id.
  final int id;
  final ReminderKind kind;

  /// Local wall-clock time to fire.
  final DateTime at;

  /// [classStart]: the class.
  final ClassOwner? owner;
  final LocalDate? date;
  final ClockTime? time;

  /// [feesDue], [weeklySummary]: how many students.
  final int count;

  /// [feesDue], [weeklySummary]: taka owed.
  final int amount;
}

/// An open (unpaid, unwaived) due of an active student.
class DueEntry {
  const DueEntry({
    required this.studentId,
    required this.dueDate,
    required this.balance,
  });

  final String studentId;
  final LocalDate dueDate;
  final int balance;
}

/// Which reminders are wanted and when.
class ReminderConfig {
  const ReminderConfig({
    this.classReminders = true,
    this.classMinutesBefore = 30,
    this.feeReminders = true,
    this.feeTime = const ClockTime(8, 0),
    this.weeklySummary = true,
    this.weeklyDay = DateTime.friday,
    this.weeklyTime = const ClockTime(18, 0),
    this.backupReminders = true,
    this.backupAfterDays = 14,
    this.lastBackup,
  });

  final bool classReminders;
  final int classMinutesBefore;
  final bool feeReminders;
  final ClockTime feeTime;
  final bool weeklySummary;

  /// ISO weekday, 1 = Monday.
  final int weeklyDay;
  final ClockTime weeklyTime;
  final bool backupReminders;
  final int backupAfterDays;

  /// Null when no backup has ever been made.
  final DateTime? lastBackup;
}

/// Android drops alarms past a few hundred; stay well under that.
const maxPlannedReminders = 400;

const _backupHour = ClockTime(10, 0);
const _keepOnHour = ClockTime(9, 0);

/// Everything to notify about in the next [windowDays] days (design 9.2).
///
/// Pure and deterministic: the same inputs give the same list, ids included,
/// so cancelling everything and scheduling this list again never duplicates.
/// Reminders already in the past are left out. The result is ordered by time.
List<PlannedReminder> planReminders({
  required DateTime now,
  required ReminderConfig config,
  required List<ScheduleRule> rules,
  required List<SessionRecord> records,
  required List<DueEntry> dues,
  int windowDays = 14,
}) {
  final today = LocalDate.fromDateTime(now);
  final days = [for (var i = 0; i < windowDays; i++) today.addDays(i)];
  final planned = <PlannedReminder>[];

  DateTime at(LocalDate d, ClockTime t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  void add(
    ReminderKind kind,
    DateTime when,
    String target, {
    ClassOwner? owner,
    LocalDate? date,
    ClockTime? time,
    int count = 0,
    int amount = 0,
  }) {
    if (!when.isAfter(now)) return;
    planned.add(
      PlannedReminder(
        id: _stableId('${kind.name}|$target|${when.toIso8601String()}'),
        kind: kind,
        at: when,
        owner: owner,
        date: date,
        time: time,
        count: count,
        amount: amount,
      ),
    );
  }

  if (config.classReminders) {
    for (final day in days) {
      for (final s in expectedSessions(
        date: day,
        rules: rules,
        records: records,
      )) {
        final start = s.startTime;
        if (start == null || s.state != ClassState.notTaken) continue;
        add(
          ReminderKind.classStart,
          at(day, start).subtract(Duration(minutes: config.classMinutesBefore)),
          '${s.owner.kind.name}:${s.owner.id}',
          owner: s.owner,
          date: day,
          time: start,
        );
      }
    }
  }

  if (config.feeReminders) {
    for (final day in days) {
      final due = [
        for (final d in dues)
          if (d.dueDate == day) d,
      ];
      if (due.isEmpty) continue;
      add(
        ReminderKind.feesDue,
        at(day, config.feeTime),
        'fees',
        date: day,
        count: {for (final d in due) d.studentId}.length,
        amount: due.fold(0, (sum, d) => sum + d.balance),
      );
    }
  }

  if (config.weeklySummary) {
    final owing = {for (final d in dues) d.studentId};
    final total = dues.fold<int>(0, (sum, d) => sum + d.balance);
    if (total > 0) {
      for (final day in days) {
        if (day.isoWeekday != config.weeklyDay) continue;
        add(
          ReminderKind.weeklySummary,
          at(day, config.weeklyTime),
          'weekly',
          date: day,
          count: owing.length,
          amount: total,
        );
      }
    }
  }

  if (config.backupReminders) {
    final last = config.lastBackup ?? now;
    var when = DateTime(
      last.year,
      last.month,
      last.day,
      _backupHour.hour,
      _backupHour.minute,
    ).add(Duration(days: config.backupAfterDays));
    // Already overdue: nudge once, tomorrow morning.
    if (!when.isAfter(now)) {
      final tomorrow = today.addDays(1);
      when = at(tomorrow, _backupHour);
    }
    if (when.isBefore(at(today.addDays(windowDays), const ClockTime(0, 0)))) {
      add(ReminderKind.backup, when, 'backup');
    }
  }

  if (planned.isNotEmpty || config.classReminders || config.feeReminders) {
    add(
      ReminderKind.keepOn,
      at(today.addDays(windowDays - 1), _keepOnHour),
      'keep-on',
    );
  }

  planned.sort((a, b) {
    final c = a.at.compareTo(b.at);
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  final capped = planned.length > maxPlannedReminders
      ? planned.sublist(0, maxPlannedReminders)
      : planned;
  return _uniqueIds(capped);
}

/// FNV-1a, folded to a positive 31-bit int (notification ids are 32-bit).
int _stableId(String key) {
  var hash = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

/// Two reminders could in theory hash alike; nudge later ones deterministically.
List<PlannedReminder> _uniqueIds(List<PlannedReminder> list) {
  final seen = <int>{};
  return [
    for (final r in list)
      () {
        var id = r.id;
        while (!seen.add(id)) {
          id = (id + 1) & 0x7fffffff;
        }
        return id == r.id
            ? r
            : PlannedReminder(
                id: id,
                kind: r.kind,
                at: r.at,
                owner: r.owner,
                date: r.date,
                time: r.time,
                count: r.count,
                amount: r.amount,
              );
      }(),
  ];
}
