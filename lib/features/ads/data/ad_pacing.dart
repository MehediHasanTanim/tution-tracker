import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/platform/secure_store.dart';
import 'package:tution_tracker/features/ads/domain/ad_policy.dart';

/// Remembers when full-screen ads were shown, so [InterstitialRules] can be
/// kept. Lives in the secure store, not the database: a restored backup or a
/// "delete all data" must not reset the limits, and backups stay free of ad
/// state.
class AdPacing {
  AdPacing(
    this._store, {
    DateTime Function()? now,
    this.rules = const InterstitialRules(),
  }) : _now = now ?? DateTime.now;

  static const installKey = 'ads_installed_at';
  static const lastKey = 'ads_last_interstitial_at';
  static const dayKey = 'ads_interstitial_day';

  final SecureKeyValueStore _store;
  final DateTime Function() _now;
  final InterstitialRules rules;

  DateTime? _lastLockShownAt;

  /// Called whenever the lock screen appears.
  void lockShown() => _lastLockShownAt = _now();

  /// Records the first run once; every later call leaves it alone.
  Future<void> ensureInstallDate() async {
    if (await _store.read(installKey) == null) {
      await _store.write(installKey, _now().toIso8601String());
    }
  }

  Future<bool> canShowInterstitial() async {
    final installed = DateTime.tryParse(await _store.read(installKey) ?? '');
    final last = DateTime.tryParse(await _store.read(lastKey) ?? '');
    return rules.canShow(
      now: _now(),
      installedAt: installed,
      lastShownAt: last,
      shownToday: await _shownToday(),
      lastLockShownAt: _lastLockShownAt,
    );
  }

  Future<void> recordShown() async {
    final now = _now();
    await _store.write(lastKey, now.toIso8601String());
    final today = LocalDate.fromDateTime(now).toIso();
    final shown = await _shownToday();
    await _store.write(dayKey, '$today|${shown + 1}');
  }

  Future<int> _shownToday() async {
    final raw = await _store.read(dayKey);
    if (raw == null) return 0;
    final parts = raw.split('|');
    if (parts.length != 2) return 0;
    final today = LocalDate.fromDateTime(_now()).toIso();
    return parts[0] == today ? int.tryParse(parts[1]) ?? 0 : 0;
  }
}
