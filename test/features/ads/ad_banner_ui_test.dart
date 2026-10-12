import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/platform/secure_store.dart';
import 'package:tution_tracker/features/ads/data/ad_providers.dart';
import 'package:tution_tracker/features/lock/data/app_lock_service.dart';
import 'package:tution_tracker/router.dart';

import '../../support/fake_ads.dart';
import '../../support/fee_harness.dart';
import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

Future<void> _launch(
  WidgetTester tester,
  FeeHarness h,
  FakeAdService ads, {
  MemorySecureKeyValueStore? store,
}) async {
  await pumpApp(
    tester,
    h.db,
    clock: () => h.now,
    secureStore: store,
    overrides: adsOn(ads),
  );
  await waitFor(tester);
  await tester.pump(const Duration(milliseconds: 300));
}

final _banner = find.byKey(const Key('fake-banner'));

void main() {
  feeUiTest('a banner shows above the tabs on a browsing screen', (
    tester,
    h,
  ) async {
    final ads = FakeAdService();
    await _launch(tester, h, ads);

    expect(_banner, findsOneWidget);
    expect(ads.starts, 1);
    // It sits directly above the navigation bar, not over the content.
    expect(
      tester.getBottomLeft(_banner).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.byType(NavigationBar)).dy),
    );
    // Sized to the screen width.
    expect(ads.widths.single, tester.view.physicalSize.width ~/ 3);
  });

  feeUiTest('moving between tabs keeps the banner', (tester, h) async {
    final ads = FakeAdService();
    await _launch(tester, h, ads);
    await goTab(tester, 'ফি');
    await tester.pump(const Duration(milliseconds: 300));
    expect(_banner, findsOneWidget);
    await goTab(tester, 'রিপোর্ট');
    await tester.pump(const Duration(milliseconds: 300));
    expect(_banner, findsOneWidget);
  });

  for (final route in [
    '/settings/backup',
    '/settings/lock',
    '/settings/templates',
    '/fees/pay/STUDENT',
    '/students/new',
  ]) {
    feeUiTest('no banner on $route', (tester, h) async {
      final ads = FakeAdService();
      final student = await seedStudent(tester, h);
      await _launch(tester, h, ads);
      await pushRoute(tester, route.replaceAll('STUDENT', student.id));
      await waitFor(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_banner, findsNothing);

      // And it is back on the screen underneath.
      ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
          .read(routerProvider)
          .pop();
      await waitFor(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_banner, findsOneWidget);
    });
  }

  feeUiTest('leaving a screen without ads disposes nothing it should keep', (
    tester,
    h,
  ) async {
    final ads = FakeAdService();
    await _launch(tester, h, ads);
    await pushRoute(tester, '/settings/backup');
    await waitFor(tester);
    // The banner was dropped while the screen was up, and freed.
    expect(ads.bannersDisposed, greaterThanOrEqualTo(1));
  });

  feeUiTest('no ad available: no gap, and it tries again later', (
    tester,
    h,
  ) async {
    final ads = FakeAdService(fill: false);
    await _launch(tester, h, ads);

    expect(_banner, findsNothing);
    expect(ads.bannerRequests, 1);
    // The tab bar sits at the very bottom, exactly as without ads.
    expect(
      tester.getBottomLeft(find.byType(NavigationBar)).dy,
      tester.view.physicalSize.height / tester.view.devicePixelRatio,
    );

    // Back online later: the next try (after 30 s) finds an ad.
    ads.fill = true;
    await tester.pump(const Duration(seconds: 31));
    await waitFor(tester);
    expect(ads.bannerRequests, 2);
    expect(_banner, findsOneWidget);
  });

  feeUiTest('without consent nothing is requested', (tester, h) async {
    final ads = FakeAdService(consentOk: false);
    await _launch(tester, h, ads);
    expect(_banner, findsNothing);
    expect(ads.bannerRequests, 0);
  });

  feeUiTest('with ads off the service is never touched', (tester, h) async {
    final ads = FakeAdService();
    await pumpApp(tester, h.db, clock: () => h.now);
    await waitFor(tester);
    expect(_banner, findsNothing);
    expect(ads.starts, 0);
    expect(ads.bannerRequests, 0);
  });

  feeUiTest('the banner is not requested while the app is locked', (
    tester,
    h,
  ) async {
    final store = MemorySecureKeyValueStore();
    await real(
      tester,
      () => AppLockService(
        store,
        now: () => h.now,
        iterations: 100,
      ).enable('123456'),
    );
    final ads = FakeAdService();
    await _launch(tester, h, ads, store: store);

    expect(find.text('পিন দিন'), findsOneWidget);
    expect(_banner, findsNothing);
    expect(ads.bannerRequests, 0);
  });

  feeUiTest('a refresh replaces the banner and frees the old one', (
    tester,
    h,
  ) async {
    final ads = FakeAdService();
    await _launch(tester, h, ads);
    expect(ads.bannerRequests, 1);
    await tester.pump(const Duration(seconds: 61));
    await waitFor(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(ads.bannerRequests, 2);
    expect(ads.bannersDisposed, 1);
    expect(_banner, findsOneWidget);
  });

  feeUiTest('Settings offers ad privacy options only when required', (
    tester,
    h,
  ) async {
    final ads = FakeAdService(privacy: true);
    await _launch(tester, h, ads);
    await goTab(tester, 'সেটিংস');
    await waitFor(tester);
    final tile = find.text('বিজ্ঞাপনের গোপনীয়তা অপশন');
    await tester.scrollUntilVisible(
      tile,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(tile);
    await tester.pump();
    expect(ads.privacyShown, 1);
  });

  feeUiTest('Settings has no ad entry when ads are off', (tester, h) async {
    await pumpApp(tester, h.db, clock: () => h.now);
    await goTab(tester, 'সেটিংস');
    await waitFor(tester);
    expect(find.text('বিজ্ঞাপনের গোপনীয়তা অপশন'), findsNothing);
  });

  feeUiTest('saving a payment and tapping Done may show a full-screen ad', (
    tester,
    h,
  ) async {
    final ads = FakeAdService();
    final student = await seedStudent(tester, h);
    // Past the first days, so the rules allow one.
    await pumpApp(
      tester,
      h.db,
      clock: () => h.now,
      overrides: [
        ...adsOn(ads),
        interstitialProvider.overrideWith(
          (ref) =>
              () => ads.showInterstitial(),
        ),
      ],
    );
    await waitFor(tester);
    await pushRoute(tester, '/fees/pay/${student.id}');
    await waitFor(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'));
    await waitFor(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'ঠিক আছে'));
    await waitFor(tester);
    expect(ads.interstitials, 1);
  });
}
