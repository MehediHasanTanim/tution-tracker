import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/platform/url_launcher_service.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';

import '../../support/fee_harness.dart';
import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

class _Launcher implements UrlLauncherService {
  final opened = <String>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri.toString());
    return true;
  }
}

Future<void> _open(
  WidgetTester tester,
  FeeHarness h, {
  UrlLauncherService? launcher,
}) async {
  await pumpApp(
    tester,
    h.db,
    clock: () => h.now,
    overrides: [
      if (launcher != null) urlLauncherProvider.overrideWithValue(launcher),
    ],
  );
  await goTab(tester, 'ফি');
}

void main() {
  group('due list', () {
    feeUiTest('shows an all-clear state when nobody owes anything', (
      tester,
      h,
    ) async {
      await _open(tester, h);
      expect(find.text('কারও কোনো বাকি নেই'), findsOneWidget);
      expect(find.text('সব ফি আদায় হয়েছে'), findsOneWidget);
    });

    feeUiTest('lists who owes what with a totals header', (tester, h) async {
      await seedStudent(tester, h, name: 'Rahim'); // Jan..Mar = 4500
      await seedStudent(tester, h, name: 'Karim', fee: 2000); // 6000
      await _open(tester, h);

      expect(find.text('৳ ১০,৫০০'), findsOneWidget); // total
      expect(find.text('২ জন বাকি'), findsOneWidget);
      expect(find.text('৳ ৪,৫০০'), findsOneWidget);
      expect(find.text('৳ ৬,০০০'), findsOneWidget);
      expect(find.textContaining('৩ মাস বাকি'), findsNWidgets(2));
    });

    feeUiTest('overdue rows show days late; the rest show the due date', (
      tester,
      h,
    ) async {
      await seedStudent(tester, h, name: 'Late'); // oldest due Jan 10: 64 days
      await seedStudent(
        tester,
        h,
        name: 'OnTime',
        joinedOn: const LocalDate(2026, 3, 1),
        dueDay: 20,
      );
      await _open(tester, h);
      expect(find.textContaining('৬৪ দিন বিলম্ব'), findsOneWidget);
      expect(find.textContaining('শেষ তারিখ ২০ মার্চ ২০২৬'), findsOneWidget);
    });

    feeUiTest('sorts by overdue days by default, or by amount', (
      tester,
      h,
    ) async {
      await seedStudent(tester, h, name: 'SmallButOld', fee: 100);
      await seedStudent(
        tester,
        h,
        name: 'BigButNew',
        fee: 9000,
        joinedOn: const LocalDate(2026, 3, 1),
        dueDay: 12,
      );
      await _open(tester, h);

      List<String> order() => [
        for (final t in tester.widgetList<ListTile>(find.byType(ListTile)))
          ((t.title as Text).data ?? ''),
      ];
      expect(order(), ['SmallButOld', 'BigButNew']);

      await tester.tap(find.widgetWithText(Chip, 'বিলম্ব অনুযায়ী'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('পরিমাণ অনুযায়ী').last);
      await tester.pumpAndSettle();
      expect(order(), ['BigButNew', 'SmallButOld']);
    });

    feeUiTest('the overdue and due-this-week filters narrow the list', (
      tester,
      h,
    ) async {
      await seedStudent(tester, h, name: 'Late');
      await seedStudent(
        tester,
        h,
        name: 'Soon',
        joinedOn: const LocalDate(2026, 3, 1),
        dueDay: 18,
      );
      await seedStudent(
        tester,
        h,
        name: 'Later',
        joinedOn: const LocalDate(2026, 3, 1),
        dueDay: 28,
      );
      await _open(tester, h);
      expect(find.byType(ListTile), findsNWidgets(3));

      await tester.tap(find.widgetWithText(ChoiceChip, 'বিলম্বিত'));
      await tester.pumpAndSettle();
      expect(find.text('Late'), findsOneWidget);
      expect(find.text('Soon'), findsNothing);

      await tester.tap(find.widgetWithText(ChoiceChip, 'এই সপ্তাহে'));
      await tester.pumpAndSettle();
      // Late also has the March due (due Mar 10, already past), so only
      // dues from today to six days ahead count: Soon (Mar 18).
      expect(find.text('Soon'), findsOneWidget);
      expect(find.text('Later'), findsNothing);
    });

    feeUiTest('the batch filter shows only that batch\'s students', (
      tester,
      h,
    ) async {
      final inBatch = await seedStudent(tester, h, name: 'In Batch');
      await seedStudent(tester, h, name: 'Outside');
      final batch = await real(
        tester,
        () => h.batches.create(
          const BatchDraft(name: 'Math 9', scheduleDays: [1], defaultFee: 1500),
        ),
      );
      await real(
        tester,
        () => h.batches.addMembers(batch.id, [inBatch.id], h.today),
      );
      await _open(tester, h);

      await tester.tap(find.widgetWithText(Chip, 'ব্যাচ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Math 9').last);
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.text('In Batch'), findsOneWidget);
      expect(find.text('Outside'), findsNothing);
    });

    feeUiTest('a row opens the payment screen in one tap', (tester, h) async {
      await seedStudent(tester, h, name: 'Rahim');
      await _open(tester, h);
      await tester.tap(find.text('Rahim'));
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.text('পেমেন্ট নিন'), findsWidgets);
      expect(find.text('মোট বাকি: ৳ ৪,৫০০'), findsOneWidget);
    });

    feeUiTest('the call button dials the guardian', (tester, h) async {
      final s = await seedStudent(tester, h, name: 'Rahim');
      await real(
        tester,
        () => h.db.customStatement(
          "UPDATE students SET guardian_phone = '01712345678' WHERE id = '${s.id}'",
        ),
      );
      final launcher = _Launcher();
      await _open(tester, h, launcher: launcher);
      await tester.tap(find.byTooltip('কল'));
      await tester.pump();
      expect(launcher.opened, ['tel:+8801712345678']);
    });

    feeUiTest('the call button is disabled without a phone number', (
      tester,
      h,
    ) async {
      await seedStudent(tester, h, name: 'Rahim');
      await _open(tester, h);
      expect(
        tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.call))
            .onPressed,
        isNull,
      );
    });

    feeUiTest('20 students: the list and header match the real balances', (
      tester,
      h,
    ) async {
      var expectedTotal = 0;
      for (var i = 0; i < 20; i++) {
        final fee = 1000 + 100 * i;
        await seedStudent(
          tester,
          h,
          name: 'Student ${i.toString().padLeft(2, '0')}',
          fee: fee,
        );
        expectedTotal += 3 * fee;
      }
      // A few payments of different shapes.
      final all = await real(tester, () => h.students.list());
      await real(tester, () => h.pay(all[0].id, 3000));
      await real(tester, () => h.pay(all[1].id, 400));
      await real(tester, () => h.pay(all[2].id, 99999));
      expectedTotal -= 3000 + 400 + (3 * all[2].monthlyFee);

      await _open(tester, h);
      final list = await real(tester, () => h.fees.watchDueList().first);
      expect(list.fold<int>(0, (s, e) => s + e.totalBalance), expectedTotal);
      for (final e in list) {
        expect(
          e.totalBalance,
          await real(tester, () => h.balanceOf(e.student.id)),
        );
      }

      // Student 00 paid exactly what they owed and student 02 overpaid, so
      // 18 of the 20 still owe something.
      expect(list, hasLength(18));

      // The header shows the same grand total, in Bangla digits.
      final grand = formatTaka(
        Taka(expectedTotal),
        numerals: NumeralStyle.bangla,
        grouping: GroupingStyle.lakh,
      );
      expect(find.text(grand), findsOneWidget);
      expect(find.text('১৮ জন বাকি'), findsOneWidget);
    });
  });
}
