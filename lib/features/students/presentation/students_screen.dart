import 'package:flutter/widgets.dart';
import 'package:tution_tracker/core/navigation/placeholder_screen.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: AppLocalizations.of(context).navStudents);
}
