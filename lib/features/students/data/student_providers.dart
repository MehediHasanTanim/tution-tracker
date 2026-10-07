import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';

final studentRepositoryProvider = FutureProvider<StudentRepository>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  return StudentRepository(db);
});
