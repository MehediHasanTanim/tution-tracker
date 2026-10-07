import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';

final settingsStoreProvider = FutureProvider<SettingsStore>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return SettingsStore(db);
});
