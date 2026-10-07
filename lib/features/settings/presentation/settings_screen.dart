import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/app.dart';
import 'package:tution_tracker/core/app_info.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/settings/setting_key.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/ui/input_formatters.dart';
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
import 'package:tution_tracker/features/fees/domain/proration_rule.dart';
import 'package:tution_tracker/features/onboarding/data/onboarding_providers.dart';
import 'package:tution_tracker/features/reminders/presentation/reminder_actions.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final numerals = ref.watchSetting(SettingKeys.numerals);
    final grouping = ref.watchSetting(SettingKeys.grouping);
    final themeMode = ref.watchSetting(SettingKeys.themeMode);
    final dueDay = ref.watchSetting(SettingKeys.defaultDueDay);
    final proration = ref.watchSetting(SettingKeys.proration);

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.language, style: theme.textTheme.titleMedium),
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
            heading(l10n.setNumerals),
            SegmentedButton<NumeralStyle>(
              segments: [
                ButtonSegment(
                  value: NumeralStyle.bangla,
                  label: Text(l10n.setNumeralsBangla),
                ),
                ButtonSegment(
                  value: NumeralStyle.western,
                  label: Text(l10n.setNumeralsWestern),
                ),
              ],
              selected: {numerals},
              onSelectionChanged: (s) =>
                  writeSetting(ref, SettingKeys.numerals, s.first),
            ),
            heading(l10n.setGrouping),
            SegmentedButton<GroupingStyle>(
              segments: [
                ButtonSegment(
                  value: GroupingStyle.lakh,
                  label: Text(l10n.setGroupingLakh),
                ),
                ButtonSegment(
                  value: GroupingStyle.western,
                  label: Text(l10n.setGroupingWestern),
                ),
              ],
              selected: {grouping},
              onSelectionChanged: (s) =>
                  writeSetting(ref, SettingKeys.grouping, s.first),
            ),
            heading(l10n.setTheme),
            SegmentedButton<AppThemeMode>(
              segments: [
                ButtonSegment(
                  value: AppThemeMode.system,
                  label: Text(l10n.setThemeSystem),
                ),
                ButtonSegment(
                  value: AppThemeMode.light,
                  label: Text(l10n.setThemeLight),
                ),
                ButtonSegment(
                  value: AppThemeMode.dark,
                  label: Text(l10n.setThemeDark),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) =>
                  writeSetting(ref, SettingKeys.themeMode, s.first),
            ),
            heading(l10n.setFees),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.setDefaultDueDay),
              subtitle: Text(
                l10n.setDueDayValue(formatCount(dueDay, numerals)),
              ),
              trailing: const Icon(Icons.expand_more),
              onTap: () => _pickDueDay(context, ref, dueDay, numerals),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.setProration),
              subtitle: Text(_prorationLabel(l10n, proration)),
              trailing: const Icon(Icons.expand_more),
              onTap: () => _pickProration(context, ref, proration),
            ),
            Text(l10n.setProrationHint, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            const _TutorProfileSection(),
            heading(l10n.setData),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_outlined),
              title: Text(l10n.remSettingsTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(ReminderRoutes.settings),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.message_outlined),
              title: Text(l10n.tplTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/templates'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline),
              title: Text(l10n.lockSettingsTitle),
              subtitle: Text(l10n.lockSettingsHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/lock'),
            ),
            const _SampleDataTile(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.backup_outlined),
              title: Text(l10n.bkTitle),
              subtitle: Text(l10n.bkPrivacy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/backup'),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.setAbout(appVersion),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (ref.watch(appFlavorProvider) == AppFlavor.dev) ...[
              const SizedBox(height: 24),
              const Divider(),
              Text(l10n.devSection, style: theme.textTheme.titleMedium),
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

String _prorationLabel(AppLocalizations l10n, ProrationRule rule) =>
    switch (rule) {
      ProrationRule.fullMonth => l10n.setProrationFull,
      ProrationRule.byDays => l10n.setProrationDays,
      ProrationRule.nextMonth => l10n.setProrationNext,
    };

Future<void> _pickDueDay(
  BuildContext context,
  WidgetRef ref,
  int current,
  NumeralStyle numerals,
) async {
  final picked = await showDialog<int>(
    context: context,
    builder: (context) => SimpleDialog(
      children: [
        SizedBox(
          width: double.maxFinite,
          height: 320,
          child: ListView(
            children: [
              for (var d = 1; d <= 31; d++)
                ListTile(
                  title: Text(formatCount(d, numerals)),
                  trailing: d == current ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(context, d),
                ),
            ],
          ),
        ),
      ],
    ),
  );
  if (picked != null) {
    await writeSetting(ref, SettingKeys.defaultDueDay, picked);
  }
}

Future<void> _pickProration(
  BuildContext context,
  WidgetRef ref,
  ProrationRule current,
) async {
  final l10n = AppLocalizations.of(context);
  final picked = await showDialog<ProrationRule>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l10n.setProration),
      children: [
        for (final rule in ProrationRule.values)
          ListTile(
            title: Text(_prorationLabel(l10n, rule)),
            trailing: rule == current ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(context, rule),
          ),
      ],
    ),
  );
  if (picked != null) {
    await writeSetting(ref, SettingKeys.proration, picked);
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
    try {
      final store = await ref.read(settingsStoreProvider.future);
      final name = await store.get(SettingKeys.tutorName);
      final institution = await store.get(SettingKeys.institutionName);
      final phone = await store.get(SettingKeys.tutorPhone);
      if (!mounted) return;
      _name.text = name;
      _institution.text = institution;
      _phone.text = phone;
      setState(() => _loaded = true);
    } on Object {
      // The screen went away, or the database was swapped by a restore while
      // this was reading. Nothing to show; the next visit loads again.
    }
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

/// Add or remove the sample data (spec ON-5).
class _SampleDataTile extends ConsumerWidget {
  const _SampleDataTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final loaded = ref.watch(sampleLoadedProvider).value ?? false;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.auto_awesome_outlined),
      title: Text(loaded ? l10n.sampleRemove : l10n.sampleLoad),
      subtitle: Text(l10n.sampleSettingsHint),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        final service = await ref.read(sampleDataServiceProvider.future);
        if (loaded) {
          await service.remove();
          messenger.showSnackBar(SnackBar(content: Text(l10n.sampleRemoved)));
        } else {
          await service.load(ref.read(appLanguageProvider));
          messenger.showSnackBar(SnackBar(content: Text(l10n.sampleLoaded)));
        }
      },
    );
  }
}
