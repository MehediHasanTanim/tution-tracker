import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/theme/app_theme.dart';
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A new month may have started while the app was in the background.
    if (state == AppLifecycleState.resumed) unawaited(_generateDues());
  }

  /// Fills in any dues that are missing up to this month (design 7.1). Safe
  /// to repeat: it only creates what is not there yet.
  Future<void> _generateDues() async {
    try {
      final dues = await ref.read(dueServiceProvider.future);
      await dues.generateForAll();
    } on Object {
      // Nothing to show the user; the next start or resume tries again.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: widget.flavor == AppFlavor.dev,
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
