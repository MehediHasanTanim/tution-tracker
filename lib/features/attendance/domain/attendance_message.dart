import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_stats.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// The monthly attendance message a tutor sends a guardian (spec AT-10).
///
/// Written in whichever language [l10n] is, with digits as the user's numeral
/// setting says. [tutorName], when given, signs it.
String composeAttendanceSummary({
  required AppLocalizations l10n,
  required String studentName,
  required String monthText,
  required AttendanceCounts counts,
  required NumeralStyle numerals,
  String tutorName = '',
}) {
  String n(int v) => formatCount(v, numerals);

  final lines = <String>[l10n.shareAttTitle(studentName, monthText)];
  if (counts.total == 0) {
    lines.add(l10n.shareAttNone);
  } else {
    lines
      ..add(l10n.shareAttClasses(n(counts.total)))
      ..add(
        l10n.shareAttBreakdown(
          n(counts.present),
          n(counts.late),
          n(counts.absent),
          n(counts.excused),
        ),
      );
    final percent = counts.percent;
    if (percent != null) {
      lines.add(l10n.shareAttRate(applyNumerals('$percent%', numerals)));
    }
  }
  if (tutorName.trim().isNotEmpty) {
    lines
      ..add('')
      ..add(l10n.shareFooter(tutorName.trim()));
  }
  return lines.join('\n');
}
