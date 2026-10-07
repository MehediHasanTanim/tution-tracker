/// Time of day (`HH:mm`), used for class start and reminder times.
class ClockTime implements Comparable<ClockTime> {
  const ClockTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24, 'hour must be 0..23'),
      assert(minute >= 0 && minute < 60, 'minute must be 0..59');

  /// Parses `HH:mm`. Throws [FormatException] on malformed input.
  factory ClockTime.parse(String text) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(text);
    if (match == null) throw FormatException('Expected HH:mm', text);
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) {
      throw FormatException('Time out of range', text);
    }
    return ClockTime(hour, minute);
  }

  final int hour;
  final int minute;

  int get minutesSinceMidnight => hour * 60 + minute;

  /// `HH:mm`, the stored form.
  String toKey() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  bool operator <(ClockTime other) => compareTo(other) < 0;

  bool operator >(ClockTime other) => compareTo(other) > 0;

  @override
  int compareTo(ClockTime other) =>
      minutesSinceMidnight.compareTo(other.minutesSinceMidnight);

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => toKey();
}
