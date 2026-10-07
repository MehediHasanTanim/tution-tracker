import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/settings/setting_key.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';

/// Typed view over the `settings` key/value table.
class SettingsStore {
  SettingsStore(this._db);

  final AppDatabase _db;

  /// The stored value, or the key's default when missing or unreadable.
  Future<T> get<T>(SettingKey<T> key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((t) => t.key.equals(key.name))).getSingleOrNull();
    return key.read(row?.value);
  }

  Future<void> set<T>(SettingKey<T> key, T value) async {
    key.validate?.call(value);
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key.name, value: key.encode(value)),
        );
  }

  /// Emits the current value, then again whenever it changes.
  Stream<T> watch<T>(SettingKey<T> key) {
    return (_db.select(_db.settings)..where((t) => t.key.equals(key.name)))
        .watchSingleOrNull()
        .map((row) => key.read(row?.value))
        .distinct();
  }

  /// Emits once now and again whenever any setting changes.
  Stream<void> watchAny() => _db.select(_db.settings).watch().map((_) {});

  /// Removes a stored value so the default applies again.
  Future<void> reset<T>(SettingKey<T> key) =>
      (_db.delete(_db.settings)..where((t) => t.key.equals(key.name))).go();

  /// Returns the next receipt number and advances the counter, atomically.
  /// Call inside the payment transaction so a rollback also rolls this back
  /// (design 7.4).
  Future<int> nextReceiptNumber() {
    return _db.transaction(() async {
      final current = await get(SettingKeys.nextReceiptNo);
      await set(SettingKeys.nextReceiptNo, current + 1);
      return current;
    });
  }

  /// Raises the counter to at least [minNext]; never lowers it. Used after a
  /// restore so numbering never goes backward (design 10.5).
  Future<void> ensureNextReceiptAtLeast(int minNext) {
    return _db.transaction(() async {
      final current = await get(SettingKeys.nextReceiptNo);
      if (minNext > current) await set(SettingKeys.nextReceiptNo, minNext);
    });
  }
}
