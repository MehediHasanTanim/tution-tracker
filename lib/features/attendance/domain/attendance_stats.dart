import 'package:tution_tracker/core/dates/local_date.dart';

enum AttendanceStatus { present, absent, late, excused }

/// Attendance marks added up, with the percentage rule from the design
/// (section 8.3): `(present + late) / (marked - excused)`.
///
/// Late counts as attended. Excused absences are left out of both sides, so
/// they never count against a student. Only classes that were held are
/// counted: the data layer never feeds cancelled or holiday classes in.
class AttendanceCounts {
  const AttendanceCounts({
    this.present = 0,
    this.absent = 0,
    this.late = 0,
    this.excused = 0,
  });

  factory AttendanceCounts.from(Iterable<AttendanceStatus> statuses) {
    var present = 0, absent = 0, late = 0, excused = 0;
    for (final s in statuses) {
      switch (s) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.late:
          late++;
        case AttendanceStatus.excused:
          excused++;
      }
    }
    return AttendanceCounts(
      present: present,
      absent: absent,
      late: late,
      excused: excused,
    );
  }

  static const none = AttendanceCounts();

  final int present;
  final int absent;
  final int late;
  final int excused;

  /// Everything marked, excused included.
  int get total => present + absent + late + excused;

  /// Students who came, even if late.
  int get attended => present + late;

  /// What the percentage is out of: marked classes less excused ones.
  int get counted => total - excused;

  /// 0.0 to 1.0, or null when nothing counts yet (no classes, or all excused).
  double? get rate => counted == 0 ? null : attended / counted;

  /// [rate] as a whole percent, halves rounded up, or null.
  int? get percent =>
      counted == 0 ? null : (attended * 200 + counted) ~/ (2 * counted);

  AttendanceCounts operator +(AttendanceCounts o) => AttendanceCounts(
    present: present + o.present,
    absent: absent + o.absent,
    late: late + o.late,
    excused: excused + o.excused,
  );

  @override
  bool operator ==(Object other) =>
      other is AttendanceCounts &&
      other.present == present &&
      other.absent == absent &&
      other.late == late &&
      other.excused == excused;

  @override
  int get hashCode => Object.hash(present, absent, late, excused);

  @override
  String toString() => 'P$present A$absent L$late E$excused';
}

/// How a day shows on a student's calendar.
enum DayStatus { present, late, absent, excused, cancelled, holiday }

/// One calendar day for a student.
class DayMark {
  const DayMark(this.date, this.status);

  final LocalDate date;
  final DayStatus status;
}

/// The one status a day shows when a student had several marks that day:
/// absent beats late beats present beats excused. Cancelled and holiday only
/// show on days with no attendance at all.
DayStatus? dayStatusFor({
  required Iterable<AttendanceStatus> marks,
  required Iterable<SessionKind> offDays,
}) {
  final set = marks.toSet();
  if (set.contains(AttendanceStatus.absent)) return DayStatus.absent;
  if (set.contains(AttendanceStatus.late)) return DayStatus.late;
  if (set.contains(AttendanceStatus.present)) return DayStatus.present;
  if (set.contains(AttendanceStatus.excused)) return DayStatus.excused;
  final off = offDays.toSet();
  if (off.contains(SessionKind.holiday)) return DayStatus.holiday;
  if (off.contains(SessionKind.cancelled)) return DayStatus.cancelled;
  return null;
}

/// A non-held class, for [dayStatusFor].
enum SessionKind { cancelled, holiday }
