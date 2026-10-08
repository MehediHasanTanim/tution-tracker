import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/settings/setting_key.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/fees/domain/proration_rule.dart';

import '../../support/fee_harness.dart';
import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

Future<void> _open(WidgetTester tester, FeeHarness h) async {
  await pumpHarnessApp(tester, h);
  await goTab(tester, 'সেটিংস');
  await waitFor(tester);
}

Future<T> _stored<T>(WidgetTester tester, FeeHarness h, SettingKey<T> key) =>
    real(tester, () => h.settings.get<T>(key));

void main() {
  feeUiTest('shows every setting with its current value', (tester, h) async {
    await _open(tester, h);
    expect(find.text('ভাষা'), findsOneWidget);
    expect(find.text('সংখ্যার ধরন'), findsOneWidget);
    expect(find.text('টাকার কমা'), findsOneWidget);
    expect(find.text('থিম'), findsOneWidget);
    expect(find.text('নতুন শিক্ষার্থীর ফি আদায়ের দিন'), findsOneWidget);
    expect(find.text('প্রতি মাসের ১০ তারিখ'), findsOneWidget);
    expect(find.text('পুরো মাসের ফি'), findsOneWidget);
    expect(
      find.text('সংস্করণ ১.০.০'),
      findsOneWidget,
    ); // digits follow the setting
  });

  feeUiTest('the privacy note is in the app', (tester, h) async {
    await _open(tester, h);
    await tester.scrollUntilVisible(
      find.text('সহায়তা ও গোপনীয়তা'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('আপনার তথ্য এই ফোনেই থাকে। নিয়মিত ব্যাকআপ নিন।'),
      findsWidgets,
    );
  });

  feeUiTest('digits change at once and are remembered', (tester, h) async {
    await _open(tester, h);
    await tester.tap(find.text('ইংরেজি (123)'));
    await waitFor(tester);

    expect(
      await _stored<NumeralStyle>(tester, h, SettingKeys.numerals),
      NumeralStyle.western,
    );
    // The screen itself switched immediately.
    expect(find.text('প্রতি মাসের 10 তারিখ'), findsOneWidget);

    // And it survives restarting the app.
    await tester.pumpWidget(const SizedBox());
    await _open(tester, h);
    expect(find.text('প্রতি মাসের 10 তারিখ'), findsOneWidget);
  });

  feeUiTest('money grouping changes how amounts read everywhere', (
    tester,
    h,
  ) async {
    await seedStudent(
      tester,
      h,
      fee: 125000,
      joinedOn: const LocalDate(2026, 3, 1),
    );
    await pumpHarnessApp(tester, h);
    await goTab(tester, 'ফি');
    await waitFor(tester);
    expect(find.text('৳ ১,২৫,০০০'), findsWidgets); // lakh style

    await goTab(tester, 'সেটিংস');
    await tapCentered(tester, find.textContaining('মিলিয়ন'));
    await waitFor(tester);
    await goTab(tester, 'ফি');
    await waitFor(tester);
    expect(find.text('৳ ১২৫,০০০'), findsWidgets);
    expect(find.text('৳ ১,২৫,০০০'), findsNothing);
  });

  feeUiTest('the theme applies at once', (tester, h) async {
    await _open(tester, h);
    ThemeMode mode() =>
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;
    expect(mode(), ThemeMode.system);

    await tester.tap(find.text('গাঢ়'));
    await waitFor(tester);
    expect(mode(), ThemeMode.dark);

    await tester.tap(find.text('হালকা'));
    await waitFor(tester);
    expect(mode(), ThemeMode.light);
    expect(
      await _stored<AppThemeMode>(tester, h, SettingKeys.themeMode),
      AppThemeMode.light,
    );
  });

  feeUiTest('the default due day is chosen from the days of the month', (
    tester,
    h,
  ) async {
    await _open(tester, h);
    await tapCentered(tester, find.text('নতুন শিক্ষার্থীর ফি আদায়ের দিন'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('২৫'),
      100,
      scrollable: find
          .descendant(
            of: find.byType(SimpleDialog),
            matching: find.byType(Scrollable),
          )
          .last,
    );
    await tester.ensureVisible(find.text('২৫'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('২৫'));
    await waitFor(tester);

    expect(await _stored<int>(tester, h, SettingKeys.defaultDueDay), 25);
    expect(find.text('প্রতি মাসের ২৫ তারিখ'), findsOneWidget);
  });

  feeUiTest('the proration rule is used for the next student added', (
    tester,
    h,
  ) async {
    await _open(tester, h);
    await tapCentered(tester, find.text('যোগদানের মাসের ফি'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('দিন হিসাবে আনুপাতিক'));
    await waitFor(tester);
    expect(
      await _stored<ProrationRule>(tester, h, SettingKeys.proration),
      ProrationRule.byDays,
    );

    // Close the app first: writing students while screens are watching them
    // stalls under fake time (a limit of the test harness, not of the app).
    await tester.pumpWidget(const SizedBox());

    // A student joining on 15 March pays for 17 of 31 days.
    final s = await seedStudent(
      tester,
      h,
      fee: 3100,
      joinedOn: const LocalDate(2026, 3, 15),
    );
    final ledger = await real(tester, () => h.ledger(s.id));
    final march = ledger.firstWhere((b) => b.month == '2026-03');
    expect(march.amountDue, 1700);
  });

  feeUiTest('opens reminders, templates and backup', (tester, h) async {
    await _open(tester, h);
    for (final (entry, title) in [
      ('রিমাইন্ডার', 'রিমাইন্ডার'),
      ('মেসেজ টেমপ্লেট', 'মেসেজ টেমপ্লেট · ফি-র রিমাইন্ডার'),
      ('ব্যাকআপ ও রিস্টোর', 'ব্যাকআপ ও রিস্টোর'),
    ]) {
      await tapCentered(tester, find.text(entry).first);
      await waitFor(tester);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(title)),
        findsOneWidget,
        reason: entry,
      );
      await tester.tap(find.byType(BackButton));
      await waitFor(tester);
    }
  });

  feeUiTest('text size changes at once and is remembered', (tester, h) async {
    await _open(tester, h);
    double sizeOf(String text) => tester.getSize(find.text(text)).height;

    final before = sizeOf('লেখার আকার');
    await tapCentered(tester, find.text('অনেক বড়'));
    await waitFor(tester);

    expect(
      await _stored<AppFontSize>(tester, h, SettingKeys.fontSize),
      AppFontSize.extraLarge,
    );
    expect(sizeOf('লেখার আকার'), greaterThan(before * 1.2));
  });

  feeUiTest('Bangla dates are shown after choosing them', (tester, h) async {
    await _open(tester, h);
    await tapCentered(tester, find.text('বাংলা তারিখও দেখান'));
    await waitFor(tester);

    expect(
      await _stored<CalendarStyle>(tester, h, SettingKeys.calendar),
      CalendarStyle.bangla,
    );
    // The Today header carries the Bangla date: 15 March 2026 is 1 Choitro.
    await goTab(tester, 'হোম');
    await waitFor(tester);
    expect(find.textContaining('১ চৈত্র ১৪৩২'), findsOneWidget);
  });
}
