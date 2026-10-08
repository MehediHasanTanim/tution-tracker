/// True for Gregorian leap years.
bool isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

/// Days in [month] (1..12) of [year].
int daysInMonthOf(int year, int month) {
  assert(month >= 1 && month <= 12, 'month must be 1..12');
  const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return month == 2 && isLeapYear(year) ? 29 : days[month - 1];
}

/// A calendar date with no time or zone, stored as `YYYY-MM-DD`.
///
/// Built from year/month/day so date-only values can never shift across
/// midnight through `DateTime` zone conversion (design section 5.2).
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day)
    : assert(month >= 1 && month <= 12, 'month must be 1..12'),
      assert(day >= 1 && day <= 31, 'day must be 1..31');

  /// Throws [ArgumentError] when the day does not exist in that month.
  factory LocalDate.checked(int year, int month, int day) {
    if (month < 1 ||
        month > 12 ||
        day < 1 ||
        day > daysInMonthOf(year, month)) {
      throw ArgumentError('Invalid date $year-$month-$day');
    }
    return LocalDate(year, month, day);
  }

  /// Takes the wall-clock fields of [dateTime] as-is (no zone conversion).
  factory LocalDate.fromDateTime(DateTime dateTime) =>
      LocalDate(dateTime.year, dateTime.month, dateTime.day);

  /// Parses `YYYY-MM-DD`. Throws [FormatException] on malformed or
  /// non-existent dates.
  factory LocalDate.parse(String iso) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
    if (match == null) {
      throw FormatException('Expected YYYY-MM-DD', iso);
    }
    final y = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final d = int.parse(match.group(3)!);
    if (m < 1 || m > 12 || d < 1 || d > daysInMonthOf(y, m)) {
      throw FormatException('Date does not exist', iso);
    }
    return LocalDate(y, m, d);
  }

  final int year;
  final int month;
  final int day;

  /// 1 = Monday .. 7 = Sunday (ISO weekday).
  int get isoWeekday => DateTime.utc(year, month, day).weekday;

  int get daysInMonth => daysInMonthOf(year, month);

  LocalDate addDays(int n) {
    // UTC arithmetic has no DST gaps, so day math is exact.
    final shifted = DateTime.utc(year, month, day + n);
    return LocalDate(shifted.year, shifted.month, shifted.day);
  }

  /// Whole days from this date to [other] (negative if [other] is earlier).
  int daysUntil(LocalDate other) => DateTime.utc(
    other.year,
    other.month,
    other.day,
  ).difference(DateTime.utc(year, month, day)).inDays;

  /// `YYYY-MM-DD`, the stored form.
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  bool operator <(LocalDate other) => compareTo(other) < 0;

  bool operator <=(LocalDate other) => compareTo(other) <= 0;

  bool operator >(LocalDate other) => compareTo(other) > 0;

  bool operator >=(LocalDate other) => compareTo(other) >= 0;

  @override
  int compareTo(LocalDate other) {
    final byYear = year.compareTo(other.year);
    if (byYear != 0) return byYear;
    final byMonth = month.compareTo(other.month);
    return byMonth != 0 ? byMonth : day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
