import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';

/// The messages a tutor can customise. Only fee reminders for now.
enum MessageKind {
  feeReminder('fee_reminder');

  const MessageKind(this.key);

  /// The value stored in `message_templates.kind`.
  final String key;
}

/// Placeholders a template can use, written `{name}` in the text.
enum MessageVariable {
  student,
  guardian,
  month,
  amount,
  due,
  months,
  tutor,
  institution,
  signature;

  String get token => '{$name}';
}

/// The template used until the tutor edits it (spec 3.9).
String defaultTemplate(
  MessageKind kind,
  AppLanguage language,
) => switch (language) {
  AppLanguage.bn =>
    'সম্মানিত অভিভাবক, {student}-এর {month}-এর টিউশন ফি {amount} বাকি আছে '
        '(নির্ধারিত তারিখ {due})। অনুগ্রহ করে পরিশোধ করবেন। ধন্যবাদ।\n{signature}',
  AppLanguage.en =>
    'Dear guardian, the tuition fee for {student} for {month} is still due: '
        '{amount} (due date {due}). Please pay when you can. Thank you.\n'
        '{signature}',
};

/// What a fee reminder says about one student.
class FeeReminderFacts {
  const FeeReminderFacts({
    required this.studentName,
    required this.balance,
    required this.oldestMonth,
    required this.oldestDueDate,
    this.openMonths = 1,
    this.guardianName = '',
  });

  final String studentName;
  final String guardianName;

  /// Everything the student owes, all months.
  final int balance;

  /// The earliest month with an open due, and when that was due.
  final YearMonth oldestMonth;
  final LocalDate oldestDueDate;
  final int openMonths;
}

/// The tutor's own details, for the signature.
class TutorSignature {
  const TutorSignature({this.name = '', this.institution = ''});

  final String name;
  final String institution;
}

/// Fills [body] with [facts]. Unknown `{words}` are left as typed, so a
/// typo is visible in the preview rather than silently dropped. Digits follow
/// [numerals]; `{signature}` is `— name` and vanishes when no name is set.
String renderTemplate(
  String body, {
  required FeeReminderFacts facts,
  required TutorSignature tutor,
  required AppLanguage language,
  required NumeralStyle numerals,
  required GroupingStyle grouping,
}) {
  final signature = tutor.name.trim().isEmpty ? '' : '— ${tutor.name.trim()}';
  final values = <MessageVariable, String>{
    MessageVariable.student: facts.studentName,
    MessageVariable.guardian: facts.guardianName,
    MessageVariable.month: formatMonth(
      facts.oldestMonth,
      language: language,
      numerals: numerals,
    ),
    MessageVariable.amount: formatTaka(
      Taka(facts.balance),
      numerals: numerals,
      grouping: grouping,
    ),
    MessageVariable.due: formatDate(
      facts.oldestDueDate,
      language: language,
      numerals: numerals,
    ),
    MessageVariable.months: formatCount(facts.openMonths, numerals),
    MessageVariable.tutor: tutor.name.trim(),
    MessageVariable.institution: tutor.institution.trim(),
    MessageVariable.signature: signature,
  };
  var text = body;
  for (final entry in values.entries) {
    text = text.replaceAll(entry.key.token, entry.value);
  }
  // A missing signature leaves trailing blank lines.
  return text.trim();
}
