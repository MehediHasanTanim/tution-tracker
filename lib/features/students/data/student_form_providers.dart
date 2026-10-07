import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/students/data/student_providers.dart';

/// The student being edited, or null when the id is unknown.
final studentByIdProvider = FutureProvider.autoDispose.family<Student?, String>(
  (ref, id) async {
    final repo = await ref.watch(studentRepositoryProvider.future);
    return repo.getById(id);
  },
);

/// The default fee due day from settings (spec SE-5).
final defaultDueDayProvider = FutureProvider.autoDispose<int>((ref) async {
  final store = await ref.watch(settingsStoreProvider.future);
  return store.get(SettingKeys.defaultDueDay);
});

/// A student that updates live as it is edited, archived or restored.
final studentStreamProvider = StreamProvider.autoDispose
    .family<Student?, String>((ref, id) async* {
      final repo = await ref.watch(studentRepositoryProvider.future);
      yield* repo.watchById(id);
    });
