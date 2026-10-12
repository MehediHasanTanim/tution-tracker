import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/platform/secure_store.dart';
import 'package:tution_tracker/features/ads/data/ad_pacing.dart';
import 'package:tution_tracker/features/ads/domain/ad_config.dart';
import 'package:tution_tracker/features/ads/domain/ad_policy.dart';
import 'package:tution_tracker/router.dart';

void main() {
  group('AdConfig', () {
    test('off has no ids and is not enabled', () {
      final c = AdConfig.resolve(mode: AdsMode.off, banner: 'x');
      expect(c.enabled, isFalse);
      expect(c.bannerUnitId, isEmpty);
    });

    test('test mode always uses Google sample ids', () {
      final c = AdConfig.resolve(
        mode: AdsMode.test,
        banner: 'ca-app-pub-1/2',
        interstitial: 'ca-app-pub-1/3',
      );
      expect(c.bannerUnitId, testBannerUnitId);
      expect(c.interstitialUnitId, testInterstitialUnitId);
    });

    test('live mode needs both of the owner\'s own ids', () {
      final ok = AdConfig.resolve(
        mode: AdsMode.live,
        banner: 'ca-app-pub-1/2',
        interstitial: 'ca-app-pub-1/3',
      );
      expect(ok.mode, AdsMode.live);
      expect(ok.bannerUnitId, 'ca-app-pub-1/2');
      for (final bad in [
        AdConfig.resolve(mode: AdsMode.live),
        AdConfig.resolve(mode: AdsMode.live, banner: 'ca-app-pub-1/2'),
        AdConfig.resolve(
          mode: AdsMode.live,
          banner: testBannerUnitId,
          interstitial: 'ca-app-pub-1/3',
        ),
      ]) {
        // Quietly no ads, never test ads in front of real users.
        expect(bad.enabled, isFalse);
      }
    });

    test('unknown mode text means off', () {
      expect(AdsMode.parse('whatever'), AdsMode.off);
      expect(AdsMode.parse('live'), AdsMode.live);
    });
  });

  group('AdPolicy', () {
    test('browsing screens may show a banner', () {
      for (final l in [
        '/home',
        '/students',
        '/students/abc',
        '/batches/b1',
        '/fees',
        '/fees/remind',
        '/reports',
        '/settings',
        '/settings/reminders',
      ]) {
        expect(AdPolicy.bannerAllowedOn(l), isTrue, reason: l);
      }
    });

    test('screens that take or protect data never do', () {
      for (final l in [
        '/attendance?owner=batch&id=b1',
        '/fees/pay/s1',
        '/fees/receipt/p1',
        '/fees/payments/p1/edit',
        '/students/new',
        '/students/s1/edit',
        '/batches/new',
        '/batches/b1/edit',
        '/settings/lock',
        '/settings/backup',
        '/settings/templates',
        '/settings/reminders/permission',
        '/settings/reminders/battery',
      ]) {
        expect(AdPolicy.bannerAllowedOn(l), isFalse, reason: l);
      }
    });

    test('a screen nobody listed gets no ad', () {
      expect(AdPolicy.bannerAllowedOn('/something/new'), isFalse);
      expect(AdPolicy.bannerAllowedOn(''), isFalse);
    });

    test('a query string does not change the answer', () {
      expect(AdPolicy.bannerAllowedOn('/students?q=ra'), isTrue);
    });

    test('every route in the router is classified', () {
      final unclassified = <String>[];
      var seen = 0;
      void walk(List<RouteBase> routes, String parent) {
        for (final r in routes) {
          switch (r) {
            case GoRoute():
              final path = r.path.startsWith('/')
                  ? r.path
                  : '${parent == '/' ? '' : parent}/${r.path}';
              final sample = path.replaceAllMapped(
                RegExp(r':\w+'),
                (_) => 'x1',
              );
              seen++;
              if (!AdPolicy.isClassified(sample)) unclassified.add(path);
              walk(r.routes, path);
            case StatefulShellRoute():
              for (final b in r.branches) {
                walk(b.routes, parent);
              }
            default:
              walk(r.routes, parent);
          }
        }
      }

      walk(buildRouter().configuration.routes, '');
      expect(seen, greaterThan(20)); // the walk really visited the router
      expect(
        unclassified,
        isEmpty,
        reason: 'Add these to AdPolicy (allowed or denied): $unclassified',
      );
    });
  });

  group('InterstitialRules', () {
    const rules = InterstitialRules();
    final installed = DateTime(2026, 10, 1);
    final now = DateTime(2026, 10, 10, 12);

    bool can({
      DateTime? inst,
      DateTime? last,
      int today = 0,
      DateTime? lock,
      DateTime? at,
    }) => rules.canShow(
      now: at ?? now,
      installedAt: inst ?? installed,
      lastShownAt: last,
      shownToday: today,
      lastLockShownAt: lock,
    );

    test('allowed when everything is quiet', () => expect(can(), isTrue));

    test('not in the first three days', () {
      expect(can(inst: DateTime(2026, 10, 8)), isFalse);
      expect(can(inst: DateTime(2026, 10, 7)), isTrue);
    });

    test('not before the install date is known', () {
      expect(
        rules.canShow(
          now: now,
          installedAt: null,
          lastShownAt: null,
          shownToday: 0,
          lastLockShownAt: null,
        ),
        isFalse,
      );
    });

    test('at least five minutes apart, three a day', () {
      expect(can(last: now.subtract(const Duration(minutes: 4))), isFalse);
      expect(can(last: now.subtract(const Duration(minutes: 6))), isTrue);
      expect(can(today: 3), isFalse);
      expect(can(today: 2), isTrue);
    });

    test('not right after the lock screen', () {
      expect(can(lock: now.subtract(const Duration(seconds: 10))), isFalse);
      expect(can(lock: now.subtract(const Duration(seconds: 40))), isTrue);
    });
  });

  group('AdPacing', () {
    late MemorySecureKeyValueStore store;
    late DateTime clock;
    late AdPacing pacing;

    setUp(() {
      store = MemorySecureKeyValueStore();
      clock = DateTime(2026, 10, 1, 9);
      pacing = AdPacing(store, now: () => clock);
    });

    test('the install date is written once', () async {
      await pacing.ensureInstallDate();
      final first = store.values[AdPacing.installKey];
      clock = DateTime(2026, 11, 1);
      await pacing.ensureInstallDate();
      expect(store.values[AdPacing.installKey], first);
    });

    test('nothing shows in the first days, then shows, then limits', () async {
      await pacing.ensureInstallDate();
      expect(await pacing.canShowInterstitial(), isFalse);

      clock = DateTime(2026, 10, 5, 9);
      expect(await pacing.canShowInterstitial(), isTrue);
      await pacing.recordShown();
      expect(await pacing.canShowInterstitial(), isFalse); // too soon

      clock = clock.add(const Duration(minutes: 6));
      expect(await pacing.canShowInterstitial(), isTrue);
      await pacing.recordShown();
      clock = clock.add(const Duration(minutes: 6));
      await pacing.recordShown();
      clock = clock.add(const Duration(minutes: 6));
      expect(await pacing.canShowInterstitial(), isFalse); // three today

      clock = DateTime(2026, 10, 6, 9);
      expect(await pacing.canShowInterstitial(), isTrue); // a new day
    });

    test('the lock screen quietens it for a moment', () async {
      await pacing.ensureInstallDate();
      clock = DateTime(2026, 10, 5, 9);
      pacing.lockShown();
      expect(await pacing.canShowInterstitial(), isFalse);
      clock = clock.add(const Duration(seconds: 31));
      expect(await pacing.canShowInterstitial(), isTrue);
    });
  });
}
