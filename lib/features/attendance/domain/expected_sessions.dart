import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';

/// The classes for [date]: those the schedule expects, merged with those
/// already recorded (design 8.1).
///
/// Sessions are never generated ahead of time. A class on the schedule with no
/// saved row is [ClassState.notTaken]; one with a row takes its state from it.
/// A saved row with no matching schedule entry is an extra class, shown even
/// when its batch has since been archived, so history is never hidden.
///
/// Archived batches and students are left out of the schedule side only.
/// [records] of other dates are ignored. The result is ordered by start time
/// (classes without a time last), then by name.
List<ExpectedSession> expectedSessions({
  required LocalDate date,
  required List<ScheduleRule> rules,
  required List<SessionRecord> records,
}) {
  final weekday = date.isoWeekday;
  final onDate = [
    for (final r in records)
      if (r.date == date) r,
  ];
  final used = <SessionRecord>{};
  final result = <ExpectedSession>[];

  for (final rule in rules) {
    if (!rule.active || !rule.days.contains(weekday)) continue;
    final record = _match(onDate, rule.owner, rule.startTime);
    if (record != null) used.add(record);
    result.add(
      ExpectedSession(
        owner: rule.owner,
        startTime: rule.startTime,
        durationMin: rule.durationMin,
        state: _stateOf(record),
        record: record,
      ),
    );
  }

  for (final record in onDate) {
    if (used.contains(record)) continue;
    result.add(
      ExpectedSession(
        owner: record.owner,
        startTime: record.startTime,
        state: _stateOf(record),
        record: record,
        isExtra: true,
      ),
    );
  }

  result.sort((a, b) {
    final at = a.startTime;
    final bt = b.startTime;
    if (at != null && bt != null) {
      final c = at.compareTo(bt);
      if (c != 0) return c;
    } else if (at != null) {
      return -1;
    } else if (bt != null) {
      return 1;
    }
    return a.owner.name.toLowerCase().compareTo(b.owner.name.toLowerCase());
  });
  return result;
}

SessionRecord? _match(
  List<SessionRecord> records,
  ClassOwner owner,
  ClockTime? startTime,
) {
  for (final r in records) {
    if (r.owner == owner && r.startTime == startTime) return r;
  }
  return null;
}

ClassState _stateOf(SessionRecord? record) {
  if (record == null) return ClassState.notTaken;
  return switch (record.status) {
    SessionStatus.cancelled => ClassState.cancelled,
    SessionStatus.holiday => ClassState.holiday,
    // A held class counts as taken once someone has been marked.
    SessionStatus.held =>
      record.attendanceCount > 0 ? ClassState.taken : ClassState.notTaken,
  };
}
