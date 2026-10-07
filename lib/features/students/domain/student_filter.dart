import 'package:tution_tracker/features/students/domain/student_status.dart';

/// What the student list shows. By default archived ([StudentStatus.left])
/// students are hidden.
class StudentFilter {
  const StudentFilter({
    this.query = '',
    this.statuses = const {StudentStatus.active, StudentStatus.paused},
    this.classLevel,
    this.batchId,
  });

  /// Free text matched against name, guardian, school and phone numbers.
  final String query;
  final Set<StudentStatus> statuses;
  final String? classLevel;

  /// Only students currently in this batch (not left it).
  final String? batchId;

  StudentFilter copyWith({
    String? query,
    Set<StudentStatus>? statuses,
    String? Function()? classLevel,
    String? Function()? batchId,
  }) => StudentFilter(
    query: query ?? this.query,
    statuses: statuses ?? this.statuses,
    classLevel: classLevel != null ? classLevel() : this.classLevel,
    batchId: batchId != null ? batchId() : this.batchId,
  );
}
