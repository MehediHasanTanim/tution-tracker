// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tuition Khata';

  @override
  String get navHome => 'Home';

  @override
  String get navStudents => 'Students';

  @override
  String get navFees => 'Fees';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get sampleConjuncts => 'Sample text';

  @override
  String get studentsSearchHint => 'Search by name, guardian or phone';

  @override
  String get studentsClearSearch => 'Clear';

  @override
  String get studentsFilterClass => 'Class';

  @override
  String get studentsAllClasses => 'All classes';

  @override
  String get studentsFilterBatch => 'Batch';

  @override
  String get studentsAllBatches => 'All batches';

  @override
  String get statusActive => 'Active';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusArchived => 'Archived';

  @override
  String studentsCount(String count) {
    return 'Students: $count';
  }

  @override
  String get studentsEmptyTitle => 'No students yet';

  @override
  String get studentsEmptyBody => 'Add your first student';

  @override
  String get studentsNoMatch => 'No students match';

  @override
  String get studentsClearFilters => 'Clear filters';

  @override
  String get studentsAdd => 'Add student';

  @override
  String get studentProfileTitle => 'Student profile';

  @override
  String studentFeePerMonth(String amount) {
    return '$amount / month';
  }
}
