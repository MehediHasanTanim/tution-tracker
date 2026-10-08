import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';

void main() {
  group('rollover', () {
    test('next wraps December into January', () {
      expect(const YearMonth(2026, 12).next(), const YearMonth(2027, 1));
      expect(const YearMonth(2026, 3).next(), const YearMonth(2026, 4));
    });

    test('previous wraps January into December', () {
      expect(const YearMonth(2027, 1).previous(), const YearMonth(2026, 12));
      expect(const YearMonth(2026, 4).previous(), const YearMonth(2026, 3));
    });

    test('addMonths crosses several years in both directions', () {
      expect(const YearMonth(2026, 11).addMonths(15), const YearMonth(2028, 2));
      expect(
        const YearMonth(2026, 2).addMonths(-14),
        const YearMonth(2024, 12),
      );
      expect(const YearMonth(2026, 5).addMonths(0), const YearMonth(2026, 5));
    });
  });

  group('month length', () {
    test('leap years', () {
      expect(const YearMonth(2024, 2).daysInMonth, 29);
      expect(const YearMonth(2025, 2).daysInMonth, 28);
      expect(const YearMonth(2000, 2).daysInMonth, 29); // divisible by 400
      expect(const YearMonth(1900, 2).daysInMonth, 28); // divisible by 100 only
    });

    test('30 and 31 day months', () {
      expect(const YearMonth(2026, 4).daysInMonth, 30);
      expect(const YearMonth(2026, 12).daysInMonth, 31);
    });

    test('first and last day', () {
      expect(const YearMonth(2024, 2).firstDay, const LocalDate(2024, 2, 1));
      expect(const YearMonth(2024, 2).lastDay, const LocalDate(2024, 2, 29));
    });
  });

  group('due-day clamping', () {
    test('day 31 in February', () {
      expect(
        const YearMonth(2025, 2).dayClamped(31),
        const LocalDate(2025, 2, 28),
      );
      expect(
        const YearMonth(2024, 2).dayClamped(31),
        const LocalDate(2024, 2, 29),
      );
    });

    test('day 31 in a 30-day month', () {
      expect(
        const YearMonth(2026, 4).dayClamped(31),
        const LocalDate(2026, 4, 30),
      );
    });

    test('in-range days are unchanged', () {
      expect(
        const YearMonth(2026, 4).dayClamped(10),
        const LocalDate(2026, 4, 10),
      );
      expect(
        const YearMonth(2026, 1).dayClamped(31),
        const LocalDate(2026, 1, 31),
      );
    });
  });

  group('keys and ordering', () {
    test('toKey pads the month', () {
      expect(const YearMonth(2026, 3).toKey(), '2026-03');
      expect(const YearMonth(2026, 12).toKey(), '2026-12');
    });

    test('parse round trips', () {
      expect(YearMonth.parse('2026-03'), const YearMonth(2026, 3));
      expect(
        YearMonth.parse(const YearMonth(1999, 12).toKey()),
        const YearMonth(1999, 12),
      );
    });

    test('parse rejects malformed keys', () {
      for (final bad in [
        '2026-13',
        '2026-00',
        '2026-3',
        '26-03',
        '2026/03',
        '',
      ]) {
        expect(() => YearMonth.parse(bad), throwsFormatException, reason: bad);
      }
    });

    test('compare across year boundaries', () {
      expect(const YearMonth(2025, 12) < const YearMonth(2026, 1), isTrue);
      expect(const YearMonth(2026, 2) > const YearMonth(2026, 1), isTrue);
      expect(const YearMonth(2026, 2) <= const YearMonth(2026, 2), isTrue);
      expect(const YearMonth(2026, 2) >= const YearMonth(2026, 3), isFalse);
    });

    test('equality and hashing', () {
      final months = [const YearMonth(2026, 2), YearMonth.parse('2026-02')];
      expect(months.first, months.last);
      expect(months.toSet().length, 1);
    });

    test('from a LocalDate', () {
      expect(
        YearMonth.from(const LocalDate(2026, 10, 31)),
        const YearMonth(2026, 10),
      );
    });
  });
}
