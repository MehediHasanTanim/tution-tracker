import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/platform/battery_guide_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';

import '../../support/fake_notifications.dart';
import '../../support/fee_harness.dart';
import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

Future<void> _open(
  WidgetTester tester,
  FeeHarness h,
  FakeNotifications n, {
  FakeBatteryGuide? guide,
  String route = '/settings/reminders',
}) async {
  await pumpApp(
    tester,
    h.db,
    clock: () => h.now,
    notifications: n,
    batteryGuide: guide ?? FakeBatteryGuide(),
  );
  await pushRoute(tester, route);
  await waitFor(tester);
}

/// Taps [text], scrolling it to the middle first: the bottom bar would
/// otherwise cover it.
Future<void> _tap(WidgetTester tester, String text) async {
  final target = find.text(text);
  await tester.scrollUntilVisible(
    target,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tapCentered(tester, target);
}

Future<bool> _on(WidgetTester tester, FeeHarness h) =>
    real(tester, () => h.settings.get(SettingKeys.remindersEnabled));

void main() {
  feeUiTest('turning reminders on asks first, then the system, then guides', (
    tester,
    h,
  ) async {
    final n = FakeNotifications(permitted: false);
    await _open(tester, h, n);
    expect(find.text('বন্ধ আছে'), findsOneWidget); // health: off

    await tester.tap(find.byType(Switch).first);
    await waitFor(tester);
    // The rationale comes before any system prompt.
    expect(find.text('রিমাইন্ডার চালু করুন'), findsOneWidget);
    expect(n.permissionRequests, 0);

    await tester.tap(find.text('অনুমতি দিন'));
    await waitFor(tester);
    expect(n.permissionRequests, 1);
    expect(await _on(tester, h), isTrue);
    // First time on: the battery guide follows.
    expect(find.text('ব্যাটারি সেটিংস'), findsWidgets);
    expect(find.textContaining('অটোস্টার্ট'), findsOneWidget);

    await _tap(tester, 'বুঝেছি');
    await waitFor(tester);
    expect(find.text('রিমাইন্ডার'), findsWidgets);
    final shown = await real(
      tester,
      () => h.settings.get(SettingKeys.oemGuideShown),
    );
    expect(shown, isTrue);
  });

  feeUiTest('a refusal is explained and offers the phone settings', (
    tester,
    h,
  ) async {
    final n = FakeNotifications(permitted: false, grants: false);
    await _open(tester, h, n);
    await tester.tap(find.byType(Switch).first);
    await waitFor(tester);
    await tester.tap(find.text('অনুমতি দিন'));
    await waitFor(tester);

    expect(
      find.textContaining('নোটিফিকেশনের অনুমতি দেওয়া হয়নি'),
      findsOneWidget,
    );
    expect(await _on(tester, h), isFalse);

    await tester.tap(find.text('সেটিংস খুলুন'));
    await tester.pump();
    expect(n.settingsOpened, 1);
  });

  feeUiTest('the guide is not shown again once seen', (tester, h) async {
    await real(tester, () => h.settings.set(SettingKeys.oemGuideShown, true));
    final n = FakeNotifications();
    await _open(tester, h, n);
    await tester.tap(find.byType(Switch).first);
    await waitFor(tester);

    expect(await _on(tester, h), isTrue);
    expect(find.text('বুঝেছি'), findsNothing);
    expect(find.text('রিমাইন্ডার'), findsWidgets);
  });

  feeUiTest('the guide is reachable later and opens battery settings', (
    tester,
    h,
  ) async {
    final guide = FakeBatteryGuide(PhoneMaker.samsung);
    await _open(tester, h, FakeNotifications(), guide: guide);
    await _tap(tester, 'ব্যাটারি সেটিংস');
    await waitFor(tester);

    expect(find.textContaining('কখনো ঘুমায় না এমন অ্যাপ'), findsOneWidget);
    // Another maker's steps can be picked by hand.
    await tester.tap(find.text('Vivo / iQOO'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('উচ্চ ব্যাকগ্রাউন্ড পাওয়ার ব্যবহার'),
      findsOneWidget,
    );

    await _tap(tester, 'ব্যাটারি সেটিংস খুলুন');
    await tester.pump();
    expect(guide.opened, [PhoneMaker.vivo]);
  });

  feeUiTest('the health row reflects blocked notifications and counts', (
    tester,
    h,
  ) async {
    await real(
      tester,
      () => h.settings.set(SettingKeys.remindersEnabled, true),
    );
    final n = FakeNotifications(permitted: false);
    await _open(tester, h, n);
    expect(find.text('নোটিফিকেশন বন্ধ করা আছে'), findsOneWidget);
  });

  feeUiTest('the test notification is sent from Settings', (tester, h) async {
    await real(
      tester,
      () => h.settings.set(SettingKeys.remindersEnabled, true),
    );
    final n = FakeNotifications();
    await _open(tester, h, n);
    await _tap(tester, 'পরীক্ষামূলক নোটিফিকেশন পাঠান');
    await waitFor(tester);
    expect(n.shown, hasLength(1));
  });

  group('notification taps', () {
    Future<String> seedClass(WidgetTester tester, FeeHarness h) =>
        real(tester, () async {
          final b = await h.batches.create(
            const BatchDraft(
              name: 'Math 9',
              scheduleDays: [7],
              startTime: ClockTime(17, 0),
            ),
          );
          return b.id;
        });

    feeUiTest('tapping a class reminder opens that attendance sheet', (
      tester,
      h,
    ) async {
      final id = await seedClass(tester, h);
      final n = FakeNotifications();
      await _open(tester, h, n, route: '/home');

      n.tapController.add(
        '/attendance?kind=batch&id=$id&date=2026-03-15&time=17%3A00',
      );
      await waitFor(tester);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.text('Math 9'), findsWidgets);

      // Back lands on Today, not outside the app.
      await tester.tap(find.byType(BackButton));
      await waitFor(tester);
      expect(find.text('নেওয়া হয়নি'), findsOneWidget);
    });

    feeUiTest('a notification that launched the app is opened at start', (
      tester,
      h,
    ) async {
      final id = await seedClass(tester, h);
      final n = FakeNotifications()
        ..launchPayload =
            '/attendance?kind=batch&id=$id&date=2026-03-15&time=17%3A00';
      await pumpApp(tester, h.db, clock: () => h.now, notifications: n);
      await waitFor(tester);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.text('Math 9'), findsWidgets);
    });

    feeUiTest('a fee reminder opens the Fees tab', (tester, h) async {
      final n = FakeNotifications();
      await _open(tester, h, n, route: '/home');
      n.tapController.add('/fees');
      await waitFor(tester);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('ফি')),
        findsOneWidget,
      );
    });
  });
}
