import 'package:tution_tracker/core/dates/local_date.dart';

/// Calendar month, used for fee months (`YYYY-MM`).
class YearMonth implements Comparable<YearMonth> {
  const YearMonth(this.year, this.month)
    : assert(month >= 1 && month <= 12, 'month must be 1..12');

  factory YearMonth.from(LocalDate date) => YearMonth(date.year, date.month);

  /// Parses a `YYYY-MM` key. Throws [FormatException] on malformed input.
  factory YearMonth.parse(String key) {
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(key);
    if (match == null) {
      throw FormatException('Expected YYYY-MM', key);
    }
    final month = int.parse(match.group(2)!);
    if (month < 1 || month > 12) {
      throw FormatException('Month out of range', key);
    }
    return YearMonth(int.parse(match.group(1)!), month);
  }

  final int year;
  final int month;

  YearMonth next() => addMonths(1);

  YearMonth previous() => addMonths(-1);

  YearMonth addMonths(int n) {
    final index = year * 12 + (month - 1) + n;
    return YearMonth(index ~/ 12, index % 12 + 1);
  }

  /// Number of days in this month (leap years respected).
  int get daysInMonth => daysInMonthOf(year, month);

  LocalDate get firstDay => LocalDate(year, month, 1);

  LocalDate get lastDay => LocalDate(year, month, daysInMonth);

  /// The given [day] of this month, clamped to the month length, so due
  /// day 31 becomes the 28th/29th/30th in shorter months.
  LocalDate dayClamped(int day) {
    assert(day >= 1, 'day must be >= 1');
    return LocalDate(year, month, day > daysInMonth ? daysInMonth : day);
  }

  /// `YYYY-MM`, the stored form.
  String toKey() => '$year-${month.toString().padLeft(2, '0')}';

  bool operator <(YearMonth other) => compareTo(other) < 0;

  bool operator <=(YearMonth other) => compareTo(other) <= 0;

  bool operator >(YearMonth other) => compareTo(other) > 0;

  bool operator >=(YearMonth other) => compareTo(other) >= 0;

  @override
  int compareTo(YearMonth other) =>
      (year * 12 + month).compareTo(other.year * 12 + other.month);

  @override
  bool operator ==(Object other) =>
      other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => toKey();
}
