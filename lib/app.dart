import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/navigation/app_gate.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/theme/app_theme.dart';
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
import 'package:tution_tracker/features/reminders/data/reminder_coordinator.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';
import 'package:tution_tracker/router.dart';

/// Build-time environment, set by the flavor entry points.
enum AppFlavor { dev, prod }

/// The running flavor. The entry points override it; it defaults to prod so a
/// missing override can never switch on developer tools.
final appFlavorProvider = Provider<AppFlavor>((ref) => AppFlavor.prod);

class TuitionTrackerApp extends ConsumerStatefulWidget {
  const TuitionTrackerApp({required this.flavor, super.key});

  final AppFlavor flavor;

  @override
  ConsumerState<TuitionTrackerApp> createState() => _TuitionTrackerAppState();
}

class _TuitionTrackerAppState extends ConsumerState<TuitionTrackerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_generateDues());
    unawaited(ref.read(reminderCoordinatorProvider).start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A new month may have started while the app was in the background.
    if (state == AppLifecycleState.resumed) {
      unawaited(_generateDues());
      unawaited(ref.read(reminderCoordinatorProvider).refresh());
    }
  }

  /// Fills in any dues that are missing up to this month (design 7.1). Safe
  /// to repeat: it only creates what is not there yet.
  Future<void> _generateDues() async {
    try {
      await ref.read(databaseLockProvider).run(() async {
        final dues = await ref.read(dueServiceProvider.future);
        await dues.generateForAll();
      });
    } on Object {
      // Nothing to show the user; the next start or resume tries again.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        final size = ref.watchSetting(SettingKeys.fontSize);
        final media = MediaQuery.of(context);
        // The app's own step multiplies the phone's setting (spec SE-8).
        return MediaQuery(
          data: media.copyWith(
            textScaler: _MultipliedScaler(media.textScaler, size.factor),
          ),
          child: AppGate(child: child ?? const SizedBox()),
        );
      },
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: widget.flavor == AppFlavor.dev,
      themeMode: switch (ref.watchSetting(SettingKeys.themeMode)) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: ref.watch(localeProvider),
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

/// The phone's text scaler with the app's size step on top.
class _MultipliedScaler extends TextScaler {
  const _MultipliedScaler(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  double get textScaleFactor => scale(1);

  @override
  bool operator ==(Object other) =>
      other is _MultipliedScaler &&
      other.base == base &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
