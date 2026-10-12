import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tution_tracker/features/ads/data/ad_service.dart';
import 'package:tution_tracker/features/ads/domain/ad_config.dart';

/// AdMob through `google_mobile_ads`, with Google's consent form (UMP).
///
/// Requests carry no keywords, content URL or extras: nothing about the
/// tutor's students or money ever reaches the network.
class GoogleAdService implements AdService {
  GoogleAdService(this._config);

  final AdConfig _config;
  Future<bool>? _started;

  @override
  Future<bool> start() => _started ??= _start();

  Future<bool> _start() async {
    try {
      await _requestConsent();
      if (!await ConsentInformation.instance.canRequestAds()) return false;
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // Family-friendly content only: the app's data is about children.
          maxAdContentRating: MaxAdContentRating.g,
          // The user of the app is the tutor, an adult: no child treatment.
          ageRestrictedTreatment: AgeRestrictedTreatment.unspecified,
        ),
      );
      await MobileAds.instance.initialize();
      return true;
    } on Object {
      return false;
    }
  }

  Future<void> _requestConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(tagForUnderAgeOfConsent: false),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {
          if (!done.isCompleted) done.complete();
        });
      },
      // No answer (offline): the last stored consent still applies.
      (_) {
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future.timeout(const Duration(seconds: 20), onTimeout: () {});
  }

  @override
  Future<bool> privacyOptionsRequired() async {
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {
        if (!done.isCompleted) done.complete();
      });
    } on Object {
      if (!done.isCompleted) done.complete();
    }
    await done.future;
  }

  @override
  Future<AdBannerHandle?> loadBanner(int widthDp) async {
    if (!await start()) return null;
    try {
      // The standard anchored size is the shorter one; the replacement
      // ("large") is taller than a utility app should spend on an ad.
      // ignore: deprecated_member_use
      final size = await AdSize.getAnchoredAdaptiveBannerAdSize(
        Orientation.portrait,
        widthDp,
      );
      if (size == null) return null;
      final loaded = Completer<BannerAd?>();
      final ad = BannerAd(
        adUnitId: _config.bannerUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) => loaded.complete(ad as BannerAd),
          onAdFailedToLoad: (ad, _) {
            ad.dispose();
            loaded.complete(null);
          },
        ),
      );
      await ad.load();
      final result = await loaded.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          ad.dispose();
          return null;
        },
      );
      if (result == null) return null;
      return AdBannerHandle(
        widget: SizedBox(
          width: size.width.toDouble(),
          height: size.height.toDouble(),
          child: AdWidget(ad: result),
        ),
        height: size.height.toDouble(),
        dispose: result.dispose,
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> showInterstitial() async {
    if (!await start()) return;
    final closed = Completer<void>();
    try {
      await InterstitialAd.load(
        adUnitId: _config.interstitialUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                if (!closed.isCompleted) closed.complete();
              },
              onAdFailedToShowFullScreenContent: (ad, _) {
                ad.dispose();
                if (!closed.isCompleted) closed.complete();
              },
            );
            ad.show();
          },
          onAdFailedToLoad: (_) {
            if (!closed.isCompleted) closed.complete();
          },
        ),
      );
    } on Object {
      if (!closed.isCompleted) closed.complete();
    }
    await closed.future.timeout(const Duration(minutes: 2), onTimeout: () {});
  }
}
