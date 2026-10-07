import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/settings/setting_key.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/reminders/data/reminder_providers.dart';
import 'package:tution_tracker/features/reminders/data/reminder_scheduler.dart';
import 'package:tution_tracker/features/reminders/presentation/reminder_actions.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Reminder switches, times, the "reminder health" indicator and the test
/// notification (spec 3.8, S4-05).
class RemindersSettingsScreen extends ConsumerWidget {
  const RemindersSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final enabled = ref.watchSetting(SettingKeys.remindersEnabled);
    String time(ClockTime t) => applyNumerals(t.toKey(), numerals);

    Future<void> pickTime(SettingKey<ClockTime> key, ClockTime current) async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
      );
      if (picked != null) {
        await writeSetting(ref, key, ClockTime(picked.hour, picked.minute));
      }
    }

    final feeTime = ref.watchSetting(SettingKeys.feeReminderTime);
    final weeklyTime = ref.watchSetting(SettingKeys.weeklySummaryTime);
    final weeklyDay = ref.watchSetting(SettingKeys.weeklySummaryDay);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remSettingsTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.remMasterTitle),
            subtitle: Text(l10n.remMasterHint),
            value: enabled,
            onChanged: (on) =>
                on ? startEnableReminders(context, ref) : disableReminders(ref),
          ),
          const _HealthTile(),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.remClassOn),
            value: ref.watchSetting(SettingKeys.classReminders),
            onChanged: enabled
                ? (v) => writeSetting(ref, SettingKeys.classReminders, v)
                : null,
          ),
          ListTile(
            enabled: enabled && ref.watchSetting(SettingKeys.classReminders),
            title: Text(
              l10n.remMinutes(
                formatCount(
                  ref.watchSetting(SettingKeys.classReminderMinutes),
                  numerals,
                ),
              ),
            ),
            trailing: const Icon(Icons.expand_more),
            onTap: () => _pickMinutes(context, ref, numerals),
          ),
          SwitchListTile(
            title: Text(l10n.remFeeOn),
            value: ref.watchSetting(SettingKeys.feeReminders),
            onChanged: enabled
                ? (v) => writeSetting(ref, SettingKeys.feeReminders, v)
                : null,
          ),
          ListTile(
            enabled: enabled && ref.watchSetting(SettingKeys.feeReminders),
            title: Text(l10n.remAt(time(feeTime))),
            trailing: const Icon(Icons.schedule),
            onTap: () => pickTime(SettingKeys.feeReminderTime, feeTime),
          ),
          SwitchListTile(
            title: Text(l10n.remWeeklyOn),
            value: ref.watchSetting(SettingKeys.weeklySummary),
            onChanged: enabled
                ? (v) => writeSetting(ref, SettingKeys.weeklySummary, v)
                : null,
          ),
          ListTile(
            enabled: enabled && ref.watchSetting(SettingKeys.weeklySummary),
            title: Text(
              l10n.remWeeklyWhen(
                weekdayName(weeklyDay, language),
                time(weeklyTime),
              ),
            ),
            trailing: const Icon(Icons.expand_more),
            onTap: () => _pickWeekly(context, ref, weeklyTime, language),
          ),
          SwitchListTile(
            title: Text(l10n.remBackupOn),
            subtitle: Text(
              l10n.remBackupAfter(
                formatCount(
                  ref.watchSetting(SettingKeys.backupReminderDays),
                  numerals,
                ),
              ),
            ),
            value: ref.watchSetting(SettingKeys.backupReminders),
            onChanged: enabled
                ? (v) => writeSetting(ref, SettingKeys.backupReminders, v)
                : null,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notification_add_outlined),
            title: Text(l10n.remTestSend),
            enabled: enabled,
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final scheduler = await ref.read(
                reminderSchedulerProvider.future,
              );
              await scheduler.sendTest();
              messenger.showSnackBar(SnackBar(content: Text(l10n.remTestSent)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.battery_saver),
            title: Text(l10n.oemTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(ReminderRoutes.battery),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMinutes(
    BuildContext context,
    WidgetRef ref,
    NumeralStyle numerals,
  ) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          for (final m in const [5, 10, 15, 30, 45, 60])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, m),
              child: Text(l10n.remMinutes(formatCount(m, numerals))),
            ),
        ],
      ),
    );
    if (picked != null) {
      await writeSetting(ref, SettingKeys.classReminderMinutes, picked);
    }
  }

  Future<void> _pickWeekly(
    BuildContext context,
    WidgetRef ref,
    ClockTime currentTime,
    AppLanguage language,
  ) async {
    final day = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          for (final d in const [6, 7, 1, 2, 3, 4, 5])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, d),
              child: Text(weekdayName(d, language)),
            ),
        ],
      ),
    );
    if (day == null) return;
    await writeSetting(ref, SettingKeys.weeklySummaryDay, day);
    if (!context.mounted) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentTime.hour,
        minute: currentTime.minute,
      ),
    );
    if (picked != null) {
      await writeSetting(
        ref,
        SettingKeys.weeklySummaryTime,
        ClockTime(picked.hour, picked.minute),
      );
    }
  }
}

/// "Reminder health": is it on, is the phone letting it through, and is
/// anything actually scheduled.
class _HealthTile extends ConsumerWidget {
  const _HealthTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final status = ref.watch(reminderStatusProvider).value;

    final (
      IconData icon,
      Color color,
      String text,
      VoidCallback? onTap,
    ) = switch (status) {
      null => (Icons.hourglass_empty, scheme.outline, '…', null),
      ReminderStatus(enabled: false) => (
        Icons.notifications_off_outlined,
        scheme.outline,
        l10n.remHealthOff,
        () => startEnableReminders(context, ref),
      ),
      ReminderStatus(permitted: false) => (
        Icons.error_outline,
        scheme.error,
        l10n.remHealthBlocked,
        () => context.push(ReminderRoutes.permission),
      ),
      ReminderStatus(scheduled: 0) => (
        Icons.info_outline,
        scheme.tertiary,
        l10n.remHealthNone,
        null,
      ),
      final s => (
        Icons.check_circle_outline,
        scheme.primary,
        l10n.remHealthOk(formatCount(s.scheduled, numerals)),
        null,
      ),
    };
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(l10n.remHealth),
      subtitle: Text(text),
      onTap: onTap,
    );
  }
}
