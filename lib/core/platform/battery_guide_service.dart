import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phone makers whose battery managers are known to stop reminders unless the
/// user allows the app to run in the background (design 9.3).
enum PhoneMaker {
  xiaomi,
  oppo,
  vivo,
  realme,
  samsung,
  other;

  /// Maps `Build.MANUFACTURER` (and sub-brands) to a maker.
  static PhoneMaker fromManufacturer(String manufacturer) {
    final m = manufacturer.toLowerCase();
    if (m.contains('xiaomi') || m.contains('redmi') || m.contains('poco')) {
      return xiaomi;
    }
    if (m.contains('realme')) return realme;
    if (m.contains('oppo') || m.contains('oneplus')) return oppo;
    if (m.contains('vivo') || m.contains('iqoo')) return vivo;
    if (m.contains('samsung')) return samsung;
    return other;
  }
}

/// Finds out which phone this is and opens its battery settings, wrapped so
/// the guide screen is testable without the plugins.
abstract interface class BatteryGuideService {
  Future<PhoneMaker> maker();

  /// Opens the maker's own background/autostart page when this phone has it,
  /// else the system battery-optimisation list. False if nothing opened.
  Future<bool> openBatterySettings(PhoneMaker maker);
}

class _Target {
  const _Target(this.package, this.component);

  final String package;
  final String component;
}

// Pages move between OS versions, so several are tried in order.
const _targets = <PhoneMaker, List<_Target>>{
  PhoneMaker.xiaomi: [
    _Target(
      'com.miui.securitycenter',
      'com.miui.permcenter.autostart.AutoStartManagementActivity',
    ),
  ],
  PhoneMaker.oppo: [
    _Target(
      'com.oplus.battery',
      'com.oplus.powermanager.fuelgauge.PowerUsageModelActivity',
    ),
    _Target(
      'com.coloros.safecenter',
      'com.coloros.safecenter.permission.startup.StartupAppListActivity',
    ),
  ],
  PhoneMaker.realme: [
    _Target(
      'com.oplus.battery',
      'com.oplus.powermanager.fuelgauge.PowerUsageModelActivity',
    ),
    _Target(
      'com.coloros.safecenter',
      'com.coloros.safecenter.permission.startup.StartupAppListActivity',
    ),
  ],
  PhoneMaker.vivo: [
    _Target(
      'com.vivo.permissionmanager',
      'com.vivo.permissionmanager.activity.BgStartUpManagerActivity',
    ),
    _Target(
      'com.iqoo.secure',
      'com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity',
    ),
  ],
  PhoneMaker.samsung: [
    _Target(
      'com.samsung.android.lool',
      'com.samsung.android.sm.battery.ui.BatteryActivity',
    ),
  ],
};

class PluginBatteryGuideService implements BatteryGuideService {
  const PluginBatteryGuideService();

  @override
  Future<PhoneMaker> maker() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return PhoneMaker.fromManufacturer(info.manufacturer);
    } on Object {
      return PhoneMaker.other;
    }
  }

  @override
  Future<bool> openBatterySettings(PhoneMaker maker) async {
    for (final t in _targets[maker] ?? const <_Target>[]) {
      if (await _launch(
        AndroidIntent(
          action: 'android.intent.action.MAIN',
          package: t.package,
          componentName: t.component,
        ),
      )) {
        return true;
      }
    }
    return _launch(
      const AndroidIntent(
        action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
      ),
    );
  }

  Future<bool> _launch(AndroidIntent intent) async {
    try {
      if (!(await intent.canResolveActivity() ?? false)) return false;
      await intent.launch();
      return true;
    } on Object {
      return false;
    }
  }
}

class NoopBatteryGuideService implements BatteryGuideService {
  const NoopBatteryGuideService();

  @override
  Future<PhoneMaker> maker() async => PhoneMaker.other;

  @override
  Future<bool> openBatterySettings(PhoneMaker maker) async => false;
}

final batteryGuideServiceProvider = Provider<BatteryGuideService>(
  (ref) => defaultTargetPlatform == TargetPlatform.android
      ? const PluginBatteryGuideService()
      : const NoopBatteryGuideService(),
);
