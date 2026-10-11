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
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
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
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          BlockStack(
            children: [
              const _HealthTile(),
              BlockToggle(
                label: l10n.remMasterTitle,
                subtitle: l10n.remMasterHint,
                value: enabled,
                onChanged: (on) => on
                    ? startEnableReminders(context, ref)
                    : disableReminders(ref),
              ),
              BlockToggle(
                label: l10n.remClassOn,
                value: ref.watchSetting(SettingKeys.classReminders),
                onChanged: enabled
                    ? (v) => writeSetting(ref, SettingKeys.classReminders, v)
                    : null,
              ),
              if (enabled && ref.watchSetting(SettingKeys.classReminders))
                BlockChips<int>(
                  options: [
                    for (final m in const [5, 10, 15, 30, 45, 60])
                      (m, l10n.remMinutes(formatCount(m, numerals))),
                  ],
                  isSelected: (m) =>
                      m == ref.watchSetting(SettingKeys.classReminderMinutes),
                  onTap: (m) =>
                      writeSetting(ref, SettingKeys.classReminderMinutes, m),
                ),
              BlockToggle(
                label: l10n.remFeeOn,
                value: ref.watchSetting(SettingKeys.feeReminders),
                onChanged: enabled
                    ? (v) => writeSetting(ref, SettingKeys.feeReminders, v)
                    : null,
              ),
              if (enabled && ref.watchSetting(SettingKeys.feeReminders))
                BlockItem(
                  leading: const BlockIcon(Icons.schedule_rounded),
                  title: l10n.remAt(time(feeTime)),
                  chevron: true,
                  onTap: () => pickTime(SettingKeys.feeReminderTime, feeTime),
                ),
              BlockToggle(
                label: l10n.remWeeklyOn,
                value: ref.watchSetting(SettingKeys.weeklySummary),
                onChanged: enabled
                    ? (v) => writeSetting(ref, SettingKeys.weeklySummary, v)
                    : null,
              ),
              if (enabled && ref.watchSetting(SettingKeys.weeklySummary))
                BlockItem(
                  leading: const BlockIcon(Icons.event_repeat_rounded),
                  title: l10n.remWeeklyWhen(
                    weekdayName(weeklyDay, language),
                    time(weeklyTime),
                  ),
                  chevron: true,
                  onTap: () => _pickWeekly(context, ref, weeklyTime, language),
                ),
              BlockToggle(
                label: l10n.remBackupOn,
                subtitle: l10n.remBackupAfter(
                  formatCount(
                    ref.watchSetting(SettingKeys.backupReminderDays),
                    numerals,
                  ),
                ),
                value: ref.watchSetting(SettingKeys.backupReminders),
                onChanged: enabled
                    ? (v) => writeSetting(ref, SettingKeys.backupReminders, v)
                    : null,
              ),
              const SizedBox(height: 4),
              BlockItem(
                leading: const BlockIcon(Icons.battery_saver_rounded),
                title: l10n.oemTitle,
                subtitle: l10n.remBatterySub,
                chevron: true,
                onTap: () => context.push(ReminderRoutes.battery),
              ),
              BlockItem(
                leading: const BlockIcon(Icons.chat_bubble_outline_rounded),
                title: l10n.tplTitle,
                subtitle: l10n.remTemplateSub,
                chevron: true,
                onTap: () => context.push('/settings/templates'),
              ),
              BlockItem(
                leading: const BlockIcon(
                  Icons.notification_add_rounded,
                  sage: true,
                ),
                title: l10n.remTestSend,
                onTap: enabled
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final scheduler = await ref.read(
                          reminderSchedulerProvider.future,
                        );
                        await scheduler.sendTest();
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.remTestSent)),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
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
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final status = ref.watch(reminderStatusProvider).value;

    final o = Organic.of(context);
    final (
      String text,
      bool warn,
      VoidCallback? onTap,
      String? action,
    ) = switch (status) {
      null => ('…', false, null, null),
      ReminderStatus(enabled: false) => (
        l10n.remHealthOff,
        true,
        () => startEnableReminders(context, ref),
        l10n.remMasterTitle,
      ),
      ReminderStatus(permitted: false) => (
        l10n.remHealthBlocked,
        true,
        () => context.push(ReminderRoutes.permission),
        l10n.remPermAllow,
      ),
      ReminderStatus(scheduled: 0) => (l10n.remHealthNone, false, null, null),
      final s => (
        l10n.remHealthOk(formatCount(s.scheduled, numerals)),
        false,
        null,
        null,
      ),
    };
    return BlockStack(
      children: [
        BlockBanner(
          title: l10n.remHealth,
          text: text,
          background: warn ? o.accentSoft : o.sageSoft,
          foreground: warn ? o.onAccentSoft : o.onSageSoft,
        ),
        if (onTap != null && action != null)
          BlockButton(action, onPressed: onTap),
      ],
    );
  }
}
