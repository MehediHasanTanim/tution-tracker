import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/platform/secure_store.dart';
import 'package:tution_tracker/features/ads/data/ad_pacing.dart';
import 'package:tution_tracker/features/ads/data/ad_service.dart';
import 'package:tution_tracker/features/ads/data/google_ad_service.dart';
import 'package:tution_tracker/features/ads/domain/ad_config.dart';
import 'package:tution_tracker/features/lock/data/lock_controller.dart';

final adConfigProvider = Provider<AdConfig>(
  (ref) => AdConfig.fromEnvironment(),
);

final adServiceProvider = Provider<AdService>((ref) {
  final config = ref.watch(adConfigProvider);
  return config.enabled ? GoogleAdService(config) : const NoAdService();
});

/// True once consent is settled and the SDK is running. Starts after the first
/// frame so ads never slow the app's start (cold start budget: 2 s).
final adsReadyProvider = FutureProvider<bool>((ref) async {
  final config = ref.watch(adConfigProvider);
  if (!config.enabled) return false;
  await WidgetsBinding.instance.endOfFrame;
  final pacing = ref.read(adPacingProvider);
  await pacing.ensureInstallDate();
  return ref.watch(adServiceProvider).start();
});

final privacyOptionsRequiredProvider = FutureProvider<bool>((ref) async {
  if (!await ref.watch(adsReadyProvider.future)) return false;
  return ref.watch(adServiceProvider).privacyOptionsRequired();
});

final adPacingProvider = Provider<AdPacing>((ref) {
  final pacing = AdPacing(
    ref.watch(secureStoreProvider),
    now: ref.watch(clockProvider),
  );
  ref.listen(lockControllerProvider, (_, status) {
    if (status == LockStatus.locked) pacing.lockShown();
  });
  return pacing;
});

/// Shows a full-screen ad if the rules allow it right now. Call only at a
/// natural pause, never while someone is entering data.
final interstitialProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final config = ref.read(adConfigProvider);
    if (!config.enabled) return;
    if (!await ref.read(adsReadyProvider.future)) return;
    final pacing = ref.read(adPacingProvider);
    if (!await pacing.canShowInterstitial()) return;
    await pacing.recordShown();
    await ref.read(adServiceProvider).showInterstitial();
  };
});
