import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/theme/app_theme.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Build-time environment, set by the flavor entry points.
enum AppFlavor { dev, prod }

class TuitionTrackerApp extends ConsumerWidget {
  const TuitionTrackerApp({required this.flavor, super.key});

  final AppFlavor flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: flavor == AppFlavor.dev,
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
      home: const _LocaleDemoScreen(),
    );
  }
}

/// Temporary screen proving locale switching and Bangla rendering.
/// Replaced by the navigation shell in S1-03.
class _LocaleDemoScreen extends ConsumerWidget {
  const _LocaleDemoScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<Locale>(
              segments: [
                ButtonSegment(
                  value: const Locale('bn'),
                  label: Text(l10n.languageBangla),
                ),
                ButtonSegment(
                  value: const Locale('en'),
                  label: Text(l10n.languageEnglish),
                ),
              ],
              selected: {locale},
              onSelectionChanged: (s) =>
                  ref.read(localeProvider.notifier).setLocale(s.first),
            ),
            const SizedBox(height: 24),
            Text(l10n.sampleConjuncts),
          ],
        ),
      ),
    );
  }
}
