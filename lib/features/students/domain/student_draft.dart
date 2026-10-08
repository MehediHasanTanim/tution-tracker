import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/i18n/text_normalizer.dart';
import 'package:tution_tracker/core/utils/phone.dart';

enum StudentFieldError {
  nameRequired,
  feeInvalid,
  dueDayInvalid,
  guardianPhoneInvalid,
  studentPhoneInvalid,
}

/// The editable fields of a student, before they are saved.
class StudentDraft {
  const StudentDraft({
    required this.name,
    required this.monthlyFee,
    required this.joinedOn,
    this.feeDueDay = 10,
    this.classLevel,
    this.school,
    this.guardianName,
    this.guardianPhone,
    this.studentPhone,
    this.address,
    this.photoPath,
    this.subjects = const [],
    this.classDays = const [],
    this.classTime,
    this.notes,
  });

  /// Quick-add (spec ST-2): name and fee now, everything else later.
  const StudentDraft.quick({
    required this.name,
    required this.monthlyFee,
    required this.joinedOn,
    this.feeDueDay = 10,
  }) : classLevel = null,
       school = null,
       guardianName = null,
       guardianPhone = null,
       studentPhone = null,
       address = null,
       photoPath = null,
       subjects = const [],
       classDays = const [],
       classTime = null,
       notes = null;

  final String name;
  final int monthlyFee;
  final LocalDate joinedOn;
  final int feeDueDay;
  final String? classLevel;
  final String? school;
  final String? guardianName;
  final String? guardianPhone;
  final String? studentPhone;
  final String? address;
  final String? photoPath;
  final List<String> subjects;

  /// ISO weekdays (1 = Monday .. 7 = Sunday) of this student's own classes.
  final List<int> classDays;
  final ClockTime? classTime;
  final String? notes;

  /// All problems with this draft; empty means it can be saved.
  List<StudentFieldError> validate() => [
    if (normalizeText(name).isEmpty) StudentFieldError.nameRequired,
    if (monthlyFee < 0) StudentFieldError.feeInvalid,
    if (feeDueDay < 1 || feeDueDay > 31) StudentFieldError.dueDayInvalid,
    if (!isValidOptionalPhone(guardianPhone ?? ''))
      StudentFieldError.guardianPhoneInvalid,
    if (!isValidOptionalPhone(studentPhone ?? ''))
      StudentFieldError.studentPhoneInvalid,
  ];
}

class StudentValidationException implements Exception {
  const StudentValidationException(this.errors);

  final List<StudentFieldError> errors;

  @override
  String toString() => 'StudentValidationException($errors)';
}
