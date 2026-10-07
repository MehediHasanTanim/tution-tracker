import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/platform/notification_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/attendance/data/attendance_providers.dart';
import 'package:tution_tracker/features/attendance/data/attendance_repository.dart';
import 'package:tution_tracker/features/reminders/domain/reminder_planner.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// What the last plan did, for the "reminder health" indicator.
class ReminderStatus {
  const ReminderStatus({
    required this.enabled,
    required this.permitted,
    required this.scheduled,
    this.refreshedAt,
  });

  final bool enabled;
  final bool permitted;

  /// Notifications waiting to fire.
  final int scheduled;
  final DateTime? refreshedAt;

  bool get healthy => enabled && permitted;
}

/// Works out the next two weeks of reminders and hands them to the phone,
/// replacing whatever was scheduled before (design 9.2).
///
/// Call [replan] whenever something it depends on may have changed. Calls
/// that arrive while a plan is running are folded into one more run.
class ReminderScheduler {
  ReminderScheduler(
    this._db,
    this._settings,
    this._attendance,
    this._notifications, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final SettingsStore _settings;
  final AttendanceRepository _attendance;
  final NotificationService _notifications;
  final DateTime Function() _now;

  Future<void>? _running;
  bool _again = false;

  /// Replans now, or after the plan already in progress.
  Future<void> replan() {
    if (_running != null) {
      _again = true;
      return _running!;
    }
    return _running = _loop().whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    do {
      _again = false;
      await _plan();
    } while (_again);
  }

  Future<void> _plan() async {
    final enabled = await _settings.get(SettingKeys.remindersEnabled);
    if (!enabled || !await _notifications.isPermitted()) {
      await _notifications.cancelAll();
      return;
    }
    final language = await _settings.get(SettingKeys.language);
    final numerals = await _settings.get(SettingKeys.numerals);
    final grouping = await _settings.get(SettingKeys.grouping);
    final l10n = lookupAppLocalizations(Locale(language.name));
    await prepare();

    final now = _now();
    final today = LocalDate.fromDateTime(now);
    final config = await loadConfig();
    final plan = planReminders(
      now: now,
      config: config,
      rules: [
        ...await _attendance.watchBatchRules().first,
        ...await _attendance.watchOneToOneRules().first,
      ],
      records: await _attendance.sessionsBetween(today, today.addDays(14)),
      dues: await _openDues(),
    );

    String money(int v) =>
        formatTaka(Taka(v), numerals: numerals, grouping: grouping);
    String n(int v) => formatCount(v, numerals);

    await _notifications.replaceAll([
      for (final r in plan)
        switch (r.kind) {
          ReminderKind.classStart => ScheduledNotification(
            id: r.id,
            at: r.at,
            channel: NotificationChannel.classes,
            title: l10n.remClassTitle(r.owner!.name),
            body: l10n.remClassBody(applyNumerals(r.time!.toKey(), numerals)),
            payload: attendanceLocation(r.owner!, r.date!, r.time),
          ),
          ReminderKind.feesDue => ScheduledNotification(
            id: r.id,
            at: r.at,
            channel: NotificationChannel.fees,
            title: l10n.remFeesTitle(n(r.count)),
            body: l10n.remFeesBody(money(r.amount)),
            payload: '/fees',
          ),
          ReminderKind.weeklySummary => ScheduledNotification(
            id: r.id,
            at: r.at,
            channel: NotificationChannel.summary,
            title: l10n.remWeeklyTitle,
            body: l10n.remWeeklyBody(n(r.count), money(r.amount)),
            payload: '/fees',
          ),
          ReminderKind.backup => ScheduledNotification(
            id: r.id,
            at: r.at,
            channel: NotificationChannel.backup,
            title: l10n.remBackupTitle,
            body: l10n.remBackupBody,
            payload: '/settings/backup',
          ),
          ReminderKind.keepOn => ScheduledNotification(
            id: r.id,
            at: r.at,
            channel: NotificationChannel.summary,
            title: l10n.remKeepOnTitle,
            body: l10n.remKeepOnBody,
            payload: '/home',
          ),
        },
    ]);
  }

  /// Creates the notification channels (in the current language) and starts
  /// listening for taps. Needed before anything can be shown or tapped.
  Future<void> prepare() async {
    final language = await _settings.get(SettingKeys.language);
    final l10n = lookupAppLocalizations(Locale(language.name));
    await _notifications.initialize(channelTexts(l10n));
  }

  /// The reminder settings as a planner config.
  Future<ReminderConfig> loadConfig() async => ReminderConfig(
    classReminders: await _settings.get(SettingKeys.classReminders),
    classMinutesBefore: await _settings.get(SettingKeys.classReminderMinutes),
    feeReminders: await _settings.get(SettingKeys.feeReminders),
    feeTime: await _settings.get(SettingKeys.feeReminderTime),
    weeklySummary: await _settings.get(SettingKeys.weeklySummary),
    weeklyDay: await _settings.get(SettingKeys.weeklySummaryDay),
    weeklyTime: await _settings.get(SettingKeys.weeklySummaryTime),
    backupReminders: await _settings.get(SettingKeys.backupReminders),
    backupAfterDays: await _settings.get(SettingKeys.backupReminderDays),
    lastBackup: await _settings.get(SettingKeys.lastBackupAt),
  );

  /// Unpaid, unwaived dues of students who are still active.
  Future<List<DueEntry>> _openDues() async {
    final rows = await _db
        .customSelect(
          'SELECT b.student_id AS student_id, b.due_date AS due_date, '
          'b.balance AS balance FROM fee_balances b '
          'JOIN students s ON s.id = b.student_id '
          "WHERE b.waived = 0 AND b.balance > 0 AND s.status = 'active'",
          readsFrom: {_db.students},
        )
        .get();
    return [
      for (final r in rows)
        DueEntry(
          studentId: r.read<String>('student_id'),
          dueDate: LocalDate.parse(r.read<String>('due_date')),
          balance: r.read<int>('balance'),
        ),
    ];
  }

  /// A snapshot for the health indicator.
  Future<ReminderStatus> status() async => ReminderStatus(
    enabled: await _settings.get(SettingKeys.remindersEnabled),
    permitted: await _notifications.isPermitted(),
    scheduled: (await _notifications.pendingIds()).length,
    refreshedAt: _now(),
  );

  /// Fires one notification now, to prove reminders reach the tutor.
  Future<void> sendTest() async {
    final language = await _settings.get(SettingKeys.language);
    final l10n = lookupAppLocalizations(Locale(language.name));
    await prepare();
    await _notifications.showNow(
      ScheduledNotification(
        id: 1,
        at: _now(),
        channel: NotificationChannel.classes,
        title: l10n.remTestTitle,
        body: l10n.remTestBody,
      ),
    );
  }

  /// Whether the current notification permission lets reminders work.
  Future<bool> isPermitted() => _notifications.isPermitted();
}

/// Channel names and descriptions in the language of [l10n].
ChannelTexts channelTexts(AppLocalizations l10n) => {
  NotificationChannel.classes: (
    name: l10n.chClasses,
    about: l10n.chClassesAbout,
  ),
  NotificationChannel.fees: (name: l10n.chFees, about: l10n.chFeesAbout),
  NotificationChannel.summary: (
    name: l10n.chSummary,
    about: l10n.chSummaryAbout,
  ),
  NotificationChannel.backup: (name: l10n.chBackup, about: l10n.chBackupAbout),
};
