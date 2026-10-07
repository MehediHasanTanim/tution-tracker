import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/year_month.dart';

import '../../support/fee_harness.dart';
import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

Future<String> _openFeesTab(
  WidgetTester tester,
  FeeHarness h, {
  int dueDay = 20,
  String name = 'Rahim',
}) async {
  final s = await seedStudent(tester, h, dueDay: dueDay, name: name);
  await pumpHarnessApp(tester, h);
  await pushRoute(tester, '/students/${s.id}');
  await tester.tap(find.widgetWithText(Tab, 'ফি'));
  await tester.pumpAndSettle();
  return s.id;
}

Future<void> _openAdjust(WidgetTester tester, String item) async {
  await tester.tap(find.byTooltip('ফি সমন্বয়'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item));
  await tester.pumpAndSettle();
}

Future<void> _openRow(WidgetTester tester, String month, String action) async {
  await tapCentered(tester, find.text(month));
  await tester.pumpAndSettle();
  await tester.tap(find.text(action));
  await tester.pumpAndSettle();
}

Future<void> _confirmDialog(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'),
    ),
  );
  await waitFor(tester);
}

void main() {
  group('ledger', () {
    feeUiTest('shows each month with its status, amounts and running balance', (
      tester,
      h,
    ) async {
      final id = await _openFeesTab(tester, h); // due day 20: Jan, Feb overdue
      await real(tester, () => h.pay(id, 3500)); // Jan, Feb paid; Mar 500
      await tester.pumpAndSettle();

      expect(find.text('জানুয়ারি ২০২৬'), findsOneWidget);
      expect(find.text('ফেব্রুয়ারি ২০২৬'), findsOneWidget);
      expect(find.text('মার্চ ২০২৬'), findsOneWidget);
      expect(find.text('পরিশোধিত'), findsNWidgets(2));
      // March: partly paid and not yet past its due date.
      expect(find.text('আংশিক'), findsOneWidget);
      expect(
        find.textContaining('ফি ৳ ১,৫০০ · জমা ৳ ৫০০ · বাকি ৳ ১,০০০'),
        findsOneWidget,
      );
      expect(find.textContaining('এ পর্যন্ত মোট বাকি ৳ ১,০০০'), findsWidgets);
    });

    feeUiTest('overdue and not-yet-due months are told apart', (
      tester,
      h,
    ) async {
      await _openFeesTab(tester, h); // nothing paid
      expect(find.text('বিলম্বিত'), findsNWidgets(2)); // Jan 20, Feb 20 passed
      expect(find.text('বাকি'), findsWidgets); // March, due on the 20th
      expect(find.text('মোট বাকি'), findsOneWidget);
      expect(find.text('৳ ৪,৫০০'), findsWidgets);
    });

    feeUiTest(
      'the ledger total equals what the due list shows for the student',
      (tester, h) async {
        final id = await _openFeesTab(tester, h);
        await real(tester, () => h.pay(id, 2200));
        await tester.pumpAndSettle();

        final list = await real(tester, () => h.fees.watchDueList().first);
        final listed = list.single.totalBalance;
        expect(listed, 2300);
        final ledgerTotal = await real(tester, () => h.balanceOf(id));
        expect(ledgerTotal, listed);
        expect(find.text('৳ ২,৩০০'), findsWidgets);
      },
    );

    feeUiTest('a student with no dues yet says so', (tester, h) async {
      h.now = DateTime(2025, 12, 1); // before the student joins
      await _openFeesTab(tester, h);
      expect(find.text('এখনও কোনো ফি তৈরি হয়নি'), findsOneWidget);
    });

    feeUiTest('advance credit is shown', (tester, h) async {
      final id = await _openFeesTab(tester, h);
      await real(tester, () => h.pay(id, 5000)); // 4500 owed, 500 credit
      await tester.pumpAndSettle();
      expect(find.text('অগ্রিম জমা: ৳ ৫০০'), findsOneWidget);
    });
  });

  group('payment history', () {
    feeUiTest('lists payments newest first and hides deleted ones', (
      tester,
      h,
    ) async {
      final id = await _openFeesTab(tester, h);
      final first = (await real(tester, () => h.pay(id, 1000))).payment;
      await real(tester, () => h.pay(id, 2000));
      final third = (await real(tester, () => h.pay(id, 300))).payment;
      await real(tester, () => h.payments.delete(third.id));
      await tester.pumpAndSettle();

      expect(find.textContaining('রসিদ নং ২'), findsOneWidget);
      expect(find.textContaining('রসিদ নং ১'), findsOneWidget);
      expect(find.textContaining('রসিদ নং ৩'), findsNothing);
      expect(first.receiptNo, 1);
      expect(find.text('৳ ২,০০০'), findsOneWidget);
    });

    feeUiTest('shows the payment method', (tester, h) async {
      final id = await _openFeesTab(tester, h);
      await real(tester, () => h.pay(id, 1000));
      await tester.pumpAndSettle();
      expect(find.text('ক্যাশ'), findsOneWidget);
    });

    feeUiTest('deleting asks first; cancel keeps the payment', (
      tester,
      h,
    ) async {
      final id = await _openFeesTab(tester, h);
      await real(tester, () => h.pay(id, 1500));
      await tester.pumpAndSettle();

      await tapCentered(tester, find.textContaining('রসিদ নং ১'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('পেমেন্ট মুছুন'));
      await tester.pumpAndSettle();
      expect(find.text('পেমেন্ট মুছবেন?'), findsOneWidget);
      expect(find.textContaining('রসিদ নং ১ মুছে ফেললে'), findsOneWidget);
      expect(find.textContaining('রসিদ আগে শেয়ার'), findsNothing);

      await tester.tap(find.text('বাতিল'));
      await tester.pumpAndSettle();
      expect(
        await real(tester, () => h.payments.watchForStudent(id).first),
        hasLength(1),
      );
    });

    feeUiTest('confirming deletes it and the months owe again', (
      tester,
      h,
    ) async {
      final id = await _openFeesTab(tester, h);
      await real(tester, () => h.pay(id, 4500));
      await tester.pumpAndSettle();
      expect(await real(tester, () => h.balanceOf(id)), 0);

      await tapCentered(tester, find.textContaining('রসিদ নং ১'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('পেমেন্ট মুছুন'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'পেমেন্ট মুছুন'));
      await waitFor(tester);

      expect(find.text('পেমেন্ট মুছে ফেলা হয়েছে'), findsOneWidget);
      expect(await real(tester, () => h.balanceOf(id)), 4500);
      expect(find.text('কোনো পেমেন্ট নেই'), findsOneWidget);
    });

    feeUiTest('warns before deleting a payment whose receipt was shared', (
      tester,
      h,
    ) async {
      final id = await _openFeesTab(tester, h);
      final p = (await real(tester, () => h.pay(id, 1500))).payment;
      await real(tester, () => h.payments.markReceiptShared(p.id));
      await tester.pumpAndSettle();

      await tapCentered(tester, find.textContaining('রসিদ নং ১'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('পেমেন্ট মুছুন'));
      await tester.pumpAndSettle();
      expect(find.textContaining('রসিদ আগে শেয়ার করা হয়েছে'), findsOneWidget);
    });

    feeUiTest('edit opens the edit screen for that payment', (tester, h) async {
      final id = await _openFeesTab(tester, h);
      await real(tester, () => h.pay(id, 1500));
      await tester.pumpAndSettle();

      await tapCentered(tester, find.textContaining('রসিদ নং ১'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('সম্পাদনা'));
      await waitFor(tester);
      expect(find.text('পেমেন্ট সম্পাদনা'), findsOneWidget);
    });
  });

  group('waive and discount', () {
    feeUiTest(
      'waiving needs a reason, then shows as waived and stops counting',
      (tester, h) async {
        final id = await _openFeesTab(tester, h);
        await _openRow(tester, 'জানুয়ারি ২০২৬', 'মওকুফ করুন');

        // Empty reason is refused.
        await _confirmDialog(tester);
        expect(find.text('কারণ লিখুন'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextField, 'কারণ'),
          'Scholarship',
        );
        await _confirmDialog(tester);

        expect(find.text('মওকুফ'), findsOneWidget);
        expect(await real(tester, () => h.balanceOf(id)), 3000);
        final jan = await real(
          tester,
          () => h.dueFor(id, const YearMonth(2026, 1)),
        );
        final record = await real(
          tester,
          () => (h.db.select(
            h.db.feeRecords,
          )..where((f) => f.id.equals(jan.feeRecordId))).getSingle(),
        );
        expect(record.note, 'Scholarship');
        expect(find.text('৳ ৩,০০০'), findsWidgets);
      },
    );

    feeUiTest('a waiver can be undone', (tester, h) async {
      final id = await _openFeesTab(tester, h);
      await _openRow(tester, 'জানুয়ারি ২০২৬', 'মওকুফ করুন');
      await tester.enterText(find.widgetWithText(TextField, 'কারণ'), 'x');
      await _confirmDialog(tester);
      expect(await real(tester, () => h.balanceOf(id)), 3000);

      // Let the "saved" snackbar go; it would sit over the sheet's last item.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      await _openRow(tester, 'জানুয়ারি ২০২৬', 'মওকুফ বাতিল করুন');
      await waitFor(tester);
      expect(find.text('মওকুফ'), findsNothing);
      expect(await real(tester, () => h.balanceOf(id)), 4500);
    });

    feeUiTest('a discount lowers what is payable', (tester, h) async {
      final id = await _openFeesTab(tester, h);
      await _openRow(tester, 'ফেব্রুয়ারি ২০২৬', 'ছাড় দিন');
      await tester.enterText(
        find.widgetWithText(TextField, 'ছাড়ের পরিমাণ (৳)'),
        '৫০০',
      );
      await _confirmDialog(tester);

      expect(
        find.textContaining('ফি ৳ ১,০০০ · জমা ৳ ০ · বাকি ৳ ১,০০০'),
        findsOneWidget,
      );
      expect(await real(tester, () => h.balanceOf(id)), 4000);
    });

    feeUiTest('a discount larger than the fee is refused', (tester, h) async {
      final id = await _openFeesTab(tester, h);
      await _openRow(tester, 'জানুয়ারি ২০২৬', 'ছাড় দিন');
      await tester.enterText(
        find.widgetWithText(TextField, 'ছাড়ের পরিমাণ (৳)'),
        '1501',
      );
      await _confirmDialog(tester);
      expect(find.text('পরিমাণ লিখুন'), findsOneWidget);
      expect(await real(tester, () => h.balanceOf(id)), 4500);
    });
  });

  group('fee changes', () {
    feeUiTest('the new fee applies from the chosen month; past dues stay', (
      tester,
      h,
    ) async {
      final id = await _openFeesTab(tester, h);
      await _openAdjust(tester, 'মাসিক ফি পরিবর্তন');

      // Offered the fee in force, effective this month by default.
      expect(find.text('মার্চ ২০২৬'), findsWidgets);
      await tester.tap(find.byType(DropdownButtonFormField<YearMonth>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('এপ্রিল ২০২৬').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'নতুন মাসিক ফি (৳)'),
        '2000',
      );
      await _confirmDialog(tester);

      expect(find.text('ফি পরিবর্তন করা হয়েছে'), findsOneWidget);
      for (final m in [1, 2, 3]) {
        expect(
          (await real(
            tester,
            () => h.dueFor(id, YearMonth(2026, m)),
          )).amountDue,
          1500,
          reason: 'month $m',
        );
      }
      await real(tester, () => h.advanceTo(const YearMonth(2026, 4)));
      expect(
        (await real(
          tester,
          () => h.dueFor(id, const YearMonth(2026, 4)),
        )).amountDue,
        2000,
      );
    });

    feeUiTest('a fee must be entered', (tester, h) async {
      await _openFeesTab(tester, h);
      await _openAdjust(tester, 'মাসিক ফি পরিবর্তন');
      await tester.enterText(
        find.widgetWithText(TextField, 'নতুন মাসিক ফি (৳)'),
        '',
      );
      await _confirmDialog(tester);
      expect(find.text('পরিমাণ লিখুন'), findsOneWidget);
    });
  });

  group('pause and resume', () {
    feeUiTest('pausing stops new dues; the menu then offers resume', (
      tester,
      h,
    ) async {
      final id = await _openFeesTab(tester, h);
      await _openAdjust(tester, 'ফি বন্ধ রাখুন');
      expect(find.text('যে মাস থেকে বন্ধ'), findsOneWidget);
      await _confirmDialog(tester);

      expect(find.text('ফি বন্ধ করা হয়েছে'), findsOneWidget);
      final pauses = await real(tester, () => h.fees.watchPauses(id).first);
      expect(pauses.single.fromMonth, '2026-03');
      expect(pauses.single.toMonth, isNull);

      await real(tester, () => h.advanceTo(const YearMonth(2026, 6)));
      final months = (await real(
        tester,
        () => h.ledger(id),
      )).map((b) => b.month);
      expect(months, [
        '2026-01',
        '2026-02',
        '2026-03',
      ]); // March's was already made

      await tester.tap(find.byTooltip('ফি সমন্বয়'));
      await tester.pumpAndSettle();
      expect(find.text('ফি আবার চালু করুন'), findsOneWidget);
      expect(find.text('ফি বন্ধ রাখুন'), findsNothing);
    });

    feeUiTest('resuming brings dues back from the chosen month', (
      tester,
      h,
    ) async {
      final id = await _openFeesTab(tester, h);
      await real(tester, () => h.fees.pauseFees(id, const YearMonth(2026, 4)));
      await real(tester, () => h.advanceTo(const YearMonth(2026, 6)));
      await tester.pumpAndSettle();

      await _openAdjust(tester, 'ফি আবার চালু করুন');
      expect(find.text('যে মাস থেকে চালু'), findsOneWidget);
      await _confirmDialog(tester); // from the current month, June

      expect(find.text('ফি চালু করা হয়েছে'), findsOneWidget);
      final months = (await real(
        tester,
        () => h.ledger(id),
      )).map((b) => b.month);
      expect(months, ['2026-01', '2026-02', '2026-03', '2026-06']);
    });
  });

  group('one-time fees', () {
    feeUiTest('adds a labelled due that shows in the ledger and the due list', (
      tester,
      h,
    ) async {
      final id = await _openFeesTab(tester, h);
      await _openAdjust(tester, 'এককালীন ফি যোগ করুন');
      await tester.enterText(
        find.widgetWithText(TextField, 'বিবরণ (যেমন ভর্তি ফি)'),
        'Admission',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'পরিমাণ (৳)'),
        '800',
      );
      await _confirmDialog(tester);

      expect(find.text('এককালীন ফি যোগ করা হয়েছে'), findsOneWidget);
      expect(find.text('Admission · মার্চ ২০২৬'), findsOneWidget);
      final list = await real(tester, () => h.fees.watchDueList().first);
      expect(list.single.totalBalance, 4500 + 800);
      expect(await real(tester, () => h.balanceOf(id)), 5300);
    });

    feeUiTest('needs a label and an amount', (tester, h) async {
      await _openFeesTab(tester, h);
      await _openAdjust(tester, 'এককালীন ফি যোগ করুন');
      await _confirmDialog(tester);
      expect(find.text('কারণ লিখুন'), findsOneWidget);
      expect(find.text('পরিমাণ লিখুন'), findsOneWidget);
    });
  });
}
