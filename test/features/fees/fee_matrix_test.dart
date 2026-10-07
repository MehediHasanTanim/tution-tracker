// The fee engine test matrix from the technical design, section 7.7.
// "Must pass before release": each row below is one end-to-end test through
// the real repositories, finishing with a consistency check.
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/fees/data/consistency_checker.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/fees/domain/allocation.dart';
import 'package:tution_tracker/features/fees/domain/proration_rule.dart';

import '../../support/fee_harness.dart';

YearMonth ym(int y, int m) => YearMonth(y, m);

void main() {
  late FeeHarness h;

  setUp(() => h = FeeHarness()); // clock: 2026-03-15
  tearDown(() => h.close());

  Future<void> expectConsistent() async {
    expect(await ConsistencyChecker(h.db, h.settings).run(), isEmpty);
  }

  group('7.7 fee engine matrix', () {
    group('join on the 1st, 15th, 31st with each proration mode', () {
      // January 2026 has 31 days; fee 1500.
      const expected = {
        ProrationRule.fullMonth: {1: 1500, 15: 1500, 31: 1500},
        ProrationRule.byDays: {1: 1500, 15: 823, 31: 48},
        ProrationRule.nextMonth: {1: null, 15: null, 31: null},
      };
      for (final rule in ProrationRule.values) {
        for (final day in [1, 15, 31]) {
          test('${rule.name}, day $day', () async {
            await h.settings.set(SettingKeys.proration, rule);
            final s = await h.addStudent(joinedOn: LocalDate(2026, 1, day));
            final ledger = await h.ledger(s.id);
            final jan = ledger.where((b) => b.month == '2026-01');
            final want = expected[rule]![day];
            if (want == null) {
              expect(jan, isEmpty);
            } else {
              expect(jan.single.amountDue, want);
            }
            // February onward is always the full fee.
            expect(
              ledger.where((b) => b.month == '2026-02').single.amountDue,
              1500,
            );
            await expectConsistent();
          });
        }
      }
    });

    test(
      'fee change mid-year: old dues unchanged, new dues use the new fee',
      () async {
        final s = await h.addStudent();
        await h.fees.changeFee(s.id, ym(2026, 4), 2000);
        await h.advanceTo(ym(2026, 6));
        final fees = {
          for (final b in await h.ledger(s.id)) b.month: b.amountDue,
        };
        expect(fees, {
          '2026-01': 1500,
          '2026-02': 1500,
          '2026-03': 1500,
          '2026-04': 2000,
          '2026-05': 2000,
          '2026-06': 2000,
        });
        await expectConsistent();
      },
    );

    test('fee change effective in the past: existing dues untouched, only missing dues use it', () async {
      final s = await h.addStudent();
      await h.db.customStatement(
        "DELETE FROM fee_records WHERE month = '2026-03'",
      );
      await h.fees.changeFee(s.id, ym(2026, 2), 1800);
      final fees = {for (final b in await h.ledger(s.id)) b.month: b.amountDue};
      expect(fees, {'2026-01': 1500, '2026-02': 1500, '2026-03': 1800});
      await expectConsistent();
    });

    group('payment exact, partial, multi-month, over-payment', () {
      test('exact', () async {
        final s = await h.addStudent();
        final r = await h.pay(s.id, 1500);
        expect(r.lines.map((l) => l.amount), [1500]);
        expect((await h.dueFor(s.id, ym(2026, 1))).balance, 0);
        await expectConsistent();
      });

      test('partial', () async {
        final s = await h.addStudent();
        await h.pay(s.id, 400);
        expect((await h.dueFor(s.id, ym(2026, 1))).balance, 1100);
        await expectConsistent();
      });

      test('multi-month', () async {
        final s = await h.addStudent();
        final r = await h.pay(s.id, 4000);
        expect(r.lines.map((l) => l.amount), [1500, 1500, 1000]);
        expect(await h.balanceOf(s.id), 500);
        await expectConsistent();
      });

      test('over-payment', () async {
        final s = await h.addStudent();
        final r = await h.pay(s.id, 5000);
        expect(r.lines.last.isCredit, isTrue);
        expect(await h.balanceOf(s.id), 0);
        expect(await h.payments.creditBalance(s.id), 500);
        await expectConsistent();
      });
    });

    test('payment targeted at a specific month while older dues exist: targeted first, remainder to oldest', () async {
      final s = await h.addStudent();
      await h.pay(s.id, 2000, target: SpecificMonths([ym(2026, 3)]));
      expect((await h.dueFor(s.id, ym(2026, 3))).balance, 0);
      expect((await h.dueFor(s.id, ym(2026, 1))).balance, 1000);
      expect((await h.dueFor(s.id, ym(2026, 2))).balance, 1500);
      await expectConsistent();
    });

    test('edit payment amount up and down: balances consistent', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 3000)).payment;
      for (final amount in [1000, 4500, 200, 6000, 3000]) {
        await h.payments.edit(
          p.id,
          PaymentEdit(amount: amount, receivedOn: h.today),
        );
        final owed = 4500 - amount.clamp(0, 4500);
        expect(
          await h.balanceOf(s.id),
          owed,
          reason: 'after editing to $amount',
        );
        expect(
          await h.payments.creditBalance(s.id),
          amount > 4500 ? amount - 4500 : 0,
        );
        await expectConsistent();
      }
    });

    test('delete payment: dues re-open, receipt number not reused', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 3000)).payment;
      await h.payments.delete(p.id);
      expect(await h.balanceOf(s.id), 4500);
      final next = (await h.pay(s.id, 100)).payment;
      expect(next.receiptNo, p.receiptNo + 1);
      await expectConsistent();
    });

    test('pause and resume: no dues during the pause', () async {
      final s = await h.addStudent();
      await h.fees.pauseFees(s.id, ym(2026, 4));
      await h.advanceTo(ym(2026, 6));
      expect((await h.ledger(s.id)).map((b) => b.month), [
        '2026-01',
        '2026-02',
        '2026-03',
      ]);
      await h.fees.resumeFees(s.id, ym(2026, 6));
      expect((await h.ledger(s.id)).map((b) => b.month).last, '2026-06');
      expect(
        (await h.ledger(s.id)).map((b) => b.month),
        isNot(contains('2026-04')),
      );
      await expectConsistent();
    });

    test('due day 31 in February is clamped to 28 / 29', () async {
      h.now = DateTime(2028, 3, 15);
      final s = await h.addStudent(
        joinedOn: const LocalDate(2027, 1, 1),
        dueDay: 31,
      );
      final due = {for (final b in await h.ledger(s.id)) b.month: b.dueDate};
      expect(due['2027-02'], '2027-02-28');
      expect(due['2028-02'], '2028-02-29');
      expect(due['2027-04'], '2027-04-30');
      expect(due['2027-01'], '2027-01-31');
      await expectConsistent();
    });

    test('running generation twice creates no duplicates', () async {
      final s = await h.addStudent();
      await h.dues.generateForAll();
      await h.dues.generateForAll();
      expect(await h.ledger(s.id), hasLength(3));
      await expectConsistent();
    });

    test('advance credit then a new due is generated: credit is applied automatically', () async {
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      await h.pay(s.id, 4500); // March plus two months ahead
      await h.advanceTo(ym(2026, 4));
      await h.advanceTo(ym(2026, 5));
      expect((await h.dueFor(s.id, ym(2026, 4))).balance, 0);
      expect((await h.dueFor(s.id, ym(2026, 5))).balance, 0);
      expect(await h.payments.creditBalance(s.id), 0);
      await expectConsistent();
    });

    test(
      'waived month with a payment: the payment becomes credit (product rule)',
      () async {
        final s = await h.addStudent();
        final jan = await h.dueFor(s.id, ym(2026, 1));
        await h.fees.waive(jan.feeRecordId, reason: 'x');
        await h.db.customStatement(
          "DELETE FROM fee_records WHERE month != '2026-01'",
        );
        final r = await h.pay(
          s.id,
          1500,
          target: SpecificMonths([ym(2026, 1)]),
        );
        expect(r.lines.single.isCredit, isTrue);
        expect((await h.dueFor(s.id, ym(2026, 1))).paid, 0);
        expect(await h.payments.creditBalance(s.id), 1500);
        await expectConsistent();
      },
    );
  });
}
