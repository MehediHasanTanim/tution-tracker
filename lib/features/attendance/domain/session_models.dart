import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';

enum OwnerKind { batch, student }

/// Whose class it is: a batch, or one student (one-to-one tutoring).
class ClassOwner {
  const ClassOwner.batch(this.id, this.name) : kind = OwnerKind.batch;

  const ClassOwner.student(this.id, this.name) : kind = OwnerKind.student;

  final OwnerKind kind;
  final String id;

  /// Shown in lists. Not part of the owner's identity.
  final String name;

  @override
  bool operator ==(Object other) =>
      other is ClassOwner && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);

  @override
  String toString() => '${kind.name}:$id';
}

/// A recurring class from a batch or a one-to-one student's own schedule.
class ScheduleRule {
  const ScheduleRule({
    required this.owner,
    required this.days,
    this.startTime,
    this.durationMin,
    this.active = true,
  });

  final ClassOwner owner;

  /// ISO weekdays, 1 = Monday .. 7 = Sunday.
  final List<int> days;
  final ClockTime? startTime;
  final int? durationMin;

  /// False for an archived batch or an archived student.
  final bool active;
}

/// How a recorded class turned out.
enum SessionStatus { held, cancelled, holiday }

/// A class that has a row in the database.
class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.owner,
    required this.date,
    required this.status,
    this.startTime,
    this.topic,
    this.note,
    this.attendanceCount = 0,
    this.attendedCount = 0,
  });

  final String id;
  final ClassOwner owner;
  final LocalDate date;
  final ClockTime? startTime;
  final SessionStatus status;
  final String? topic;

  /// The reason for a cancellation or holiday.
  final String? note;

  /// Attendance rows saved for this class.
  final int attendanceCount;

  /// Of those, students present or late.
  final int attendedCount;
}

/// What the Today screen shows for one class.
enum ClassState {
  /// Scheduled (or added) but no attendance saved yet.
  notTaken,

  /// Attendance has been saved.
  taken,
  cancelled,
  holiday,
}

/// One class on a given day: scheduled, extra, or both once recorded.
class ExpectedSession {
  const ExpectedSession({
    required this.owner,
    required this.state,
    this.startTime,
    this.durationMin,
    this.record,
    this.isExtra = false,
  });

  final ClassOwner owner;
  final ClockTime? startTime;
  final int? durationMin;
  final ClassState state;

  /// The saved row, if there is one.
  final SessionRecord? record;

  /// True for a class that is not on the schedule (spec AT-3).
  final bool isExtra;
}
