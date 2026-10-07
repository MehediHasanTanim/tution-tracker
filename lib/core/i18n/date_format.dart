import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';

/// Whether UI text is Bangla or English (the two supported languages).
enum AppLanguage { bn, en }

// Own tables rather than intl's date data: no async init, and the strings
// are the ones we verified render correctly with the bundled font.
const _monthsBn = [
  'জানুয়ারি',
  'ফেব্রুয়ারি',
  'মার্চ',
  'এপ্রিল',
  'মে',
  'জুন',
  'জুলাই',
  'আগস্ট',
  'সেপ্টেম্বর',
  'অক্টোবর',
  'নভেম্বর',
  'ডিসেম্বর',
];

const _monthsEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _monthsEnShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

// Index 0 = Monday (ISO weekday 1).
const _weekdaysBn = [
  'সোমবার',
  'মঙ্গলবার',
  'বুধবার',
  'বৃহস্পতিবার',
  'শুক্রবার',
  'শনিবার',
  'রবিবার',
];

const _weekdaysEn = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _monthsBnShort = [
  'জানু',
  'ফেব্রু',
  'মার্চ',
  'এপ্রিল',
  'মে',
  'জুন',
  'জুলাই',
  'আগস্ট',
  'সেপ্টে',
  'অক্টো',
  'নভে',
  'ডিসে',
];

const _weekdaysBnShort = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি', 'রবি'];

const _weekdaysEnShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// A short month name for tight spaces such as chart axes.
String monthShortName(int month, AppLanguage language) =>
    (language == AppLanguage.bn ? _monthsBnShort : _monthsEnShort)[month - 1];

/// A short weekday name for calendar headers. [isoWeekday]: 1 = Monday.
String weekdayShortName(int isoWeekday, AppLanguage language) =>
    (language == AppLanguage.bn
    ? _weekdaysBnShort
    : _weekdaysEnShort)[isoWeekday - 1];

String monthName(int month, AppLanguage language) =>
    (language == AppLanguage.bn ? _monthsBn : _monthsEn)[month - 1];

/// [isoWeekday]: 1 = Monday .. 7 = Sunday.
String weekdayName(int isoWeekday, AppLanguage language) =>
    (language == AppLanguage.bn ? _weekdaysBn : _weekdaysEn)[isoWeekday - 1];

/// `অক্টোবর ২০২৬` / `October 2026`.
String formatMonth(
  YearMonth month, {
  required AppLanguage language,
  required NumeralStyle numerals,
}) {
  final text = '${monthName(month.month, language)} ${month.year}';
  return applyNumerals(text, numerals);
}

/// `৬ অক্টোবর ২০২৬` / `6 Oct 2026`.
String formatDate(
  LocalDate date, {
  required AppLanguage language,
  required NumeralStyle numerals,
}) {
  final month = language == AppLanguage.bn
      ? _monthsBn[date.month - 1]
      : _monthsEnShort[date.month - 1];
  return applyNumerals('${date.day} $month ${date.year}', numerals);
}
