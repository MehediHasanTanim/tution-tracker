import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';

void main() {
  group('leap years', () {
    test('rules', () {
      expect(isLeapYear(2024), isTrue);
      expect(isLeapYear(2025), isFalse);
      expect(isLeapYear(1900), isFalse);
      expect(isLeapYear(2000), isTrue);
    });

    test('days in February', () {
      expect(daysInMonthOf(2024, 2), 29);
      expect(daysInMonthOf(2025, 2), 28);
    });
  });

  group('parse and format', () {
    test('round trips', () {
      expect(LocalDate.parse('2026-10-06'), const LocalDate(2026, 10, 6));
      expect(const LocalDate(2026, 1, 5).toIso(), '2026-01-05');
    });

    test('rejects malformed and non-existent dates', () {
      for (final bad in [
        '2026-02-30',
        '2025-02-29',
        '2026-13-01',
        '2026-00-10',
        '2026-10-00',
        '2026-1-5',
        '06-10-2026',
        '',
      ]) {
        expect(() => LocalDate.parse(bad), throwsFormatException, reason: bad);
      }
      expect(LocalDate.parse('2024-02-29'), const LocalDate(2024, 2, 29));
    });

    test('checked rejects day beyond month length', () {
      expect(() => LocalDate.checked(2025, 2, 29), throwsArgumentError);
      expect(LocalDate.checked(2024, 2, 29), const LocalDate(2024, 2, 29));
    });

    test('fromDateTime keeps wall-clock fields without zone shifts', () {
      expect(
        LocalDate.fromDateTime(DateTime(2026, 3, 31, 23, 59)),
        const LocalDate(2026, 3, 31),
      );
      expect(
        LocalDate.fromDateTime(DateTime.utc(2026, 3, 31, 23, 59)),
        const LocalDate(2026, 3, 31),
      );
    });
  });

  group('arithmetic', () {
    test('addDays crosses month, year and leap day', () {
      expect(
        const LocalDate(2026, 1, 31).addDays(1),
        const LocalDate(2026, 2, 1),
      );
      expect(
        const LocalDate(2026, 12, 31).addDays(1),
        const LocalDate(2027, 1, 1),
      );
      expect(
        const LocalDate(2024, 2, 28).addDays(1),
        const LocalDate(2024, 2, 29),
      );
      expect(
        const LocalDate(2025, 2, 28).addDays(1),
        const LocalDate(2025, 3, 1),
      );
      expect(
        const LocalDate(2026, 3, 1).addDays(-1),
        const LocalDate(2026, 2, 28),
      );
    });

    test('daysUntil', () {
      expect(
        const LocalDate(2026, 1, 1).daysUntil(const LocalDate(2027, 1, 1)),
        365,
      );
      expect(
        const LocalDate(2024, 1, 1).daysUntil(const LocalDate(2025, 1, 1)),
        366,
      );
      expect(
        const LocalDate(2026, 5, 10).daysUntil(const LocalDate(2026, 5, 7)),
        -3,
      );
    });

    test('isoWeekday: Monday is 1, Sunday is 7', () {
      expect(const LocalDate(2026, 10, 5).isoWeekday, 1); // Monday
      expect(const LocalDate(2026, 10, 11).isoWeekday, 7); // Sunday
    });
  });

  group('ordering', () {
    test('compare', () {
      expect(
        const LocalDate(2026, 1, 31) < const LocalDate(2026, 2, 1),
        isTrue,
      );
      expect(
        const LocalDate(2026, 2, 1) > const LocalDate(2025, 12, 31),
        isTrue,
      );
      expect(
        const LocalDate(2026, 2, 1) <= const LocalDate(2026, 2, 1),
        isTrue,
      );
      expect(
        const LocalDate(2026, 2, 2) >= const LocalDate(2026, 2, 3),
        isFalse,
      );
    });

    test('equality and hashing', () {
      expect(const LocalDate(2026, 2, 1), const LocalDate(2026, 2, 1));
      expect(
        {const LocalDate(2026, 2, 1), LocalDate.parse('2026-02-01')}.length,
        1,
      );
    });
  });
}
