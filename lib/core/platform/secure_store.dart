import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small secrets (the PIN hash and lock preferences) in the Android Keystore,
/// kept apart from the database on purpose: restoring a backup or deleting all
/// data must never change what unlocks the app. Wrapped so logic and tests do
/// not need the plugin.
abstract interface class SecureKeyValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class PluginSecureKeyValueStore implements SecureKeyValueStore {
  const PluginSecureKeyValueStore();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// For tests and platforms without a keystore.
class MemorySecureKeyValueStore implements SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

final secureStoreProvider = Provider<SecureKeyValueStore>(
  (ref) => const PluginSecureKeyValueStore(),
);
