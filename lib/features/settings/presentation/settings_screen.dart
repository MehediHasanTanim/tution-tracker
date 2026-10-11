import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/app.dart';
import 'package:tution_tracker/core/app_info.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/platform/url_launcher_service.dart';
import 'package:tution_tracker/core/settings/setting_key.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/input_formatters.dart';
import 'package:tution_tracker/core/ui/organic_widgets.dart';
import 'package:tution_tracker/features/backup/data/backup_status_provider.dart';
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
    final fontSize = ref.watchSetting(SettingKeys.fontSize);
    final calendar = ref.watchSetting(SettingKeys.calendar);
    final dueDay = ref.watchSetting(SettingKeys.defaultDueDay);
    final proration = ref.watchSetting(SettingKeys.proration);

    Widget heading(String text, {bool first = false}) => Padding(
      padding: EdgeInsets.only(top: first ? 4 : 18, bottom: 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _BackupCard(),
            const SizedBox(height: 16),
            _Group(
              children: [
                heading(l10n.language, first: true),
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
                heading(l10n.setCalendar),
                SegmentedButton<CalendarStyle>(
                  segments: [
                    ButtonSegment(
                      value: CalendarStyle.gregorian,
                      label: Text(l10n.setCalendarGregorian),
                    ),
                    ButtonSegment(
                      value: CalendarStyle.bangla,
                      label: Text(l10n.setCalendarBangla),
                    ),
                  ],
                  selected: {calendar},
                  onSelectionChanged: (s) =>
                      writeSetting(ref, SettingKeys.calendar, s.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Group(
              children: [
                heading(l10n.setTheme, first: true),
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
                heading(l10n.setFontSize),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (size, label) in [
                      (AppFontSize.small, l10n.setFontSmall),
                      (AppFontSize.normal, l10n.setFontNormal),
                      (AppFontSize.large, l10n.setFontLarge),
                      (AppFontSize.extraLarge, l10n.setFontExtraLarge),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: fontSize == size,
                        onSelected: (_) =>
                            writeSetting(ref, SettingKeys.fontSize, size),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Text(
                    l10n.setFontPreview,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Group(
              children: [
                heading(l10n.setFees, first: true),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.setDefaultDueDay),
                  subtitle: Text(
                    l10n.setDueDayValue(formatCount(dueDay, numerals)),
                  ),
                  trailing: const Icon(Icons.expand_more_rounded),
                  onTap: () => _pickDueDay(context, ref, dueDay, numerals),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.setProration),
                  subtitle: Text(_prorationLabel(l10n, proration)),
                  trailing: const Icon(Icons.expand_more_rounded),
                  onTap: () => _pickProration(context, ref, proration),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    l10n.setProrationHint,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _Group(children: [_TutorProfileSection()]),
            const SizedBox(height: 12),
            _Group(
              children: [
                heading(l10n.setData, first: true),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_rounded),
                  title: Text(l10n.remSettingsTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(ReminderRoutes.settings),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.chat_bubble_outline_rounded),
                  title: Text(l10n.tplTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/templates'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_rounded),
                  title: Text(l10n.lockSettingsTitle),
                  subtitle: Text(l10n.lockSettingsHint),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/lock'),
                ),
                const _SampleDataTile(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.backup_rounded),
                  title: Text(l10n.bkTitle),
                  subtitle: Text(l10n.bkPrivacy),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/backup'),
                ),
              ],
            ),
            // The privacy note is always here; the links appear when the build
            // was given them (tool/release.sh).
            heading(l10n.helpTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: Organic.of(context).muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.bkPrivacy,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Organic.of(context).subtle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...[
              if (supportWhatsApp.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.chat_rounded),
                  title: Text(l10n.helpSupportWhatsApp),
                  onTap: () => ref
                      .read(urlLauncherProvider)
                      .open(
                        Uri.parse(
                          'https://wa.me/$supportWhatsApp?text='
                          '${Uri.encodeComponent(l10n.helpSupportMessage)}',
                        ),
                      ),
                ),
              if (supportEmail.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.mail_rounded),
                  title: Text(l10n.helpSupportEmail),
                  onTap: () => ref
                      .read(urlLauncherProvider)
                      .open(Uri.parse('mailto:$supportEmail')),
                ),
              if (privacyPolicyUrl.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_rounded),
                  title: Text(l10n.helpPrivacyPolicy),
                  onTap: () => ref
                      .read(urlLauncherProvider)
                      .open(Uri.parse(privacyPolicyUrl)),
                ),
            ],
            const SizedBox(height: 16),
            Text(
              l10n.setAbout(applyNumerals(appVersion, numerals)),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (ref.watch(appFlavorProvider) == AppFlavor.dev) ...[
              const SizedBox(height: 24),
              const Divider(),
              Text(l10n.devSection, style: theme.textTheme.titleMedium),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.fact_check_rounded),
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

/// A rounded group of settings on the surface colour. Controls inside take
/// the page ground as their fill, as in the handoff's settings card.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final o = Organic.of(context);
    final seg = theme.segmentedButtonTheme.style!;
    return OrganicPanel(
      radius: OrganicRadius.panel,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Theme(
        data: theme.copyWith(
          segmentedButtonTheme: SegmentedButtonThemeData(
            style: seg.copyWith(
              backgroundColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? o.accent : o.bg,
              ),
              side: WidgetStatePropertyAll(BorderSide(color: o.bg, width: 4)),
            ),
          ),
          chipTheme: theme.chipTheme.copyWith(backgroundColor: o.bg),
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            fillColor: o.bg,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// The handoff's backup card: terracotta when a backup is overdue, sage when
/// the data is safe, with the export button right there (spec BK-5).
class _BackupCard extends ConsumerWidget {
  const _BackupCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final o = Organic.of(context);
    final status = ref.watch(backupStatusProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final warn = status.show;
    final fg = warn ? o.onAccentSoft : o.onSageSoft;
    final days = status.daysAgo;
    final message = warn
        ? (days == null
              ? l10n.bkBannerNever
              : l10n.bkBannerOld(formatCount(days, numerals)))
        : l10n.bkPrivacy;
    return OrganicPanel(
      color: warn ? o.accentSoft : o.sageSoft,
      radius: OrganicRadius.panel,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.bkCardTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: fg)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.push('/settings/backup'),
            style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
            child: Text(l10n.bkNow),
          ),
        ],
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
        const SizedBox(height: 4),
        Text(l10n.tutorSection, style: theme.textTheme.titleMedium),
        Text(l10n.tutorSectionHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 14),
        TextField(
          controller: _name,
          enabled: _loaded,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.tutorName),
          onChanged: (v) => _save(SettingKeys.tutorName, v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _institution,
          enabled: _loaded,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.tutorInstitution),
          onChanged: (v) => _save(SettingKeys.institutionName, v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          enabled: _loaded,
          keyboardType: TextInputType.phone,
          inputFormatters: const [PhoneInputFormatter()],
          decoration: InputDecoration(labelText: l10n.tutorPhone),
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
      leading: const Icon(Icons.auto_awesome_rounded),
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
