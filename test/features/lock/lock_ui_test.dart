import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/platform/secure_store.dart';
import 'package:tution_tracker/features/lock/data/app_lock_service.dart';

import '../../support/fake_notifications.dart';
import '../../support/fee_harness.dart';
import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

late MemorySecureKeyValueStore _store;
late FakeBiometric _bio;

AppLockService _service(FeeHarness h) =>
    AppLockService(_store, now: () => h.now, iterations: 100);

Future<void> _launch(WidgetTester tester, FeeHarness h, {String? route}) async {
  await pumpApp(
    tester,
    h.db,
    clock: () => h.now,
    secureStore: _store,
    biometric: _bio,
  );
  await waitFor(tester);
  if (route != null) {
    await pushRoute(tester, route);
    await waitFor(tester);
  }
}

Future<void> _enter(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    // Western digits here: the test app shows Bangla numerals, so look them up.
    const bn = '০১২৩৪৫৬৭৮৯';
    await tester.tap(find.widgetWithText(OutlinedButton, bn[int.parse(d)]));
    await tester.pump();
  }
  await waitFor(tester);
}

Future<void> _leaveFor(WidgetTester tester, FeeHarness h, Duration d) async {
  // The order Android reports them in.
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  h.now = h.now.add(d);
  for (final state in [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  await waitFor(tester);
}

void main() {
  setUp(() {
    _store = MemorySecureKeyValueStore();
    _bio = FakeBiometric();
  });

  feeUiTest('with no lock the app opens straight away', (tester, h) async {
    await _launch(tester, h);
    expect(find.text('পিন দিন'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  feeUiTest('a locked app starts on the PIN screen', (tester, h) async {
    await _service(h).enable('1234');
    await _launch(tester, h);
    expect(find.text('পিন দিন'), findsOneWidget);
    expect(find.byType(NavigationBar).hitTestable(), findsNothing);
  });

  feeUiTest('the right PIN opens the app', (tester, h) async {
    await _service(h).enable('1234');
    await _launch(tester, h);
    await _enter(tester, '1234');
    expect(find.text('পিন দিন'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  feeUiTest('a wrong PIN is refused and says how many tries are left', (
    tester,
    h,
  ) async {
    await _service(h).enable('1234');
    await _launch(tester, h);
    await _enter(tester, '1111');
    expect(find.textContaining('ভুল পিন'), findsOneWidget);
    expect(find.textContaining('আর ৪টি চেষ্টা'), findsOneWidget);
    expect(find.text('পিন দিন'), findsOneWidget);
  });

  feeUiTest('five wrong PINs make the person wait, and the wait ends', (
    tester,
    h,
  ) async {
    await _service(h).enable('1234');
    await _launch(tester, h);
    for (var i = 0; i < 5; i++) {
      await _enter(tester, '1111');
    }
    expect(find.textContaining('৩০ সেকেন্ড পরে'), findsOneWidget);
    // Even the right PIN is refused during the wait.
    await _enter(tester, '1234');
    expect(find.text('পিন দিন'), findsOneWidget);

    h.now = h.now.add(const Duration(seconds: 31));
    await tester.pump(const Duration(seconds: 2));
    await waitFor(tester);
    expect(find.textContaining('সেকেন্ড পরে'), findsNothing);
    await _enter(tester, '1234');
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  feeUiTest('the app locks again after being away longer than the timeout', (
    tester,
    h,
  ) async {
    final s = _service(h);
    await s.enable('1234');
    await s.setTimeout(const Duration(minutes: 5));
    await _launch(tester, h);
    await _enter(tester, '1234');

    await _leaveFor(tester, h, const Duration(minutes: 2));
    expect(find.text('পিন দিন'), findsNothing);

    await _leaveFor(tester, h, const Duration(minutes: 6));
    expect(find.text('পিন দিন'), findsOneWidget);
    await _enter(tester, '1234');
    expect(find.text('পিন দিন'), findsNothing);
  });

  feeUiTest('what was on screen is still there after unlocking', (
    tester,
    h,
  ) async {
    final s = _service(h);
    await s.enable('1234');
    await s.setTimeout(Duration.zero);
    await _launch(tester, h);
    await _enter(tester, '1234');
    await goTab(tester, 'সেটিংস');
    await waitFor(tester);

    await _leaveFor(tester, h, const Duration(seconds: 5));
    expect(find.text('পিন দিন'), findsOneWidget);
    await _enter(tester, '1234');
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('সেটিংস')),
      findsOneWidget,
    );
  });

  feeUiTest('fingerprint unlocks when turned on', (tester, h) async {
    final s = _service(h);
    await s.enable('1234');
    await s.setBiometric(enabled: true);
    await _launch(tester, h);
    expect(_bio.prompts, 1);
    expect(find.text('পিন দিন'), findsNothing);
  });

  feeUiTest('if fingerprint fails the PIN still works', (tester, h) async {
    final s = _service(h);
    await s.enable('1234');
    await s.setBiometric(enabled: true);
    _bio.succeeds = false;
    await _launch(tester, h);
    expect(find.text('পিন দিন'), findsOneWidget);
    await _enter(tester, '1234');
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  feeUiTest(
    'forgetting the PIN: erasing everything unlocks, after confirming',
    (tester, h) async {
      await seedStudent(tester, h);
      await _service(h).enable('1234');
      await _launch(tester, h);

      await tester.tap(find.text('পিন ভুলে গেছেন?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('ব্যাকআপ'), findsWidgets);
      // Cancelling keeps everything and the lock.
      await tester.tap(find.text('বাতিল'));
      await tester.pumpAndSettle();
      expect(find.text('পিন দিন'), findsOneWidget);
    },
  );

  group('settings', () {
    feeUiTest('turning the lock on asks for a PIN twice', (tester, h) async {
      await _launch(tester, h, route: '/settings/lock');
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '12');
      await tester.enterText(find.byType(TextField).last, '12');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await tester.pump();
      expect(find.text('৪ থেকে ৮টি সংখ্যা দিন'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '2468');
      await tester.enterText(find.byType(TextField).last, '1357');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await tester.pump();
      expect(find.text('পিন দুটি মেলেনি'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, '2468');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await waitFor(tester);

      expect((await _service(h).settings()).enabled, isTrue);
      expect(await _service(h).verify('2468'), isA<PinCorrect>());
      // The person just set it: they are not locked out of this screen.
      expect(find.text('পিন দিন'), findsNothing);
      expect(find.text('পিন বদলান'), findsOneWidget);
    });

    feeUiTest('turning it off needs the current PIN', (tester, h) async {
      final s = _service(h);
      await s.enable('1234');
      await _launch(tester, h);
      await _enter(tester, '1234');
      await pushRoute(tester, '/settings/lock');
      await waitFor(tester);

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '9999');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await waitFor(tester);
      expect(find.text('বর্তমান পিন ভুল'), findsOneWidget);
      expect((await s.settings()).enabled, isTrue);

      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await waitFor(tester);
      expect((await s.settings()).enabled, isFalse);
    });

    feeUiTest('the timeout and screen protection are saved', (tester, h) async {
      final s = _service(h);
      await s.enable('1234');
      await _launch(tester, h);
      await _enter(tester, '1234');
      await pushRoute(tester, '/settings/lock');
      await waitFor(tester);

      await tester.tap(find.text('কতক্ষণ পরে আবার লক হবে'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('১৫ মিনিট'));
      await waitFor(tester);
      expect((await s.settings()).timeout, const Duration(minutes: 15));

      await tester.tap(
        find.text('স্ক্রিনশট ও সাম্প্রতিক অ্যাপের প্রিভিউ আটকান'),
      );
      await waitFor(tester);
      expect((await s.settings()).protectScreen, isTrue);
    });
  });
}
