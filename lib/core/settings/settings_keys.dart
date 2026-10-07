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

  /// The receipt number the next payment will get (design 7.4, 10.5).
  static final nextReceiptNo = intKey('next_receipt_no', 1, min: 1);
}
