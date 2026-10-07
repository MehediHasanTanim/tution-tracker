import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';

/// How many whole days [now] is behind [lastSeen], or null when it is not
/// behind by more than [tolerance]. A few hours back is normal (time zone or
/// clock corrections); a day or more is a changed date.
int? daysWentBack({
  required DateTime now,
  required DateTime? lastSeen,
  Duration tolerance = const Duration(days: 1),
}) {
  if (lastSeen == null) return null;
  final back = lastSeen.difference(now);
  return back > tolerance ? back.inDays : null;
}

/// Notices when the phone's date has been set backwards (spec section 7,
/// case 7). It only ever warns: it never changes or deletes data because of
/// the date.
class ClockGuard {
  ClockGuard(this._settings, this._now);

  final SettingsStore _settings;
  final DateTime Function() _now;

  /// The days gone back, to warn about, or null. Moves the "last seen" mark
  /// forward when the clock is fine, but not when it has jumped back (so the
  /// warning stays until acknowledged).
  Future<int?> check() async {
    final now = _now();
    final last = await _settings.get(SettingKeys.lastSeenAt);
    final back = daysWentBack(now: now, lastSeen: last);
    if (back != null) return back;
    // Writing at every resume would be wasteful; an hour's lag is harmless.
    if (last == null || now.difference(last) > const Duration(hours: 1)) {
      await _settings.set(SettingKeys.lastSeenAt, now);
    }
    return null;
  }

  /// The person has seen the warning: accept the current date from now on.
  Future<void> acknowledge() => _settings.set(SettingKeys.lastSeenAt, _now());
}

/// The pending warning, as the number of days the date went back.
class DateJump extends Notifier<int?> {
  @override
  int? build() => null;

  Future<void> check() async {
    try {
      final store = await ref.read(settingsStoreProvider.future);
      final days = await ClockGuard(store, ref.read(clockProvider)).check();
      if (days != null) state = days;
    } on Object {
      // The check is advice only; never let it get in the way.
    }
  }

  Future<void> acknowledge() async {
    final store = await ref.read(settingsStoreProvider.future);
    await ClockGuard(store, ref.read(clockProvider)).acknowledge();
    state = null;
  }
}

final dateJumpProvider = NotifierProvider<DateJump, int?>(DateJump.new);
