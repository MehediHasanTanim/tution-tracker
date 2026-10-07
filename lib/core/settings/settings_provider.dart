import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
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
