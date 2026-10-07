import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/clock_guard.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/fees/domain/due_generation.dart';
import 'package:tution_tracker/features/fees/domain/proration_rule.dart';

import '../support/fee_harness.dart';
import '../support/fee_ui.dart';

/// Spec section 7: the edge cases not already pinned down elsewhere. The full
/// map from each case to its test is in docs/release/edge-cases.md.
void main() {
  group('case 1: a student joins mid-month', () {
    Future<void> openForm(WidgetTester tester, FeeHarness h) async {
      await pumpHarnessApp(tester, h);
      await pushRoute(tester, '/students/new');
      await waitFor(tester);
    }

    Future<void> typeFee(WidgetTester tester, String fee) async {
      await tester.enterText(find.byType(TextFormField).at(1), fee);
      await tester.pump();
    }

    feeUiTest('shows the full first-month fee before saving', (
      tester,
      h,
    ) async {
      await openForm(tester, h);
      expect(find.byKey(const Key('first-month-note')), findsNothing);
      await typeFee(tester, '3100');
      expect(find.text('প্রথম মাসের ফি: ৳ ৩,১০০'), findsOneWidget);
    });

    feeUiTest('shows the pro-rated amount when that rule is on', (
      tester,
      h,
    ) async {
      await real(
        tester,
        () => h.settings.set(SettingKeys.proration, ProrationRule.byDays),
      );
      await openForm(tester, h);
      await typeFee(tester, '3100');
      // 15 March: 17 of 31 days.
      expect(
        find.text('যোগদানের মাসের বাকি দিন অনুযায়ী ফি: ৳ ১,৭০০'),
        findsOneWidget,
      );
      // And it follows the amount as it is typed.
      await typeFee(tester, '6200');
      expect(
        find.text('যোগদানের মাসের বাকি দিন অনুযায়ী ফি: ৳ ৩,৪০০'),
        findsOneWidget,
      );
    });

    feeUiTest(
      'says there is nothing to pay this month under next-month billing',
      (tester, h) async {
        await real(
          tester,
          () => h.settings.set(SettingKeys.proration, ProrationRule.nextMonth),
        );
        await openForm(tester, h);
        await typeFee(tester, '3100');
        expect(
          find.text(
            'যোগদানের মাসের জন্য কোনো ফি নেই; বিলিং পরের মাস থেকে শুরু',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('case 7: the phone date is changed', () {
    test('only a jump back of more than a day counts', () {
      final last = DateTime(2026, 3, 15, 12);
      expect(daysWentBack(now: last, lastSeen: last), isNull);
      expect(
        daysWentBack(now: last.add(const Duration(days: 3)), lastSeen: last),
        isNull,
        reason: 'forward is normal',
      );
      expect(
        daysWentBack(
          now: last.subtract(const Duration(hours: 5)),
          lastSeen: last,
        ),
        isNull,
        reason: 'a few hours is a time zone or clock correction',
      );
      expect(
        daysWentBack(
          now: last.subtract(const Duration(days: 10)),
          lastSeen: last,
        ),
        10,
      );
      expect(daysWentBack(now: last, lastSeen: null), isNull);
    });

    feeUiTest('warns, changes nothing, and stays quiet once acknowledged', (
      tester,
      h,
    ) async {
      await seedStudent(tester, h); // data that must survive
      await real(
        tester,
        () => h.settings.set(SettingKeys.lastSeenAt, DateTime(2026, 3, 25, 10)),
      );
      await pumpHarnessApp(tester, h); // the clock says 15 March
      await waitFor(tester);

      expect(find.text('ফোনের তারিখ পিছিয়ে গেছে'), findsOneWidget);
      expect(find.textContaining('১০ দিন'), findsOneWidget);
      expect(find.textContaining('কোনো তথ্য মোছা হয়নি'), findsOneWidget);

      await tester.tap(find.text('বুঝেছি'));
      await waitFor(tester);
      expect(find.text('ফোনের তারিখ পিছিয়ে গেছে'), findsNothing);

      // Nothing was deleted or regenerated because of the date.
      final students = await real(
        tester,
        () => h.db.customSelect('SELECT COUNT(*) c FROM students').getSingle(),
      );
      expect(students.read<int>('c'), 1);

      // It does not come back on the next resume.
      for (final s in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
      await waitFor(tester);
      expect(find.text('ফোনের তারিখ পিছিয়ে গেছে'), findsNothing);
    });

    feeUiTest('moving forward in time never warns', (tester, h) async {
      await real(
        tester,
        () => h.settings.set(SettingKeys.lastSeenAt, DateTime(2026, 1, 1)),
      );
      await pumpHarnessApp(tester, h);
      await waitFor(tester);
      expect(find.text('ফোনের তারিখ পিছিয়ে গেছে'), findsNothing);
      // And the mark moved up to now.
      final seen = await real(
        tester,
        () => h.settings.get(SettingKeys.lastSeenAt),
      );
      expect(seen, h.now);
    });
  });

  group('case 13: a month with five weeks or irregular classes', () {
    test('the monthly fee is flat whatever the month looks like', () {
      final drafts = generateDues(
        studentId: 's',
        joinedOn: const LocalDate(2026, 1, 1),
        feeDueDay: 10,
        baseFee: 1500,
        upTo: const YearMonth(2026, 12),
        rule: ProrationRule.fullMonth,
      );
      // February (28 days) and five-Saturday months cost the same as any.
      expect(drafts.map((d) => d.amountDue).toSet(), {1500});
      expect(drafts, hasLength(12));
    });
  });
}
