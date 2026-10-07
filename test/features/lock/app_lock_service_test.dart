import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/platform/secure_store.dart';
import 'package:tution_tracker/core/security/pin_hash.dart';
import 'package:tution_tracker/features/lock/data/app_lock_service.dart';

void main() {
  late MemorySecureKeyValueStore store;
  late DateTime now;
  late AppLockService service;

  setUp(() {
    store = MemorySecureKeyValueStore();
    now = DateTime(2026, 3, 15, 10);
    // Few iterations: the hash is slow on purpose, tests need not be.
    service = AppLockService(store, now: () => now, iterations: 100);
  });

  group('pin hash', () {
    test('verifies the right PIN and rejects others', () async {
      final h = await PinHash.create('1234', iterations: 100);
      expect(await h.matches('1234'), isTrue);
      expect(await h.matches('1235'), isFalse);
      expect(await h.matches(''), isFalse);
    });

    test('is salted: same PIN, different hashes', () async {
      final a = await PinHash.create('1234', iterations: 100);
      final b = await PinHash.create('1234', iterations: 100);
      expect(a.hash, isNot(b.hash));
      expect(a.salt, isNot(b.salt));
    });

    test('survives encoding and never contains the PIN', () async {
      final h = await PinHash.create('987654', iterations: 100);
      final text = h.encode();
      expect(text, isNot(contains('987654')));
      final back = PinHash.tryDecode(text)!;
      expect(back.length, 6);
      expect(await back.matches('987654'), isTrue);
    });

    test('damaged text decodes to nothing', () {
      expect(PinHash.tryDecode(null), isNull);
      expect(PinHash.tryDecode('garbage'), isNull);
      expect(PinHash.tryDecode('v1:4:100:!!:!!'), isNull);
    });
  });

  group('setting a PIN', () {
    test('accepts 4 to 8 digits only', () {
      for (final ok in ['1234', '123456', '12345678']) {
        expect(AppLockService.isValidPin(ok), isTrue, reason: ok);
      }
      for (final bad in ['', '123', '123456789', '12a4', '12 4', '১২৩৪']) {
        expect(AppLockService.isValidPin(bad), isFalse, reason: bad);
      }
      expect(() => service.enable('12'), throwsArgumentError);
    });

    test('is off until set, then on', () async {
      expect((await service.settings()).enabled, isFalse);
      await service.enable('4321');
      expect((await service.settings()).enabled, isTrue);
      expect(await service.pinLength(), 4);
    });

    test('the PIN is not stored in the clear', () async {
      await service.enable('4321');
      for (final v in store.values.values) {
        expect(v, isNot(contains('4321')));
      }
    });

    test('changing the PIN replaces the old one', () async {
      await service.enable('1111');
      await service.changePin('2222');
      expect(await service.verify('1111'), isA<PinWrong>());
      expect(await service.verify('2222'), isA<PinCorrect>());
    });

    test('disabling forgets everything', () async {
      await service.enable('1111');
      await service.setBiometric(enabled: true);
      await service.setProtectScreen(enabled: true);
      await service.disable();
      expect(store.values, isEmpty);
      expect((await service.settings()).enabled, isFalse);
    });

    test('preferences are remembered', () async {
      await service.enable('1111');
      await service.setTimeout(const Duration(minutes: 5));
      await service.setBiometric(enabled: true);
      await service.setProtectScreen(enabled: true);
      final s = await service.settings();
      expect(s.timeout, const Duration(minutes: 5));
      expect(s.biometric, isTrue);
      expect(s.protectScreen, isTrue);
    });
  });

  group('wrong tries', () {
    setUp(() => service.enable('1234'));

    test('count down, then block', () async {
      for (var left = 4; left >= 1; left--) {
        final r = await service.verify('0000');
        expect(r, isA<PinWrong>().having((w) => w.attemptsLeft, 'left', left));
      }
      final fifth = await service.verify('0000');
      expect(fifth, isA<PinBlocked>());
      expect((fifth as PinBlocked).until, now.add(AppLockService.firstWait));
    });

    test('while blocked even the right PIN is refused', () async {
      for (var i = 0; i < 5; i++) {
        await service.verify('0000');
      }
      expect(await service.verify('1234'), isA<PinBlocked>());
      now = now.add(const Duration(seconds: 29));
      expect(await service.verify('1234'), isA<PinBlocked>());
    });

    test('after the wait the right PIN works and clears the count', () async {
      for (var i = 0; i < 5; i++) {
        await service.verify('0000');
      }
      now = now.add(const Duration(seconds: 31));
      expect(await service.verify('1234'), isA<PinCorrect>());
      // Fresh start: the next wrong try has the full allowance again.
      expect(
        await service.verify('0000'),
        isA<PinWrong>().having((w) => w.attemptsLeft, 'left', 4),
      );
    });

    test('each further wrong try after a wait is punished longer', () async {
      for (var i = 0; i < 5; i++) {
        await service.verify('0000');
      }
      now = now.add(const Duration(seconds: 31));
      final sixth = await service.verify('0000') as PinBlocked;
      expect(sixth.until.difference(now), const Duration(seconds: 60));
      now = now.add(const Duration(seconds: 61));
      final seventh = await service.verify('0000') as PinBlocked;
      expect(seventh.until.difference(now), const Duration(seconds: 120));
    });

    test('the wait never exceeds 15 minutes', () async {
      for (var i = 0; i < 40; i++) {
        final b = await service.blockedUntil();
        if (b != null) now = b.add(const Duration(seconds: 1));
        await service.verify('0000');
      }
      final b = await service.blockedUntil();
      expect(b!.difference(now), lessThanOrEqualTo(AppLockService.longestWait));
    });

    test('the count survives restarting the app', () async {
      for (var i = 0; i < 3; i++) {
        await service.verify('0000');
      }
      final again = AppLockService(store, now: () => now, iterations: 100);
      expect(
        await again.verify('0000'),
        isA<PinWrong>().having((w) => w.attemptsLeft, 'left', 1),
      );
    });
  });
}
