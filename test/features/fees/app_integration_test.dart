import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/app.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';

import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

void main() {
  group('dues on app start', () {
    feeUiTest('starting the app fills in the dues every student is missing', (
      tester,
      h,
    ) async {
      // A student saved without the fee hook (as an older version would),
      // so they have no dues yet.
      final plain = StudentRepository(h.db, now: () => h.now);
      final s = await real(
        tester,
        () => plain.create(
          const StudentDraft.quick(
            name: 'Rahim',
            monthlyFee: 1500,
            joinedOn: LocalDate(2026, 1, 1),
          ),
        ),
      );
      expect(await real(tester, () => h.ledger(s.id)), isEmpty);

      await pumpHarnessApp(tester, h); // start-up runs the generator
      await waitFor(tester);

      final ledger = await real(tester, () => h.ledger(s.id));
      expect(ledger.map((b) => b.month), ['2026-01', '2026-02', '2026-03']);
    });

    feeUiTest('starting twice does not duplicate anything', (tester, h) async {
      final s = await seedStudent(tester, h);
      await pumpHarnessApp(tester, h);
      await waitFor(tester);
      expect(await real(tester, () => h.ledger(s.id)), hasLength(3));
    });

    feeUiTest('coming back to the app in a new month adds that month', (
      tester,
      h,
    ) async {
      final s = await seedStudent(tester, h);
      await pumpHarnessApp(tester, h);
      await waitFor(tester);
      expect(await real(tester, () => h.ledger(s.id)), hasLength(3));

      h.now = DateTime(2026, 4, 2, 9);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await waitFor(tester);

      final ledger = await real(tester, () => h.ledger(s.id));
      expect(ledger.map((b) => b.month).last, '2026-04');
      expect(
        (await real(
          tester,
          () => h.dueFor(s.id, const YearMonth(2026, 4)),
        )).amountDue,
        1500,
      );
    });

    feeUiTest('creating a student in the form gives them a due straight away', (
      tester,
      h,
    ) async {
      await pumpHarnessApp(tester, h);
      await goTab(tester, 'শিক্ষার্থী');
      await tester.tap(find.text('শিক্ষার্থী যোগ করুন'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'নাম *'),
        'Karim',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'মাসিক ফি (৳) *'),
        '2000',
      );
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await waitFor(tester);

      final students = await real(tester, () => h.students.list());
      final ledger = await real(tester, () => h.ledger(students.single.id));
      // Joined today (2026-03-15): one due for March.
      expect(ledger.single.month, '2026-03');
      expect(ledger.single.amountDue, 2000);
    });
  });

  group('developer menu', () {
    feeUiTest('runs the consistency check and reports a clean ledger', (
      tester,
      h,
    ) async {
      final s = await seedStudent(tester, h);
      await real(tester, () => h.pay(s.id, 2000));
      await pumpHarnessApp(tester, h);
      await goTab(tester, 'সেটিংস');

      expect(find.text('ডেভেলপার'), findsOneWidget);
      await tester.tap(find.text('হিসাব যাচাই চালান'));
      await waitFor(tester);
      expect(find.text('কোনো সমস্যা পাওয়া যায়নি'), findsOneWidget);
    });

    feeUiTest('lists problems it finds', (tester, h) async {
      final s = await seedStudent(tester, h);
      final p = (await real(tester, () => h.pay(s.id, 1500))).payment;
      await real(
        tester,
        () => h.db.customStatement(
          'UPDATE payments SET amount = 1700 WHERE id = ?',
          [p.id],
        ),
      );
      await pumpHarnessApp(tester, h);
      await goTab(tester, 'সেটিংস');
      await tester.tap(find.text('হিসাব যাচাই চালান'));
      await waitFor(tester);
      expect(find.text('১টি সমস্যা পাওয়া গেছে'), findsOneWidget);
      expect(find.textContaining('allocationSumMismatch'), findsOneWidget);
    });

    feeUiTest('is hidden in the production flavor', (tester, h) async {
      await pumpApp(tester, h.db, clock: () => h.now, flavor: AppFlavor.prod);
      await goTab(tester, 'সেটিংস');
      expect(find.text('ডেভেলপার'), findsNothing);
      expect(find.text('হিসাব যাচাই চালান'), findsNothing);
    });
  });
}
