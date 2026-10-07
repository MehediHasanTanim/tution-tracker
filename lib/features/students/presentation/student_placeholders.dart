import 'package:flutter/widgets.dart';
import 'package:tution_tracker/core/navigation/placeholder_screen.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Replaced by the add/edit form in S1-11.
class StudentFormPlaceholder extends StatelessWidget {
  const StudentFormPlaceholder({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: AppLocalizations.of(context).studentsAdd);
}

/// Replaced by the profile screen in S1-12.
class StudentProfilePlaceholder extends StatelessWidget {
  const StudentProfilePlaceholder({required this.studentId, super.key});

  final String studentId;

  @override
  Widget build(BuildContext context) => PlaceholderScreen(
    title: AppLocalizations.of(context).studentProfileTitle,
  );
}
