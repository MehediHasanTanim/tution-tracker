import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/app.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
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
            if (ref.watch(appFlavorProvider) == AppFlavor.dev) ...[
              const SizedBox(height: 24),
              const Divider(),
              Text(
                l10n.devSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.fact_check_outlined),
                title: Text(l10n.devConsistency),
                onTap: () => _runConsistencyCheck(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Developer menu: runs the fee-data consistency check (design section 15)
/// and lists what it finds.
Future<void> _runConsistencyCheck(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final checker = await ref.read(consistencyCheckerProvider.future);
  final issues = await checker.run();
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.devConsistency),
      content: SingleChildScrollView(
        child: issues.isEmpty
            ? Text(l10n.devConsistencyOk)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.devConsistencyIssues('${issues.length}')),
                  const SizedBox(height: 8),
                  for (final i in issues) Text('• $i'),
                ],
              ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.payDone),
        ),
      ],
    ),
  );
}
