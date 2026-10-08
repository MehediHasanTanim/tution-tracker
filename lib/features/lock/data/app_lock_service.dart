import 'package:tution_tracker/core/platform/secure_store.dart';
import 'package:tution_tracker/core/security/pin_hash.dart';

/// What the lock is set to. Lives in the secure store, not the database, so a
/// restored backup or "delete all data" cannot change what unlocks the app.
class LockSettings {
  const LockSettings({
    this.enabled = false,
    this.timeout = const Duration(minutes: 1),
    this.biometric = false,
    this.protectScreen = false,
  });

  final bool enabled;

  /// How long the app may be in the background before it locks again.
  /// [Duration.zero] locks as soon as the app is left.
  final Duration timeout;
  final bool biometric;

  /// Blocks screenshots and the recent-apps preview.
  final bool protectScreen;

  LockSettings copyWith({
    bool? enabled,
    Duration? timeout,
    bool? biometric,
    bool? protectScreen,
  }) => LockSettings(
    enabled: enabled ?? this.enabled,
    timeout: timeout ?? this.timeout,
    biometric: biometric ?? this.biometric,
    protectScreen: protectScreen ?? this.protectScreen,
  );
}

/// The result of checking a PIN.
sealed class PinCheck {
  const PinCheck();
}

class PinCorrect extends PinCheck {
  const PinCorrect();
}

/// Wrong. [attemptsLeft] tries remain before a waiting period starts.
class PinWrong extends PinCheck {
  const PinWrong(this.attemptsLeft);

  final int attemptsLeft;
}

/// Too many wrong tries: nothing is checked until [until].
class PinBlocked extends PinCheck {
  const PinBlocked(this.until);

  final DateTime until;
}

/// Sets, checks and clears the app-lock PIN.
///
/// Wrong tries are counted and persisted (so restarting the app does not reset
/// them). After [freeAttempts] in a row the app makes the person wait, longer
/// each time, which makes guessing a short PIN impractical.
class AppLockService {
  AppLockService(
    this._store, {
    DateTime Function()? now,
    this.iterations = PinHash.defaultIterations,
  }) : _now = now ?? DateTime.now;

  final SecureKeyValueStore _store;
  final DateTime Function() _now;
  final int iterations;

  static const freeAttempts = 5;
  static const firstWait = Duration(seconds: 30);
  static const longestWait = Duration(minutes: 15);

  static const minPinLength = 4;
  static const maxPinLength = 8;

  static const _kPin = 'lock_pin';
  static const _kEnabled = 'lock_enabled';
  static const _kTimeout = 'lock_timeout_s';
  static const _kBiometric = 'lock_biometric';
  static const _kProtect = 'lock_protect_screen';
  static const _kFailed = 'lock_failed';
  static const _kBlockedUntil = 'lock_blocked_until';

  /// True for 4 to 8 digits.
  static bool isValidPin(String pin) =>
      pin.length >= minPinLength &&
      pin.length <= maxPinLength &&
      RegExp(r'^[0-9]+$').hasMatch(pin);

  Future<LockSettings> settings() async {
    final timeout = int.tryParse(await _store.read(_kTimeout) ?? '');
    return LockSettings(
      enabled: await _store.read(_kEnabled) == '1' && await hasPin(),
      timeout: timeout == null
          ? const Duration(minutes: 1)
          : Duration(seconds: timeout),
      biometric: await _store.read(_kBiometric) == '1',
      protectScreen: await _store.read(_kProtect) == '1',
    );
  }

  Future<bool> hasPin() async =>
      PinHash.tryDecode(await _store.read(_kPin)) != null;

  /// How many digits the PIN has, so the lock screen knows when to check.
  Future<int?> pinLength() async =>
      PinHash.tryDecode(await _store.read(_kPin))?.length;

  /// Turns the lock on with [pin]. Throws [ArgumentError] for a bad PIN.
  Future<void> enable(String pin) async {
    if (!isValidPin(pin)) {
      throw ArgumentError.value(pin, 'pin', 'not 4-8 digits');
    }
    final hash = await PinHash.create(pin, iterations: iterations);
    await _store.write(_kPin, hash.encode());
    await _store.write(_kEnabled, '1');
    await _clearFailures();
  }

  /// Changes the PIN without turning the lock off.
  Future<void> changePin(String pin) => enable(pin);

  /// Turns the lock off and forgets everything about it.
  Future<void> disable() async {
    for (final k in [
      _kPin,
      _kEnabled,
      _kTimeout,
      _kBiometric,
      _kProtect,
      _kFailed,
      _kBlockedUntil,
    ]) {
      await _store.delete(k);
    }
  }

  Future<void> setTimeout(Duration d) =>
      _store.write(_kTimeout, d.inSeconds.toString());

  Future<void> setBiometric({required bool enabled}) =>
      _store.write(_kBiometric, enabled ? '1' : '0');

  Future<void> setProtectScreen({required bool enabled}) =>
      _store.write(_kProtect, enabled ? '1' : '0');

  /// When the next try is allowed, or null if one is allowed now.
  Future<DateTime?> blockedUntil() async {
    final ms = int.tryParse(await _store.read(_kBlockedUntil) ?? '');
    if (ms == null) return null;
    final until = DateTime.fromMillisecondsSinceEpoch(ms);
    return until.isAfter(_now()) ? until : null;
  }

  Future<PinCheck> verify(String pin) async {
    final blocked = await blockedUntil();
    if (blocked != null) return PinBlocked(blocked);

    final hash = PinHash.tryDecode(await _store.read(_kPin));
    if (hash == null) return const PinCorrect(); // no PIN: nothing to guard
    if (await hash.matches(pin)) {
      await _clearFailures();
      return const PinCorrect();
    }

    final failed = (int.tryParse(await _store.read(_kFailed) ?? '') ?? 0) + 1;
    await _store.write(_kFailed, '$failed');
    if (failed >= freeAttempts) {
      final steps = failed - freeAttempts;
      var wait = firstWait * (1 << (steps > 5 ? 5 : steps));
      if (wait > longestWait) {
        wait = longestWait;
      }
      final until = _now().add(wait);
      await _store.write(
        _kBlockedUntil,
        until.millisecondsSinceEpoch.toString(),
      );
      return PinBlocked(until);
    }
    return PinWrong(freeAttempts - failed);
  }

  Future<void> _clearFailures() async {
    await _store.delete(_kFailed);
    await _store.delete(_kBlockedUntil);
  }
}
