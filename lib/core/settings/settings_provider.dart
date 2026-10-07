import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/settings/setting_key.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';

final settingsStoreProvider = FutureProvider<SettingsStore>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return SettingsStore(db);
});

/// The tutor's profile, live. Empty strings until the tutor fills it in.
class TutorProfile {
  const TutorProfile({this.name = '', this.institution = '', this.phone = ''});

  final String name;
  final String institution;
  final String phone;

  /// What to put at the top of a receipt: the institution, else the tutor.
  String get title => institution.isNotEmpty ? institution : name;
}

final tutorProfileProvider = StreamProvider<TutorProfile>((ref) async* {
  final store = await ref.watch(settingsStoreProvider.future);
  // Any of the three changing re-reads all three.
  await for (final _ in store.watchAny()) {
    yield TutorProfile(
      name: await store.get(SettingKeys.tutorName),
      institution: await store.get(SettingKeys.institutionName),
      phone: await store.get(SettingKeys.tutorPhone),
    );
  }
});

/// Any setting, live. Key instances come from `SettingKeys`, so the family
/// shares one stream per setting.
final settingValueProvider = StreamProvider.autoDispose
    .family<Object?, SettingKey<Object?>>((ref, key) async* {
      final store = await ref.watch(settingsStoreProvider.future);
      yield* store.watch(key);
    });

/// Changes a setting. The write goes through the same store the rest of the
/// app reads, so every watcher updates at once.
Future<void> writeSetting<T>(WidgetRef ref, SettingKey<T> key, T value) async {
  final store = await ref.read(settingsStoreProvider.future);
  await store.set(key, value);
}

extension WatchSetting on WidgetRef {
  /// The setting's current value, or its default until it has loaded.
  T watchSetting<T>(SettingKey<T> key) =>
      (watch(settingValueProvider(key)).value as T?) ?? key.defaultValue;
}
