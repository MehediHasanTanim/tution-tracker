import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/students/data/student_providers.dart';
import 'package:tution_tracker/features/students/domain/student_filter.dart';
import 'package:tution_tracker/features/students/domain/student_status.dart';

class StudentFilterNotifier extends Notifier<StudentFilter> {
  @override
  StudentFilter build() => const StudentFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  /// Adds or removes [status]; at least one status always stays selected.
  void toggleStatus(StudentStatus status) {
    final next = {...state.statuses};
    if (!next.remove(status)) next.add(status);
    if (next.isEmpty) return;
    state = state.copyWith(statuses: next);
  }

  void setClassLevel(String? level) =>
      state = state.copyWith(classLevel: () => level);

  void setBatch(String? batchId) =>
      state = state.copyWith(batchId: () => batchId);

  void clear() => state = const StudentFilter();
}

final studentFilterProvider =
    NotifierProvider<StudentFilterNotifier, StudentFilter>(
      StudentFilterNotifier.new,
    );

/// True when the filter differs from the default view.
final studentFilterActiveProvider = Provider<bool>((ref) {
  final f = ref.watch(studentFilterProvider);
  const base = StudentFilter();
  return f.query.trim().isNotEmpty ||
      f.classLevel != null ||
      f.batchId != null ||
      f.statuses.length != base.statuses.length ||
      !f.statuses.containsAll(base.statuses);
});

final studentListProvider = StreamProvider.autoDispose<List<Student>>((
  ref,
) async* {
  final filter = ref.watch(studentFilterProvider);
  final repo = await ref.watch(studentRepositoryProvider.future);
  yield* repo.watch(filter);
});

final classLevelsProvider = StreamProvider.autoDispose<List<String>>((
  ref,
) async* {
  final repo = await ref.watch(studentRepositoryProvider.future);
  yield* repo.watchClassLevels();
});

typedef BatchOption = ({String id, String name});

/// Active batches for the filter picker. Moves into the batch repository
/// with S1-14.
final batchOptionsProvider = StreamProvider.autoDispose<List<BatchOption>>((
  ref,
) async* {
  final db = await ref.watch(databaseProvider.future);
  final query = db.select(db.batches)
    ..where((b) => b.status.equals('active'))
    ..orderBy([(b) => OrderingTerm.asc(b.name.collate(Collate.noCase))]);
  yield* query.watch().map(
    (rows) => [for (final b in rows) (id: b.id, name: b.name)],
  );
});

final numeralStyleProvider = StreamProvider<NumeralStyle>((ref) async* {
  final store = await ref.watch(settingsStoreProvider.future);
  yield* store.watch(SettingKeys.numerals);
});

final groupingStyleProvider = StreamProvider<GroupingStyle>((ref) async* {
  final store = await ref.watch(settingsStoreProvider.future);
  yield* store.watch(SettingKeys.grouping);
});
