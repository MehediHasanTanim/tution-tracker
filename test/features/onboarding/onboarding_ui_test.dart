import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/onboarding/presentation/onboarding_screen.dart';

import '../../support/fee_harness.dart';
import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

Future<void> _launch(WidgetTester tester, FeeHarness h) async {
  await pumpApp(tester, h.db, clock: () => h.now, onboardingDone: null);
  await waitFor(tester);
}

Future<int> _count(WidgetTester tester, FeeHarness h, String table) async {
  final row = await real(
    tester,
    () => h.db.customSelect('SELECT COUNT(*) c FROM $table').getSingle(),
  );
  return row.read<int>('c');
}

void main() {
  feeUiTest('a fresh install starts with the welcome and language choice', (
    tester,
    h,
  ) async {
    await _launch(tester, h);
    expect(find.text('টিউশন খাতায় স্বাগতম'), findsOneWidget);
    expect(find.text('আপনার ভাষা বেছে নিন'), findsOneWidget);
    // The app underneath cannot be reached.
    expect(find.byType(NavigationBar).hitTestable(), findsNothing);
  });

  feeUiTest('choosing English changes the next screens at once', (
    tester,
    h,
  ) async {
    await _launch(tester, h);
    await tester.tap(find.text('English'));
    await waitFor(tester);
    expect(find.text('Welcome to Tuition Khata'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(OnboardingScreen),
        matching: find.text('Students'),
      ),
      findsOneWidget,
    );
  });

  feeUiTest('three taps get a tutor from install to an empty Home', (
    tester,
    h,
  ) async {
    await _launch(tester, h);
    await tester.tap(find.text('পরের ধাপ')); // 1: language -> intro
    await tester.pumpAndSettle();
    await tester.tap(find.text('এড়িয়ে যান')); // 2: skip the intros
    await tester.pumpAndSettle();
    expect(find.text('নমুনা তথ্য দিয়ে দেখবেন?'), findsOneWidget);
    await tester.tap(find.text('খালি অ্যাপ দিয়ে শুরু করুন')); // 3
    await waitFor(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('এই দিনে কোনো ক্লাস নেই'), findsOneWidget);
    expect(await _count(tester, h, 'students'), 0);
    expect(
      await real(tester, () => h.settings.get(SettingKeys.onboardingDone)),
      isTrue,
    );
  });

  feeUiTest('the intro screens can be walked through one by one', (
    tester,
    h,
  ) async {
    await _launch(tester, h);
    for (final title in ['শিক্ষার্থী', 'হাজিরা', 'ফি ও রসিদ']) {
      await tester.tap(find.text('পরের ধাপ'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(OnboardingScreen),
          matching: find.text(title),
        ),
        findsOneWidget,
      );
    }
    await tester.tap(find.text('পরের ধাপ'));
    await tester.pumpAndSettle();
    expect(find.text('নমুনা তথ্য দিয়ে দেখবেন?'), findsOneWidget);
  });

  feeUiTest('sample data can be loaded and then removed in one tap', (
    tester,
    h,
  ) async {
    await _launch(tester, h);
    await tester.tap(find.text('পরের ধাপ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('এড়িয়ে যান'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('নমুনা তথ্য যোগ করুন'));
    // Loading takes real time (a database and many writes).
    for (
      var i = 0;
      i < 60 && find.byType(NavigationBar).evaluate().isEmpty;
      i++
    ) {
      await settle(tester);
    }
    await waitFor(tester);

    expect(await _count(tester, h, 'students'), 6);
    expect(find.text('আপনি নমুনা তথ্য দেখছেন'), findsOneWidget);

    await tester.tap(find.text('নমুনা মুছুন'));
    await waitFor(tester);
    expect(await _count(tester, h, 'students'), 0);
    expect(await _count(tester, h, 'payments'), 0);
    expect(find.text('আপনি নমুনা তথ্য দেখছেন'), findsNothing);
  });

  feeUiTest('it is not shown again once finished', (tester, h) async {
    await real(tester, () => h.settings.set(SettingKeys.onboardingDone, true));
    await _launch(tester, h);
    expect(find.text('টিউশন খাতায় স্বাগতম'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  feeUiTest('sample data can also be added and removed from Settings', (
    tester,
    h,
  ) async {
    await real(tester, () => h.settings.set(SettingKeys.onboardingDone, true));
    await _launch(tester, h);
    await goTab(tester, 'সেটিংস');
    await waitFor(tester);

    await tapCentered(tester, find.text('নমুনা তথ্য যোগ করুন'));
    for (
      var i = 0;
      i < 60 && find.text('নমুনা মুছুন').evaluate().isEmpty;
      i++
    ) {
      await settle(tester);
    }
    await waitFor(tester);
    expect(await _count(tester, h, 'students'), 6);

    await tapCentered(tester, find.text('নমুনা মুছুন'));
    await waitFor(tester);
    expect(await _count(tester, h, 'students'), 0);
  });
}
