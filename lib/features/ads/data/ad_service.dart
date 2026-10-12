import 'package:flutter/widgets.dart';

/// A loaded banner, ready to put on screen. Call [dispose] when it leaves.
class AdBannerHandle {
  const AdBannerHandle({
    required this.widget,
    required this.height,
    required this.dispose,
  });

  final Widget widget;
  final double height;
  final void Function() dispose;
}

/// Everything the app needs from an ad network, behind one interface so the
/// rest of the app (and every test) never touches the SDK. Nothing in here may
/// be given student, guardian or payment data.
abstract interface class AdService {
  /// Asks for consent where the law requires it, then starts the SDK. True if
  /// ads may be requested. Never throws.
  Future<bool> start();

  /// Whether Settings must offer a "privacy options" entry (the consent form
  /// the user can reopen).
  Future<bool> privacyOptionsRequired();

  Future<void> showPrivacyOptions();

  /// A banner of the given width in dp, or null when none is available
  /// (offline, no fill, not started). Never throws.
  Future<AdBannerHandle?> loadBanner(int widthDp);

  /// Loads and shows a full-screen ad; completes when it is closed, or at once
  /// if there is none. Never throws.
  Future<void> showInterstitial();
}

/// The service for builds with ads off.
class NoAdService implements AdService {
  const NoAdService();

  @override
  Future<bool> start() async => false;

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}

  @override
  Future<AdBannerHandle?> loadBanner(int widthDp) async => null;

  @override
  Future<void> showInterstitial() async {}
}
