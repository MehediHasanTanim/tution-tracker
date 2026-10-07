import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/platform/biometric_auth.dart';
import 'package:tution_tracker/core/platform/screen_security.dart';
import 'package:tution_tracker/core/platform/secure_store.dart';
import 'package:tution_tracker/features/lock/data/app_lock_service.dart';

enum LockStatus {
  /// Reading the settings; the app is covered meanwhile.
  unknown,

  /// No lock set up.
  off,
  locked,
  unlocked,
}

final appLockServiceProvider = Provider<AppLockService>(
  (ref) => AppLockService(
    ref.watch(secureStoreProvider),
    now: ref.read(clockProvider),
  ),
);

/// Decides when the app is locked: at start, and after it has been in the
/// background longer than the timeout (S5-01).
class LockController extends Notifier<LockStatus> {
  DateTime? _leftAt;

  AppLockService get _service => ref.read(appLockServiceProvider);

  @override
  LockStatus build() {
    unawaited(_load());
    return LockStatus.unknown;
  }

  Future<void> _load() async {
    final settings = await _service.settings();
    await ref
        .read(screenSecurityProvider)
        .setProtected(enabled: settings.enabled && settings.protectScreen);
    state = settings.enabled ? LockStatus.locked : LockStatus.off;
  }

  /// The app went to the background. Android reports several states on the
  /// way out and again on the way back (`hidden` comes both ways), so only the
  /// first one counts; [didReturn] clears it.
  void didLeave() => _leftAt ??= ref.read(clockProvider)();

  /// The app came back: lock if it was away for at least the timeout.
  Future<void> didReturn() async {
    final left = _leftAt;
    _leftAt = null;
    if (left == null || state != LockStatus.unlocked) return;
    final settings = await _service.settings();
    if (!settings.enabled) return;
    if (ref.read(clockProvider)().difference(left) >= settings.timeout) {
      state = LockStatus.locked;
    }
  }

  void lockNow() {
    if (state == LockStatus.unlocked) state = LockStatus.locked;
  }

  Future<PinCheck> unlockWithPin(String pin) async {
    final result = await _service.verify(pin);
    if (result is PinCorrect) state = LockStatus.unlocked;
    return result;
  }

  /// Fingerprint or face, when the person has turned it on.
  Future<bool> unlockWithBiometric(String reason) async {
    final settings = await _service.settings();
    if (!settings.biometric) return false;
    final auth = ref.read(biometricAuthProvider);
    if (!await auth.isAvailable()) return false;
    if (!await auth.authenticate(reason)) return false;
    state = LockStatus.unlocked;
    return true;
  }

  /// After the lock was set up or changed in Settings: the person has just
  /// proved they know the PIN, so do not lock them out of the screen they
  /// are on.
  Future<void> settingsChanged() async {
    final settings = await _service.settings();
    await ref
        .read(screenSecurityProvider)
        .setProtected(enabled: settings.enabled && settings.protectScreen);
    state = settings.enabled ? LockStatus.unlocked : LockStatus.off;
  }
}

final lockControllerProvider = NotifierProvider<LockController, LockStatus>(
  LockController.new,
);
