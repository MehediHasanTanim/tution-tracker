import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/settings/setting_key.dart';
import 'package:tution_tracker/features/fees/domain/proration_rule.dart';

/// Every persisted setting, with its default (spec section 3.11).
abstract final class SettingKeys {
  static final language = enumKey(
    'language',
    AppLanguage.values,
    AppLanguage.bn,
  );

  static final numerals = enumKey(
    'numerals',
    NumeralStyle.values,
    NumeralStyle.bangla,
  );

  static final grouping = enumKey(
    'grouping',
    GroupingStyle.values,
    GroupingStyle.lakh,
  );

  static final proration = enumKey(
    'proration_rule',
    ProrationRule.values,
    ProrationRule.fullMonth,
  );

  static final defaultDueDay = intKey('default_due_day', 10, min: 1, max: 31);

  /// Minutes before class that the reminder fires.
  static final classReminderMinutes = intKey(
    'class_reminder_minutes',
    30,
    min: 0,
    max: 24 * 60,
  );

  /// Morning time for the grouped "fees due today" notification.
  static final feeReminderTime = SettingKey<ClockTime>(
    name: 'fee_reminder_time',
    defaultValue: const ClockTime(8, 0),
    encode: (v) => v.toKey(),
    decode: ClockTime.parse,
  );

  /// The tutor's own details, shown on receipts and shared messages (spec
  /// ON-2). All optional.
  static final tutorName = stringKey('tutor_name');
  static final institutionName = stringKey('institution_name');
  static final tutorPhone = stringKey('tutor_phone');

  /// The receipt number the next payment will get (design 7.4, 10.5).
  static final nextReceiptNo = intKey('next_receipt_no', 1, min: 1);

  // ---- reminders (spec section 3.8, design 9) ----------------------------

  /// Master switch. Turning it on goes through the permission flow.
  static final remindersEnabled = boolKey('reminders_enabled');
  static final classReminders = boolKey('reminders_class', defaultValue: true);
  static final feeReminders = boolKey('reminders_fees', defaultValue: true);
  static final weeklySummary = boolKey('reminders_weekly', defaultValue: true);
  static final backupReminders = boolKey(
    'reminders_backup',
    defaultValue: true,
  );

  /// ISO weekday of the weekly dues summary (default Friday).
  static final weeklySummaryDay = intKey(
    'weekly_summary_day',
    5,
    min: 1,
    max: 7,
  );
  static final weeklySummaryTime = SettingKey<ClockTime>(
    name: 'weekly_summary_time',
    defaultValue: const ClockTime(18, 0),
    encode: (v) => v.toKey(),
    decode: ClockTime.parse,
  );

  /// Whether the one-time battery-settings guide has been shown.
  static final oemGuideShown = boolKey('oem_guide_shown');

  // ---- backup ---------------------------------------------------------------

  static final lastBackupAt = dateTimeKey('last_backup_at');

  /// Ask for a backup when the last one is older than this many days.
  static final backupReminderDays = intKey(
    'backup_reminder_days',
    14,
    min: 1,
    max: 365,
  );

  // ---- look ------------------------------------------------------------------

  static final themeMode = enumKey(
    'theme_mode',
    AppThemeMode.values,
    AppThemeMode.system,
  );

  // ---- first run and sample data --------------------------------------------

  static final onboardingDone = boolKey('onboarding_done');

  /// The receipt counter before sample data used some, to put back.
  static final samplePriorReceiptNo = intKey(
    'sample_prior_receipt_no',
    1,
    min: 1,
  );

  /// Guardian fee reminders already sent, as JSON `{"studentId|YYYY-MM": "date"}`.
  static final feeRemindersSent = stringKey('fee_reminders_sent');
}

enum AppThemeMode { system, light, dark }
