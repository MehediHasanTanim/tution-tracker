import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_message.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_stats.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

final bn = lookupAppLocalizations(const Locale('bn'));
final en = lookupAppLocalizations(const Locale('en'));

const counts = AttendanceCounts(present: 10, late: 1, absent: 1, excused: 2);

void main() {
  test('Bangla message with Bangla digits', () {
    final text = composeAttendanceSummary(
      l10n: bn,
      studentName: 'রহিম উদ্দিন',
      monthText: 'মার্চ ২০২৬',
      counts: counts,
      numerals: NumeralStyle.bangla,
    );
    expect(
      text,
      [
        'রহিম উদ্দিন — মার্চ ২০২৬-এর উপস্থিতি',
        'মোট ক্লাস: ১৪',
        'উপস্থিত ১০ · দেরি ১ · অনুপস্থিত ১ · ছুটি ২',
        'উপস্থিতির হার: ৯২%', // 11 of (14 - 2)
      ].join('\n'),
    );
  });

  test('English message with English digits', () {
    final text = composeAttendanceSummary(
      l10n: en,
      studentName: 'Rahim',
      monthText: 'March 2026',
      counts: counts,
      numerals: NumeralStyle.western,
    );
    expect(
      text,
      [
        'Rahim — attendance for March 2026',
        'Classes: 14',
        'Present 10 · Late 1 · Absent 1 · Excused 2',
        'Attendance rate: 92%',
      ].join('\n'),
    );
  });

  test('digits follow the numeral setting, not the language', () {
    final text = composeAttendanceSummary(
      l10n: bn,
      studentName: 'Rahim',
      monthText: 'March 2026',
      counts: counts,
      numerals: NumeralStyle.western,
    );
    expect(text, contains('মোট ক্লাস: 14'));
    expect(text, contains('উপস্থিতির হার: 92%'));
  });

  test('a month with no classes says so', () {
    final text = composeAttendanceSummary(
      l10n: en,
      studentName: 'Rahim',
      monthText: 'March 2026',
      counts: AttendanceCounts.none,
      numerals: NumeralStyle.western,
    );
    expect(
      text,
      'Rahim — attendance for March 2026\nNo classes were held this month',
    );
  });

  test('only excused classes: counts shown, no percentage', () {
    final text = composeAttendanceSummary(
      l10n: en,
      studentName: 'Rahim',
      monthText: 'March 2026',
      counts: const AttendanceCounts(excused: 2),
      numerals: NumeralStyle.western,
    );
    expect(text, contains('Classes: 2'));
    expect(text, isNot(contains('rate')));
  });

  test('is signed with the tutor name when there is one', () {
    final text = composeAttendanceSummary(
      l10n: en,
      studentName: 'Rahim',
      monthText: 'March 2026',
      counts: counts,
      numerals: NumeralStyle.western,
      tutorName: '  Karim Sir ',
    );
    expect(text.endsWith('\n\n— Karim Sir'), isTrue);
  });

  test('no signature without a tutor name', () {
    final text = composeAttendanceSummary(
      l10n: en,
      studentName: 'Rahim',
      monthText: 'March 2026',
      counts: counts,
      numerals: NumeralStyle.western,
      tutorName: '   ',
    );
    expect(text.contains('—  '), isFalse);
    expect(text.split('\n').last, 'Attendance rate: 92%');
  });

  test('perfect and zero attendance', () {
    String rate(AttendanceCounts c) => composeAttendanceSummary(
      l10n: en,
      studentName: 'R',
      monthText: 'M',
      counts: c,
      numerals: NumeralStyle.western,
    ).split('\n').last;
    expect(rate(const AttendanceCounts(present: 4)), 'Attendance rate: 100%');
    expect(rate(const AttendanceCounts(absent: 4)), 'Attendance rate: 0%');
  });
}
