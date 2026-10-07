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

  @override
  String get studentEditTitle => 'Edit student';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldMonthlyFee => 'Monthly fee (৳)';

  @override
  String get feeLockedHint => 'To change the fee, use fee adjustments';

  @override
  String get moreDetails => 'Add more details';

  @override
  String get fewerDetails => 'Show fewer details';

  @override
  String get fieldDueDay => 'Fee due day (day of month)';

  @override
  String get fieldClassLevel => 'Class';

  @override
  String get fieldSchool => 'School / institution';

  @override
  String get fieldGuardianName => 'Guardian name';

  @override
  String get fieldGuardianPhone => 'Guardian phone';

  @override
  String get fieldStudentPhone => 'Student phone';

  @override
  String get fieldAddress => 'Address / area';

  @override
  String get fieldSubjects => 'Subjects';

  @override
  String get fieldOtherSubject => 'Add another subject';

  @override
  String get fieldJoinedOn => 'Joining date';

  @override
  String get fieldClassDays => 'Class days';

  @override
  String get fieldClassTime => 'Class time';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get actionSave => 'Save';

  @override
  String get actionClear => 'Clear';

  @override
  String get errorNameRequired => 'Enter a name';

  @override
  String get errorFeeRequired => 'Enter the monthly fee';

  @override
  String get errorPhoneInvalid =>
      'Enter a valid mobile number (e.g. 01712345678)';

  @override
  String get studentSaved => 'Student saved';

  @override
  String get none => 'None';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabAttendance => 'Attendance';

  @override
  String get tabFees => 'Fees';

  @override
  String get tabNotes => 'Notes';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get actionCall => 'Call';

  @override
  String get actionSms => 'SMS';

  @override
  String get actionWhatsapp => 'WhatsApp';

  @override
  String get noPhoneNumber => 'No phone number';

  @override
  String get contactLaunchFailed => 'Could not open it. Is the app installed?';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionArchive => 'Archive';

  @override
  String get actionRestore => 'Restore';

  @override
  String get actionDelete => 'Delete permanently';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get deleteStudentTitle => 'Delete student?';

  @override
  String get deleteStudentBody =>
      'All of this student\'s records (fees, payments, attendance) will be erased for good. This cannot be undone. To keep the records, archive instead.';

  @override
  String get studentDeleted => 'Student deleted';

  @override
  String get studentArchived => 'Student archived';

  @override
  String get studentRestored => 'Student restored';

  @override
  String get profileMonthlyFee => 'Monthly fee';

  @override
  String get profileDueDay => 'Fee due day';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get photoChange => 'Change photo';

  @override
  String get photoTake => 'Take photo';

  @override
  String get photoChoose => 'Choose from gallery';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get photoFailed => 'Could not use that photo';
}
