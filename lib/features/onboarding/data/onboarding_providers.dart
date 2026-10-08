import 'package:drift/drift.dart' show StringExpressionOperators;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/onboarding/data/sample_data_service.dart';

/// Whether the first-run flow has been finished. Null until known.
final onboardingDoneProvider = StreamProvider<bool>((ref) async* {
  final store = await ref.watch(settingsStoreProvider.future);
  yield* store.watch(SettingKeys.onboardingDone);
});

final sampleDataServiceProvider = FutureProvider<SampleDataService>((
  ref,
) async {
  return SampleDataService(
    await ref.watch(databaseProvider.future),
    await ref.watch(settingsStoreProvider.future),
    now: ref.read(clockProvider),
  );
});

/// Whether sample data is currently in the database, live.
final sampleLoadedProvider = StreamProvider<bool>((ref) async* {
  final db = await ref.watch(databaseProvider.future);
  // Re-checked whenever the students table changes. The check itself runs
  // outside the watched query: that is how the report providers do it, and
  // watching the query directly stalled writes made while a screen was open.
  yield* db.customSelect('SELECT 1', readsFrom: {db.students}).watch().asyncMap(
    (_) async {
      final rows =
          await (db.select(db.students)
                ..where((t) => t.id.like(r'sample\_%', escapeChar: r'\'))
                ..limit(1))
              .get();
      return rows.isNotEmpty;
    },
  );
});
