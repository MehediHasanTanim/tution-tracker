import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';

final studentRepositoryProvider = FutureProvider<StudentRepository>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  return StudentRepository(
    db,
    now: ref.read(clockProvider),
    // New, edited and restored students get their dues straight away.
    onStudentChanged: (id) async {
      final dues = await ref.read(dueServiceProvider.future);
      await dues.generateForStudent(id);
    },
  );
});
