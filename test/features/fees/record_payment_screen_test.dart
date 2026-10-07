import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';

import '../../support/fee_harness.dart';
import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

Finder _amountField() => find.widgetWithText(TextField, 'পরিমাণ (৳) *');

Future<List<Payment>> _payments(WidgetTester tester, FeeHarness h) =>
    real(tester, () => h.db.select(h.db.payments).get());

/// Opens the pay screen for a student who owes January to March (৳ 4,500).
Future<String> _openPay(WidgetTester tester, FeeHarness h) async {
  final s = await seedStudent(tester, h);
  await pumpHarnessApp(tester, h);
  await pushRoute(tester, '/fees/pay/${s.id}');
  return s.id;
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'));
  await waitFor(tester);
}

Future<void> _done(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'ঠিক আছে'));
  await tester.pumpAndSettle();
}

void main() {
  group('recording a payment', () {
    feeUiTest(
      'the amount is prefilled with the balance, so one tap saves a full payment',
      (tester, h) async {
        final id = await _openPay(tester, h);
        expect(
          tester.widget<TextField>(_amountField()).controller!.text,
          '4500',
        );
        expect(find.text('মোট বাকি: ৳ ৪,৫০০'), findsOneWidget);

        await _save(tester);

        // Confirmation: receipt number and the allocation breakdown.
        expect(find.text('পেমেন্ট সংরক্ষিত হয়েছে'), findsOneWidget);
        expect(find.text('রসিদ নং ১'), findsOneWidget);
        await _done(tester);

        final p = (await _payments(tester, h)).single;
        expect(p.amount, 4500);
        expect(p.method, 'cash');
        expect(p.receivedOn, '2026-03-15');
        expect(await real(tester, () => h.balanceOf(id)), 0);
        expect(find.byType(NavigationBar), findsOneWidget); // back on a tab
      },
    );

    feeUiTest('a partial payment shows its breakdown and is saved as such', (
      tester,
      h,
    ) async {
      final id = await _openPay(tester, h);
      await tester.enterText(_amountField(), '600');
      await tester.pump();

      expect(find.text('যেভাবে প্রয়োগ হবে'), findsOneWidget);
      expect(find.text('জানুয়ারি ২০২৬'), findsOneWidget);
      expect(find.text('৳ ৬০০'), findsOneWidget);

      await _save(tester);
      await _done(tester);
      expect((await _payments(tester, h)).single.amount, 600);
      expect(
        (await real(
          tester,
          () => h.dueFor(id, const YearMonth(2026, 1)),
        )).balance,
        900,
      );
    });

    feeUiTest('Bangla digits typed in the amount are understood', (
      tester,
      h,
    ) async {
      await _openPay(tester, h);
      await tester.enterText(_amountField(), '১৫০০');
      await tester.pump();
      expect(tester.widget<TextField>(_amountField()).controller!.text, '1500');
      await _save(tester);
      await _done(tester);
      expect((await _payments(tester, h)).single.amount, 1500);
    });

    feeUiTest(
      'a multi-month payment: the preview, the confirmation and the database agree',
      (tester, h) async {
        final id = await _openPay(tester, h);
        await tester.enterText(_amountField(), '3000');
        await tester.pump();

        // The preview card lists two months.
        expect(find.text('জানুয়ারি ২০২৬'), findsOneWidget);
        expect(find.text('ফেব্রুয়ারি ২০২৬'), findsOneWidget);
        expect(find.text('মার্চ ২০২৬'), findsNothing);
        expect(find.text('৳ ১,৫০০'), findsNWidgets(2));

        await _save(tester);
        // The confirmation dialog repeats the same breakdown.
        expect(
          find.text('জানুয়ারি ২০২৬'),
          findsNWidgets(2),
        ); // preview + dialog
        await _done(tester);

        // What was stored is what was shown.
        final payment = (await _payments(tester, h)).single;
        final lines = await real(
          tester,
          () => h.payments.allocationsOf(payment.id),
        );
        expect(lines.map((a) => a.amount), [1500, 1500]);
        expect(
          (await real(
            tester,
            () => h.dueFor(id, const YearMonth(2026, 3)),
          )).balance,
          1500,
        );
      },
    );

    feeUiTest('choosing a month pays it first, the rest oldest first', (
      tester,
      h,
    ) async {
      await _openPay(tester, h);
      await tester.enterText(_amountField(), '2000');
      await tester.tap(find.widgetWithText(FilterChip, 'মার্চ ২০২৬ · ৳ ১,৫০০'));
      await tester.pump();

      // Preview order: March (chosen), then January for the remainder.
      final rows = [
        for (final t in tester.widgetList<Text>(find.byType(Text)))
          if (const {'জানুয়ারি ২০২৬', 'মার্চ ২০২৬'}.contains(t.data)) t.data,
      ];
      expect(rows, ['মার্চ ২০২৬', 'জানুয়ারি ২০২৬']);
      expect(find.text('৳ ৫০০'), findsOneWidget);

      await _save(tester);
      await _done(tester);
      final payment = (await _payments(tester, h)).single;
      final lines = await real(
        tester,
        () => h.payments.allocationsOf(payment.id),
      );
      expect(lines.map((a) => a.amount).toList()..sort(), [500, 1500]);
    });

    feeUiTest('an overpayment shows advance credit', (tester, h) async {
      final id = await _openPay(tester, h);
      await tester.enterText(_amountField(), '5000');
      await tester.pump();
      expect(find.text('অগ্রিম জমা'), findsOneWidget);
      expect(find.text('৳ ৫০০'), findsOneWidget);
      await _save(tester);
      await _done(tester);
      expect(await real(tester, () => h.payments.creditBalance(id)), 500);
    });

    feeUiTest('method, reference and note are saved', (tester, h) async {
      await _openPay(tester, h);
      await tapCentered(tester, find.widgetWithText(ChoiceChip, 'বিকাশ'));
      await tester.enterText(
        find.widgetWithText(TextField, 'ট্রানজ্যাকশন আইডি / রেফারেন্স'),
        'TX123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'নোট'),
        'Rahim paid by bKash',
      );
      await _save(tester);
      await _done(tester);
      final p = (await _payments(tester, h)).single;
      expect(p.method, 'bkash');
      expect(p.reference, 'TX123');
      expect(p.note, 'Rahim paid by bKash');
    });

    feeUiTest('an empty amount shows an error and saves nothing', (
      tester,
      h,
    ) async {
      await _openPay(tester, h);
      await tester.enterText(_amountField(), '');
      await tester.pump();
      await _save(tester);
      expect(find.text('পরিমাণ লিখুন'), findsOneWidget);
      expect(await _payments(tester, h), isEmpty);

      await tester.enterText(_amountField(), '0');
      await _save(tester);
      expect(await _payments(tester, h), isEmpty);
    });

    feeUiTest('shows the date it will be recorded under', (tester, h) async {
      await _openPay(tester, h);
      expect(find.text('১৫ মার্চ ২০২৬'), findsOneWidget);
    });

    feeUiTest('a student who owes nothing starts with an empty amount', (
      tester,
      h,
    ) async {
      final s = await seedStudent(tester, h);
      await real(tester, () => h.pay(s.id, 4500));
      await pumpHarnessApp(tester, h);
      await pushRoute(tester, '/fees/pay/${s.id}');
      expect(tester.widget<TextField>(_amountField()).controller!.text, '');
      expect(find.text('মোট বাকি: ৳ ০'), findsOneWidget);
    });
  });

  group('editing a payment', () {
    feeUiTest('loads the payment and re-allocates when the amount changes', (
      tester,
      h,
    ) async {
      final s = await seedStudent(tester, h);
      final p = (await real(tester, () => h.pay(s.id, 3000))).payment;
      await pumpHarnessApp(tester, h);
      await pushRoute(tester, '/fees/payments/${p.id}/edit');

      expect(find.text('পেমেন্ট সম্পাদনা'), findsOneWidget);
      expect(tester.widget<TextField>(_amountField()).controller!.text, '3000');
      // The preview treats this payment as not yet made: Jan and Feb again.
      expect(find.text('জানুয়ারি ২০২৬'), findsOneWidget);
      expect(find.text('ফেব্রুয়ারি ২০২৬'), findsOneWidget);

      await tester.enterText(_amountField(), '1500');
      await _save(tester);
      await _done(tester);

      final edited = (await _payments(tester, h)).single;
      expect(edited.amount, 1500);
      expect(edited.receiptNo, p.receiptNo);
      expect(
        (await real(
          tester,
          () => h.dueFor(s.id, const YearMonth(2026, 2)),
        )).balance,
        1500,
      );
    });

    feeUiTest('warns when a receipt for this payment was shared', (
      tester,
      h,
    ) async {
      final s = await seedStudent(tester, h);
      final p = (await real(tester, () => h.pay(s.id, 1500))).payment;
      await real(tester, () => h.payments.markReceiptShared(p.id));
      await pumpHarnessApp(tester, h);
      await pushRoute(tester, '/fees/payments/${p.id}/edit');
      expect(find.textContaining('রসিদ আগে শেয়ার করা হয়েছে'), findsOneWidget);
    });

    feeUiTest('no warning when no receipt was shared', (tester, h) async {
      final s = await seedStudent(tester, h);
      final p = (await real(tester, () => h.pay(s.id, 1500))).payment;
      await pumpHarnessApp(tester, h);
      await pushRoute(tester, '/fees/payments/${p.id}/edit');
      expect(find.textContaining('রসিদ আগে শেয়ার করা হয়েছে'), findsNothing);
    });

    feeUiTest('an unknown payment shows a not-found message', (
      tester,
      h,
    ) async {
      await pumpHarnessApp(tester, h);
      await pushRoute(tester, '/fees/payments/nope/edit');
      expect(find.text('কোনো শিক্ষার্থী মেলেনি'), findsOneWidget);
    });
  });

  test('PaymentException is exported for callers', () {
    expect(const PaymentException('x').message, 'x');
  });
}
