import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/fees/domain/proration_rule.dart';

void main() {
  late AppDatabase db;
  late SettingsStore store;

  setUp(() {
    db = openInMemoryDatabase();
    store = SettingsStore(db);
  });

  tearDown(() => db.close());

  Future<void> putRaw(String key, String value) => db
      .into(db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  group('defaults when keys are missing', () {
    test('every setting has its documented default', () async {
      expect(await store.get(SettingKeys.language), AppLanguage.bn);
      expect(await store.get(SettingKeys.numerals), NumeralStyle.bangla);
      expect(await store.get(SettingKeys.grouping), GroupingStyle.lakh);
      expect(await store.get(SettingKeys.proration), ProrationRule.fullMonth);
      expect(await store.get(SettingKeys.defaultDueDay), 10);
      expect(await store.get(SettingKeys.classReminderMinutes), 30);
      expect(
        await store.get(SettingKeys.feeReminderTime),
        const ClockTime(8, 0),
      );
      expect(await store.get(SettingKeys.nextReceiptNo), 1);
    });

    test('reading does not write anything', () async {
      await store.get(SettingKeys.language);
      expect(await db.select(db.settings).get(), isEmpty);
    });
  });

  group('round trips', () {
    test('enums', () async {
      await store.set(SettingKeys.language, AppLanguage.en);
      await store.set(SettingKeys.numerals, NumeralStyle.western);
      await store.set(SettingKeys.grouping, GroupingStyle.western);
      await store.set(SettingKeys.proration, ProrationRule.byDays);
      expect(await store.get(SettingKeys.language), AppLanguage.en);
      expect(await store.get(SettingKeys.numerals), NumeralStyle.western);
      expect(await store.get(SettingKeys.grouping), GroupingStyle.western);
      expect(await store.get(SettingKeys.proration), ProrationRule.byDays);
    });

    test('ints and times', () async {
      await store.set(SettingKeys.defaultDueDay, 25);
      await store.set(SettingKeys.classReminderMinutes, 45);
      await store.set(SettingKeys.feeReminderTime, const ClockTime(7, 5));
      expect(await store.get(SettingKeys.defaultDueDay), 25);
      expect(await store.get(SettingKeys.classReminderMinutes), 45);
      expect(
        await store.get(SettingKeys.feeReminderTime),
        const ClockTime(7, 5),
      );
    });

    test('setting twice overwrites instead of duplicating', () async {
      await store.set(SettingKeys.defaultDueDay, 5);
      await store.set(SettingKeys.defaultDueDay, 6);
      expect(await store.get(SettingKeys.defaultDueDay), 6);
      expect(await db.select(db.settings).get(), hasLength(1));
    });

    test('values are stored as readable text', () async {
      await store.set(SettingKeys.proration, ProrationRule.nextMonth);
      await store.set(SettingKeys.feeReminderTime, const ClockTime(7, 5));
      final rows = {
        for (final r in await db.select(db.settings).get()) r.key: r.value,
      };
      expect(rows['proration_rule'], 'nextMonth');
      expect(rows['fee_reminder_time'], '07:05');
    });

    test('reset restores the default', () async {
      await store.set(SettingKeys.defaultDueDay, 20);
      await store.reset(SettingKeys.defaultDueDay);
      expect(await store.get(SettingKeys.defaultDueDay), 10);
    });
  });

  group('robustness', () {
    test('corrupt stored values fall back to the default', () async {
      await putRaw('language', 'klingon');
      await putRaw('default_due_day', 'abc');
      await putRaw('fee_reminder_time', '25:99');
      await putRaw('class_reminder_minutes', '-5');
      expect(await store.get(SettingKeys.language), AppLanguage.bn);
      expect(await store.get(SettingKeys.defaultDueDay), 10);
      expect(
        await store.get(SettingKeys.feeReminderTime),
        const ClockTime(8, 0),
      );
      expect(await store.get(SettingKeys.classReminderMinutes), 30);
    });

    test('out-of-range values are rejected on write', () async {
      expect(
        () => store.set(SettingKeys.defaultDueDay, 0),
        throwsArgumentError,
      );
      expect(
        () => store.set(SettingKeys.defaultDueDay, 32),
        throwsArgumentError,
      );
      expect(
        () => store.set(SettingKeys.classReminderMinutes, -1),
        throwsArgumentError,
      );
      expect(
        () => store.set(SettingKeys.nextReceiptNo, 0),
        throwsArgumentError,
      );
      expect(await db.select(db.settings).get(), isEmpty);
    });
  });

  test('watch emits changes and skips duplicates', () async {
    final seen = <int>[];
    final sub = store.watch(SettingKeys.defaultDueDay).listen(seen.add);
    await pumpEventQueue();
    await store.set(SettingKeys.defaultDueDay, 15);
    await pumpEventQueue();
    await store.set(SettingKeys.defaultDueDay, 15);
    await pumpEventQueue();
    await store.set(SettingKeys.defaultDueDay, 20);
    await pumpEventQueue();
    await sub.cancel();
    expect(seen, [10, 15, 20]);
  });

  group('receipt numbers', () {
    test('start at 1 and increase by one', () async {
      expect(await store.nextReceiptNumber(), 1);
      expect(await store.nextReceiptNumber(), 2);
      expect(await store.nextReceiptNumber(), 3);
      expect(await store.get(SettingKeys.nextReceiptNo), 4);
    });

    test('rapid concurrent calls never repeat or skip a number', () async {
      final numbers = await Future.wait(
        List.generate(25, (_) => store.nextReceiptNumber()),
      );
      expect(numbers.toSet(), hasLength(25));
      expect([...numbers]..sort(), List.generate(25, (i) => i + 1));
    });

    test('a rolled-back transaction does not consume a number', () async {
      await store.nextReceiptNumber(); // 1
      await expectLater(
        db.transaction(() async {
          await store.nextReceiptNumber(); // would be 2
          throw StateError('payment failed');
        }),
        throwsStateError,
      );
      expect(await store.nextReceiptNumber(), 2);
    });

    test('ensureNextReceiptAtLeast raises but never lowers', () async {
      await store.ensureNextReceiptAtLeast(50);
      expect(await store.get(SettingKeys.nextReceiptNo), 50);
      await store.ensureNextReceiptAtLeast(10);
      expect(await store.get(SettingKeys.nextReceiptNo), 50);
      expect(await store.nextReceiptNumber(), 50);
    });
  });
}
