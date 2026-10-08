import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';

/// A date in the Bangladesh revised Bangla calendar (Bangabda).
class BanglaDate {
  const BanglaDate(this.year, this.month, this.day);

  final int year;

  /// 1 = Boishakh .. 12 = Choitro.
  final int month;
  final int day;

  @override
  bool operator ==(Object other) =>
      other is BanglaDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => 'BanglaDate($year-$month-$day)';
}

// In the revised calendar every month starts on a fixed Gregorian date, so
// conversion is a table lookup. Falgun gets its extra day in leap years
// because 29 February falls inside it.
const _starts = <(int month, int day, int banglaMonth)>[
  (1, 14, 10), // Magh
  (2, 13, 11), // Falgun
  (3, 15, 12), // Choitro
  (4, 14, 1), // Boishakh
  (5, 15, 2), // Joishtho
  (6, 15, 3), // Asharh
  (7, 16, 4), // Srabon
  (8, 16, 5), // Bhadro
  (9, 16, 6), // Ashwin
  (10, 16, 7), // Kartik
  (11, 15, 8), // Ogrohayon
  (12, 15, 9), // Poush
];

BanglaDate toBanglaDate(LocalDate date) {
  // Before 14 January the month is still Poush, begun the previous 15 Dec.
  var startYear = date.year;
  var start = _starts.last;
  for (final s in _starts) {
    if (date.month > s.$1 || (date.month == s.$1 && date.day >= s.$2)) {
      start = s;
    }
  }
  if (date.month == 1 && date.day < 14) startYear = date.year - 1;
  final from = LocalDate(startYear, start.$1, start.$2);
  final day = from.daysUntil(date) + 1;
  // The year turns over on 14 April.
  final newYear = date.month > 4 || (date.month == 4 && date.day >= 14);
  return BanglaDate(date.year - (newYear ? 593 : 594), start.$3, day);
}

const _monthsBn = [
  'বৈশাখ',
  'জ্যৈষ্ঠ',
  'আষাঢ়',
  'শ্রাবণ',
  'ভাদ্র',
  'আশ্বিন',
  'কার্তিক',
  'অগ্রহায়ণ',
  'পৌষ',
  'মাঘ',
  'ফাল্গুন',
  'চৈত্র',
];

const _monthsEn = [
  'Boishakh',
  'Joishtho',
  'Asharh',
  'Srabon',
  'Bhadro',
  'Ashwin',
  'Kartik',
  'Ogrohayon',
  'Poush',
  'Magh',
  'Falgun',
  'Choitro',
];

String banglaMonthName(int month, AppLanguage language) =>
    (language == AppLanguage.bn ? _monthsBn : _monthsEn)[month - 1];

/// `১৫ বৈশাখ ১৪৩৩` / `15 Boishakh 1433`.
String formatBanglaDate(
  LocalDate date, {
  required AppLanguage language,
  required NumeralStyle numerals,
}) {
  final b = toBanglaDate(date);
  return applyNumerals(
    '${b.day} ${banglaMonthName(b.month, language)} ${b.year}',
    numerals,
  );
}
