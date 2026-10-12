import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tution_tracker/features/ads/data/ad_providers.dart';
import 'package:tution_tracker/features/ads/data/ad_service.dart';
import 'package:tution_tracker/features/ads/domain/ad_config.dart';

/// An ad network that answers instantly and records what it was asked.
class FakeAdService implements AdService {
  FakeAdService({
    this.fill = true,
    this.consentOk = true,
    this.privacy = false,
  });

  /// False: every banner request finds nothing (offline, no fill).
  bool fill;
  bool consentOk;
  bool privacy;

  int starts = 0;
  int bannerRequests = 0;
  int bannersDisposed = 0;
  int interstitials = 0;
  int privacyShown = 0;
  final widths = <int>[];

  @override
  Future<bool> start() async {
    starts++;
    return consentOk;
  }

  @override
  Future<bool> privacyOptionsRequired() async => privacy;

  @override
  Future<void> showPrivacyOptions() async => privacyShown++;

  @override
  Future<AdBannerHandle?> loadBanner(int widthDp) async {
    bannerRequests++;
    widths.add(widthDp);
    if (!fill) return null;
    return AdBannerHandle(
      widget: const SizedBox(
        key: Key('fake-banner'),
        height: 50,
        width: double.infinity,
        child: Center(child: Text('TEST AD')),
      ),
      height: 50,
      dispose: () => bannersDisposed++,
    );
  }

  @override
  Future<void> showInterstitial() async => interstitials++;
}

/// Turns ads on in a test app, with [service] as the network.
List<Override> adsOn(FakeAdService service) => [
  adConfigProvider.overrideWithValue(
    const AdConfig(
      mode: AdsMode.test,
      bannerUnitId: testBannerUnitId,
      interstitialUnitId: testInterstitialUnitId,
    ),
  ),
  adServiceProvider.overrideWithValue(service),
];
