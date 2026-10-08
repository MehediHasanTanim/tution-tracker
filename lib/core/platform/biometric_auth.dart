import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Fingerprint or face unlock, wrapped so screens and tests do not need the
/// plugin. It only ever adds convenience on top of the PIN, never replaces it.
abstract interface class BiometricAuth {
  /// Whether this phone has biometrics set up that the app can use.
  Future<bool> isAvailable();

  /// Asks the system to verify the user. False for a failure or cancel.
  Future<bool> authenticate(String reason);
}

class PluginBiometricAuth implements BiometricAuth {
  const PluginBiometricAuth();

  static final _auth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } on Object {
      return false;
    }
  }
}

final biometricAuthProvider = Provider<BiometricAuth>(
  (ref) => const PluginBiometricAuth(),
);
