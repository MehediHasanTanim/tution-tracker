import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/features/batches/data/batch_repository.dart';
import 'package:tution_tracker/features/students/data/student_providers.dart';
import 'package:tution_tracker/features/students/domain/student_filter.dart';

final batchRepositoryProvider = FutureProvider<BatchRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return BatchRepository(db);
});

/// Whether the batch list also shows archived batches.
class ShowArchivedBatches extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final showArchivedBatchesProvider = NotifierProvider<ShowArchivedBatches, bool>(
  ShowArchivedBatches.new,
);

final batchSummariesProvider = StreamProvider.autoDispose<List<BatchSummary>>((
  ref,
) async* {
  final includeArchived = ref.watch(showArchivedBatchesProvider);
  final repo = await ref.watch(batchRepositoryProvider.future);
  yield* repo.watchSummaries(includeArchived: includeArchived);
});

final batchStreamProvider = StreamProvider.autoDispose.family<Batch?, String>((
  ref,
  id,
) async* {
  final repo = await ref.watch(batchRepositoryProvider.future);
  yield* repo.watchById(id);
});

final batchMembersProvider = StreamProvider.autoDispose
    .family<List<BatchMemberView>, String>((ref, batchId) async* {
      final repo = await ref.watch(batchRepositoryProvider.future);
      yield* repo.watchMembers(batchId);
    });

final batchesOfStudentProvider = StreamProvider.autoDispose
    .family<List<Batch>, String>((ref, studentId) async* {
      final repo = await ref.watch(batchRepositoryProvider.future);
      yield* repo.watchBatchesOfStudent(studentId);
    });

/// Students that can still be added to [batchId]: not left, not already in
/// it, and matching [query].
final addableStudentsProvider = StreamProvider.autoDispose
    .family<List<Student>, ({String batchId, String query})>((ref, key) async* {
      final members = await ref.watch(batchMembersProvider(key.batchId).future);
      final repo = await ref.watch(studentRepositoryProvider.future);
      final inBatch = {for (final m in members) m.student.id};
      yield* repo
          .watch(StudentFilter(query: key.query))
          .map(
            (all) => [
              for (final s in all)
                if (!inBatch.contains(s.id)) s,
            ],
          );
    });
