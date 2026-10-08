import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/i18n/bangla_calendar.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';

BanglaDate b(int y, int m, int d) => toBanglaDate(LocalDate(y, m, d));

void main() {
  group('conversion', () {
    test('Pohela Boishakh and the day before it', () {
      expect(b(2026, 4, 14), const BanglaDate(1433, 1, 1));
      expect(b(2026, 4, 13), const BanglaDate(1432, 12, 30));
    });

    test('well-known days', () {
      expect(b(2025, 12, 16), const BanglaDate(1432, 9, 2)); // Victory Day
      expect(b(2026, 3, 26), const BanglaDate(1432, 12, 12)); // Independence
      expect(b(2026, 1, 1), const BanglaDate(1432, 9, 18));
    });

    test('Falgun has 31 days in a leap year, 30 otherwise', () {
      expect(b(2024, 2, 29), const BanglaDate(1430, 11, 17));
      expect(b(2024, 3, 14), const BanglaDate(1430, 11, 31));
      expect(b(2024, 3, 15), const BanglaDate(1430, 12, 1));
      expect(b(2026, 3, 14), const BanglaDate(1432, 11, 30));
      expect(b(2026, 3, 15), const BanglaDate(1432, 12, 1));
    });

    test('the year turns over on 14 April only', () {
      expect(b(2026, 1, 1).year, 1432);
      expect(b(2026, 4, 13).year, 1432);
      expect(b(2026, 4, 14).year, 1433);
      expect(b(2026, 12, 31).year, 1433);
    });

    test('every day of several years is valid and runs on from the last', () {
      var date = const LocalDate(2023, 1, 1);
      var prev = toBanglaDate(date);
      for (var i = 0; i < 365 * 5; i++) {
        date = date.addDays(1);
        final cur = toBanglaDate(date);
        expect(cur.day, inInclusiveRange(1, 31), reason: '$date');
        if (cur.day == 1) {
          expect(cur.month, prev.month % 12 + 1, reason: '$date');
          expect(
            prev.day,
            inInclusiveRange(30, 31),
            reason: 'month before $date',
          );
        } else {
          expect(cur.month, prev.month, reason: '$date');
          expect(cur.day, prev.day + 1, reason: '$date');
        }
        prev = cur;
      }
    });
  });

  group('formatting', () {
    test('Bangla names and digits', () {
      expect(
        formatBanglaDate(
          const LocalDate(2026, 4, 14),
          language: AppLanguage.bn,
          numerals: NumeralStyle.bangla,
        ),
        '১ বৈশাখ ১৪৩৩',
      );
    });

    test('English names and Western digits', () {
      expect(
        formatBanglaDate(
          const LocalDate(2026, 4, 14),
          language: AppLanguage.en,
          numerals: NumeralStyle.western,
        ),
        '1 Boishakh 1433',
      );
    });

    test('formatDate adds it only when asked', () {
      const d = LocalDate(2026, 10, 7);
      expect(
        formatDate(d, language: AppLanguage.en, numerals: NumeralStyle.western),
        '7 Oct 2026',
      );
      expect(
        formatDate(
          d,
          language: AppLanguage.en,
          numerals: NumeralStyle.western,
          calendar: CalendarStyle.bangla,
        ),
        '7 Oct 2026 (22 Ashwin 1433)',
      );
    });
  });
}
