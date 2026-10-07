import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';

void main() {
  test('parse and format round trip', () {
    expect(ClockTime.parse('07:05'), const ClockTime(7, 5));
    expect(const ClockTime(17, 0).toKey(), '17:00');
    expect(
      ClockTime.parse(const ClockTime(23, 59).toKey()),
      const ClockTime(23, 59),
    );
  });

  test('rejects malformed or out-of-range input', () {
    for (final bad in ['7:05', '24:00', '12:60', '12-30', '', 'noon']) {
      expect(() => ClockTime.parse(bad), throwsFormatException, reason: bad);
    }
  });

  test('ordering and equality', () {
    expect(const ClockTime(9, 0) < const ClockTime(9, 1), isTrue);
    expect(const ClockTime(9, 0), const ClockTime(9, 0));
    expect(const ClockTime(17, 30).minutesSinceMidnight, 1050);
  });
}
