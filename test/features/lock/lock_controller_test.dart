import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/platform/biometric_auth.dart';
import 'package:tution_tracker/core/platform/screen_security.dart';
import 'package:tution_tracker/core/platform/secure_store.dart';
import 'package:tution_tracker/features/lock/data/app_lock_service.dart';
import 'package:tution_tracker/features/lock/data/lock_controller.dart';

import '../../support/fake_notifications.dart';

void main() {
  late MemorySecureKeyValueStore store;
  late DateTime now;
  late FakeBiometric bio;
  late FakeScreenSecurity screen;

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        secureStoreProvider.overrideWithValue(store),
        clockProvider.overrideWithValue(() => now),
        appLockServiceProvider.overrideWith(
          (ref) => AppLockService(store, now: () => now, iterations: 100),
        ),
        biometricAuthProvider.overrideWithValue(bio),
        screenSecurityProvider.overrideWithValue(screen),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<LockStatus> settled(ProviderContainer c) async {
    c.read(lockControllerProvider); // starts loading
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    return c.read(lockControllerProvider);
  }

  setUp(() {
    store = MemorySecureKeyValueStore();
    now = DateTime(2026, 3, 15, 10);
    bio = FakeBiometric();
    screen = FakeScreenSecurity();
  });

  Future<AppLockService> withPin({
    Duration timeout = const Duration(minutes: 1),
  }) async {
    final s = AppLockService(store, now: () => now, iterations: 100);
    await s.enable('1234');
    await s.setTimeout(timeout);
    return s;
  }

  test('no lock set up: the app is simply open', () async {
    expect(await settled(container()), LockStatus.off);
  });

  test('a lock is engaged at start', () async {
    await withPin();
    expect(await settled(container()), LockStatus.locked);
  });

  test('the right PIN unlocks, a wrong one does not', () async {
    await withPin();
    final c = container();
    await settled(c);
    final ctl = c.read(lockControllerProvider.notifier);

    expect(await ctl.unlockWithPin('0000'), isA<PinWrong>());
    expect(c.read(lockControllerProvider), LockStatus.locked);
    expect(await ctl.unlockWithPin('1234'), isA<PinCorrect>());
    expect(c.read(lockControllerProvider), LockStatus.unlocked);
  });

  group('timeout', () {
    Future<ProviderContainer> unlocked(Duration timeout) async {
      await withPin(timeout: timeout);
      final c = container();
      await settled(c);
      await c.read(lockControllerProvider.notifier).unlockWithPin('1234');
      return c;
    }

    test('a short absence does not lock', () async {
      final c = await unlocked(const Duration(minutes: 5));
      final ctl = c.read(lockControllerProvider.notifier)..didLeave();
      now = now.add(const Duration(minutes: 4, seconds: 59));
      await ctl.didReturn();
      expect(c.read(lockControllerProvider), LockStatus.unlocked);
    });

    test('an absence of the timeout or more locks', () async {
      final c = await unlocked(const Duration(minutes: 5));
      final ctl = c.read(lockControllerProvider.notifier)..didLeave();
      now = now.add(const Duration(minutes: 5));
      await ctl.didReturn();
      expect(c.read(lockControllerProvider), LockStatus.locked);
    });

    test('"immediately" locks on any return', () async {
      final c = await unlocked(Duration.zero);
      final ctl = c.read(lockControllerProvider.notifier)..didLeave();
      await ctl.didReturn();
      expect(c.read(lockControllerProvider), LockStatus.locked);
    });

    test(
      'the extra "hidden" event on the way back does not reset the clock',
      () async {
        final c = await unlocked(const Duration(minutes: 5));
        final ctl = c.read(lockControllerProvider.notifier)
          ..didLeave(); // inactive -> hidden -> paused: first one counts
        ctl.didLeave();
        now = now.add(const Duration(minutes: 6));
        ctl.didLeave(); // paused -> hidden on the way back
        await ctl.didReturn();
        expect(c.read(lockControllerProvider), LockStatus.locked);
      },
    );

    test('returning without having left changes nothing', () async {
      final c = await unlocked(Duration.zero);
      await c.read(lockControllerProvider.notifier).didReturn();
      expect(c.read(lockControllerProvider), LockStatus.unlocked);
    });

    test('it locks again after the second absence too', () async {
      final c = await unlocked(const Duration(minutes: 1));
      final ctl = c.read(lockControllerProvider.notifier)..didLeave();
      now = now.add(const Duration(minutes: 2));
      await ctl.didReturn();
      await ctl.unlockWithPin('1234');
      ctl.didLeave();
      now = now.add(const Duration(minutes: 2));
      await ctl.didReturn();
      expect(c.read(lockControllerProvider), LockStatus.locked);
    });
  });

  group('biometric', () {
    test('unlocks when turned on and it succeeds', () async {
      final s = await withPin();
      await s.setBiometric(enabled: true);
      final c = container();
      await settled(c);
      expect(
        await c.read(lockControllerProvider.notifier).unlockWithBiometric('x'),
        isTrue,
      );
      expect(c.read(lockControllerProvider), LockStatus.unlocked);
    });

    test('is not even asked when turned off', () async {
      await withPin();
      final c = container();
      await settled(c);
      expect(
        await c.read(lockControllerProvider.notifier).unlockWithBiometric('x'),
        isFalse,
      );
      expect(bio.prompts, 0);
    });

    test('a failed or cancelled prompt leaves the app locked', () async {
      final s = await withPin();
      await s.setBiometric(enabled: true);
      bio.succeeds = false;
      final c = container();
      await settled(c);
      expect(
        await c.read(lockControllerProvider.notifier).unlockWithBiometric('x'),
        isFalse,
      );
      expect(c.read(lockControllerProvider), LockStatus.locked);
    });

    test('a phone without biometrics falls back to the PIN', () async {
      final s = await withPin();
      await s.setBiometric(enabled: true);
      bio.available = false;
      final c = container();
      await settled(c);
      expect(
        await c.read(lockControllerProvider.notifier).unlockWithBiometric('x'),
        isFalse,
      );
    });
  });

  group('screen protection', () {
    test('is applied at start when the lock and the option are on', () async {
      final s = await withPin();
      await s.setProtectScreen(enabled: true);
      await settled(container());
      expect(screen.last, isTrue);
    });

    test('is off when the lock is off', () async {
      await settled(container());
      expect(screen.last, isFalse);
    });

    test('follows a change made in Settings, without locking', () async {
      final c = container();
      await settled(c);
      final s = AppLockService(store, now: () => now, iterations: 100);
      await s.enable('1234');
      await s.setProtectScreen(enabled: true);
      await c.read(lockControllerProvider.notifier).settingsChanged();
      expect(screen.last, isTrue);
      expect(c.read(lockControllerProvider), LockStatus.unlocked);

      await s.disable();
      await c.read(lockControllerProvider.notifier).settingsChanged();
      expect(screen.last, isFalse);
      expect(c.read(lockControllerProvider), LockStatus.off);
    });
  });
}
