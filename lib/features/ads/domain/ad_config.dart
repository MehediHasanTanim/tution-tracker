/// How ads are built into this app. Chosen at build time with
/// `--dart-define=ADS_MODE=off|test|live`; the default is off, so a plain
/// `flutter run` or `flutter test` never touches the network.
enum AdsMode {
  /// No ads, no SDK start-up. The app is exactly as it was without ads.
  off,

  /// Google's public sample ads. Safe to tap.
  test,

  /// Real ads. Only for a release build with the owner's own ad unit ids.
  live;

  static AdsMode parse(String raw) => AdsMode.values.firstWhere(
    (m) => m.name == raw,
    orElse: () => AdsMode.off,
  );
}

const _modeDefine = String.fromEnvironment('ADS_MODE', defaultValue: 'off');
const _bannerDefine = String.fromEnvironment('ADMOB_BANNER_ID');
const _interstitialDefine = String.fromEnvironment('ADMOB_INTERSTITIAL_ID');

/// Google's published sample ids. They only ever serve test ads.
const testBannerUnitId = 'ca-app-pub-3940256099942544/9214589741';
const testInterstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';

/// What [AdsMode], banner id and interstitial id this build uses.
class AdConfig {
  const AdConfig({
    required this.mode,
    required this.bannerUnitId,
    required this.interstitialUnitId,
  });

  /// Reads the build-time defines.
  factory AdConfig.fromEnvironment() => AdConfig.resolve(
    mode: AdsMode.parse(_modeDefine),
    banner: _bannerDefine,
    interstitial: _interstitialDefine,
  );

  /// Test mode always uses Google's sample ids, whatever was passed in, so a
  /// live id can never serve in a test build. Live mode needs both ids.
  factory AdConfig.resolve({
    required AdsMode mode,
    String banner = '',
    String interstitial = '',
  }) {
    switch (mode) {
      case AdsMode.off:
        return const AdConfig(
          mode: AdsMode.off,
          bannerUnitId: '',
          interstitialUnitId: '',
        );
      case AdsMode.test:
        return const AdConfig(
          mode: AdsMode.test,
          bannerUnitId: testBannerUnitId,
          interstitialUnitId: testInterstitialUnitId,
        );
      case AdsMode.live:
        final ok =
            banner.isNotEmpty &&
            interstitial.isNotEmpty &&
            banner != testBannerUnitId &&
            interstitial != testInterstitialUnitId;
        // Without proper ids a live build quietly shows nothing rather than
        // crash or serve test ads to real users.
        return ok
            ? AdConfig(
                mode: AdsMode.live,
                bannerUnitId: banner,
                interstitialUnitId: interstitial,
              )
            : const AdConfig(
                mode: AdsMode.off,
                bannerUnitId: '',
                interstitialUnitId: '',
              );
    }
  }

  final AdsMode mode;
  final String bannerUnitId;
  final String interstitialUnitId;

  bool get enabled => mode != AdsMode.off;
}
