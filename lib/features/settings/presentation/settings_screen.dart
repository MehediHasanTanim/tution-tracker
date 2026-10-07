import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/app.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/settings/setting_key.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/ui/input_formatters.dart';
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: SingleChildScrollView(
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
            const _TutorProfileSection(),
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
  final numerals = ref.read(numeralStyleProvider).value ?? NumeralStyle.bangla;
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
                  Text(
                    l10n.devConsistencyIssues(
                      formatCount(issues.length, numerals),
                    ),
                  ),
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

/// The tutor's name, institution and phone (spec ON-2), saved as they type.
class _TutorProfileSection extends ConsumerStatefulWidget {
  const _TutorProfileSection();

  @override
  ConsumerState<_TutorProfileSection> createState() =>
      _TutorProfileSectionState();
}

class _TutorProfileSectionState extends ConsumerState<_TutorProfileSection> {
  final _name = TextEditingController();
  final _institution = TextEditingController();
  final _phone = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = await ref.read(settingsStoreProvider.future);
    _name.text = await store.get(SettingKeys.tutorName);
    _institution.text = await store.get(SettingKeys.institutionName);
    _phone.text = await store.get(SettingKeys.tutorPhone);
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _name.dispose();
    _institution.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save(SettingKey<String> key, String value) async {
    final store = await ref.read(settingsStoreProvider.future);
    await store.set(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.tutorSection, style: theme.textTheme.titleMedium),
        Text(l10n.tutorSectionHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        TextField(
          controller: _name,
          enabled: _loaded,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.tutorName,
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => _save(SettingKeys.tutorName, v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _institution,
          enabled: _loaded,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.tutorInstitution,
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => _save(SettingKeys.institutionName, v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          enabled: _loaded,
          keyboardType: TextInputType.phone,
          inputFormatters: const [PhoneInputFormatter()],
          decoration: InputDecoration(
            labelText: l10n.tutorPhone,
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => _save(SettingKeys.tutorPhone, v),
        ),
      ],
    );
  }
}
