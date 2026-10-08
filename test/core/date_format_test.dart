import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';

void main() {
  test('month in Bangla and English', () {
    const m = YearMonth(2026, 10);
    expect(
      formatMonth(m, language: AppLanguage.bn, numerals: NumeralStyle.bangla),
      'অক্টোবর ২০২৬',
    );
    expect(
      formatMonth(m, language: AppLanguage.bn, numerals: NumeralStyle.western),
      'অক্টোবর 2026',
    );
    expect(
      formatMonth(m, language: AppLanguage.en, numerals: NumeralStyle.western),
      'October 2026',
    );
  });

  test('date in Bangla and English', () {
    const d = LocalDate(2026, 10, 6);
    expect(
      formatDate(d, language: AppLanguage.bn, numerals: NumeralStyle.bangla),
      '৬ অক্টোবর ২০২৬',
    );
    expect(
      formatDate(d, language: AppLanguage.en, numerals: NumeralStyle.western),
      '6 Oct 2026',
    );
  });

  test('all twelve months have a name in both languages', () {
    for (var m = 1; m <= 12; m++) {
      expect(monthName(m, AppLanguage.bn), isNotEmpty);
      expect(monthName(m, AppLanguage.en), isNotEmpty);
    }
    expect(monthName(1, AppLanguage.en), 'January');
    expect(monthName(12, AppLanguage.bn), 'ডিসেম্বর');
  });

  test('weekday names follow ISO numbering', () {
    expect(weekdayName(1, AppLanguage.en), 'Monday');
    expect(weekdayName(7, AppLanguage.en), 'Sunday');
    expect(weekdayName(5, AppLanguage.bn), 'শুক্রবার');
  });

  test('short names exist for every month and weekday in both languages', () {
    for (var m = 1; m <= 12; m++) {
      expect(monthShortName(m, AppLanguage.bn), isNotEmpty);
      expect(monthShortName(m, AppLanguage.en).length, 3);
    }
    expect(monthShortName(10, AppLanguage.bn), 'অক্টো');
    expect(weekdayShortName(1, AppLanguage.en), 'Mon');
    expect(weekdayShortName(6, AppLanguage.bn), 'শনি');
    expect(weekdayShortName(7, AppLanguage.en), 'Sun');
  });
}
