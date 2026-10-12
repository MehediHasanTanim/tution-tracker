/// Where ads may and may not appear, as plain rules with no Flutter in them.
///
/// The rule of thumb: ads go on screens where a tutor is looking around, never
/// where they are entering money or attendance, handling their backup or PIN,
/// or reading a receipt. A stray tap on those screens costs trust, and
/// Google's policy forbids ads that invite accidental taps.
enum AdPlacement {
  /// A banner may show.
  allowed,

  /// No ad: the screen is for entering or protecting data.
  denied,
}

abstract final class AdPolicy {
  /// Browsing screens, by exact path or by pattern (`:x` is any one segment).
  static const _allowed = <String>[
    '/home',
    '/students',
    '/students/:id',
    '/batches/:id',
    '/fees',
    '/fees/remind',
    '/reports',
    '/settings',
    '/settings/reminders',
  ];

  /// Screens that are denied on purpose, listed so that every route in the
  /// router has to be classified and a new one cannot slip through unseen.
  static const _denied = <String>[
    '/attendance', // marking present/absent, save button at the bottom
    '/fees/pay/:id', // recording a payment
    '/fees/receipt/:id', // a receipt, about to be shared
    '/fees/payments/:id/edit', // editing a payment
    '/students/new', // entry forms
    '/students/:id/edit',
    '/batches/new',
    '/batches/:id/edit',
    '/settings/lock', // PIN setup
    '/settings/backup', // backup, restore, delete all
    '/settings/templates', // the template editor
    '/settings/reminders/permission',
    '/settings/reminders/battery',
  ];

  static List<String> get knownPatterns => [..._allowed, ..._denied];

  /// What applies to [location] (a path, with or without a query string).
  /// Anything not listed is denied.
  static AdPlacement placementFor(String location) {
    final path = Uri.parse(location).path;
    if (_matches(_denied, path)) return AdPlacement.denied;
    if (_matches(_allowed, path)) return AdPlacement.allowed;
    return AdPlacement.denied;
  }

  static bool bannerAllowedOn(String location) =>
      placementFor(location) == AdPlacement.allowed;

  /// True if [location] is on either list.
  static bool isClassified(String location) {
    final path = Uri.parse(location).path;
    return _matches(_denied, path) || _matches(_allowed, path);
  }

  static bool _matches(List<String> patterns, String path) =>
      patterns.any((p) => _matchesOne(p, path));

  static bool _matchesOne(String pattern, String path) {
    final a = pattern.split('/');
    final b = path.split('/');
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].startsWith(':')) {
        if (b[i].isEmpty) return false;
      } else if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}

/// When a full-screen ad may be shown. Deliberately sparing.
class InterstitialRules {
  const InterstitialRules({
    this.minInstallAge = const Duration(days: 3),
    this.minGap = const Duration(minutes: 5),
    this.maxPerDay = 3,
    this.afterLockQuietPeriod = const Duration(seconds: 30),
  });

  final Duration minInstallAge;
  final Duration minGap;
  final int maxPerDay;

  /// No full-screen ad right after the lock screen was shown.
  final Duration afterLockQuietPeriod;

  bool canShow({
    required DateTime now,
    required DateTime? installedAt,
    required DateTime? lastShownAt,
    required int shownToday,
    required DateTime? lastLockShownAt,
  }) {
    // Not known yet means not yet.
    if (installedAt == null) return false;
    if (now.difference(installedAt) < minInstallAge) return false;
    if (shownToday >= maxPerDay) return false;
    if (lastShownAt != null && now.difference(lastShownAt) < minGap) {
      return false;
    }
    if (lastLockShownAt != null &&
        now.difference(lastLockShownAt) < afterLockQuietPeriod) {
      return false;
    }
    return true;
  }
}
