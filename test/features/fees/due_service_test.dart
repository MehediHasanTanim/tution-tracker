import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:tution_tracker/features/fees/domain/proration_rule.dart';

import '../../support/fee_harness.dart';

YearMonth ym(int y, int m) => YearMonth(y, m);

void main() {
  late FeeHarness h; // the clock starts on 2026-03-15

  setUp(() => h = FeeHarness());
  tearDown(() => h.close());

  Future<List<String>> months(String id) async => [
    for (final b in await h.ledger(id)) b.month,
  ];

  group('generation', () {
    test(
      'adding a student immediately yields their dues up to this month',
      () async {
        final s = await h.addStudent(joinedOn: const LocalDate(2026, 1, 5));
        expect(await months(s.id), ['2026-01', '2026-02', '2026-03']);
        final jan = await h.dueFor(s.id, ym(2026, 1));
        expect(jan.amountDue, 1500);
        expect(jan.dueDate, '2026-01-10');
      },
    );

    test('running twice yields no duplicates', () async {
      final s = await h.addStudent();
      expect(await h.dues.generateForStudent(s.id), 0);
      expect(await h.dues.generateForAll(), 0);
      expect(await months(s.id), hasLength(3));
    });

    test('concurrent runs cannot create duplicates', () async {
      final s = await h.addStudent();
      await h.db.customStatement('DELETE FROM fee_records');
      await Future.wait([
        h.dues.generateForStudent(s.id),
        h.dues.generateForStudent(s.id),
        h.dues.generateForAll(),
      ]);
      expect(await months(s.id), ['2026-01', '2026-02', '2026-03']);
    });

    test('a new month adds a due for every student', () async {
      final a = await h.addStudent(name: 'A');
      final b = await h.addStudent(name: 'B', fee: 2000);
      await h.advanceTo(ym(2026, 4));
      expect(await months(a.id), hasLength(4));
      expect((await h.dueFor(b.id, ym(2026, 4))).amountDue, 2000);
    });

    test('a student who joins this month gets one due', () async {
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 12));
      expect(await months(s.id), ['2026-03']);
    });

    test('the proration setting is honoured for the joining month', () async {
      await h.settings.set(SettingKeys.proration, ProrationRule.byDays);
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 16));
      // March has 31 days; from the 16th is 16 days: 1500 * 16 / 31 = 774.19.
      expect((await h.dueFor(s.id, ym(2026, 3))).amountDue, 774);
    });

    test('nextMonth proration waits for the following month', () async {
      await h.settings.set(SettingKeys.proration, ProrationRule.nextMonth);
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 2));
      expect(await months(s.id), isEmpty);
      await h.advanceTo(ym(2026, 4));
      expect(await months(s.id), ['2026-04']);
    });

    test('archived students get no new dues', () async {
      final s = await h.addStudent();
      await h.students.archive(s.id);
      await h.advanceTo(ym(2026, 5));
      expect(await months(s.id), ['2026-01', '2026-02', '2026-03']);
    });

    test('an unknown student is a no-op', () async {
      expect(await h.dues.generateForStudent('nobody'), 0);
    });
  });

  group('restoring an archived student', () {
    test('the months away are not billed, the current month is', () async {
      final s = await h.addStudent(); // Jan..Mar
      await h.students.archive(s.id); // archived in March
      await h.advanceTo(ym(2026, 6)); // away through to June
      await h.students.restore(s.id);
      await h.dues.generateForStudent(s.id);

      // Nothing for April or May (covered by a pause); June is billed.
      expect(await months(s.id), ['2026-01', '2026-02', '2026-03', '2026-06']);
    });

    test('restoring in the same month adds no pause', () async {
      final s = await h.addStudent();
      await h.students.archive(s.id);
      await h.students.restore(s.id);
      expect(await h.db.select(h.db.pauses).get(), isEmpty);
    });
  });

  group('fee changes', () {
    test('past dues keep their amount; later months use the new fee', () async {
      final s = await h.addStudent();
      await h.fees.changeFee(s.id, ym(2026, 4), 2000);
      expect((await h.dueFor(s.id, ym(2026, 3))).amountDue, 1500);
      await h.advanceTo(ym(2026, 5));
      expect((await h.dueFor(s.id, ym(2026, 4))).amountDue, 2000);
      expect((await h.dueFor(s.id, ym(2026, 5))).amountDue, 2000);
      expect((await h.dueFor(s.id, ym(2026, 1))).amountDue, 1500);
    });

    test(
      'a change effective in the past leaves existing dues untouched',
      () async {
        final s = await h.addStudent();
        await h.fees.changeFee(s.id, ym(2026, 2), 1800);
        for (final m in [1, 2, 3]) {
          expect((await h.dueFor(s.id, ym(2026, m))).amountDue, 1500);
        }
        // Months with no due yet use it: delete March's due and regenerate.
        await h.db.customStatement(
          "DELETE FROM fee_records WHERE month = '2026-03'",
        );
        await h.dues.generateForStudent(s.id);
        expect((await h.dueFor(s.id, ym(2026, 3))).amountDue, 1800);
      },
    );

    test('students.monthly_fee follows the fee in force this month', () async {
      final s = await h.addStudent();
      await h.fees.changeFee(s.id, ym(2026, 9), 3000); // in the future
      expect((await h.students.getById(s.id))!.monthlyFee, 1500);
      await h.fees.changeFee(s.id, ym(2026, 3), 2000);
      expect((await h.students.getById(s.id))!.monthlyFee, 2000);
    });

    test('changing the same month twice replaces the earlier change', () async {
      final s = await h.addStudent();
      await h.fees.changeFee(s.id, ym(2026, 4), 2000);
      await h.fees.changeFee(s.id, ym(2026, 4), 2500);
      final changes = await h.fees.feeChanges(s.id);
      expect(changes.where((c) => c.effectiveMonth == '2026-04'), hasLength(1));
      await h.advanceTo(ym(2026, 4));
      expect((await h.dueFor(s.id, ym(2026, 4))).amountDue, 2500);
    });

    test('a negative fee is rejected', () async {
      final s = await h.addStudent();
      expect(() => h.fees.changeFee(s.id, ym(2026, 4), -1), throwsA(anything));
    });
  });

  group('pause and resume', () {
    test('pausing stops new dues; resuming restarts them', () async {
      final s = await h.addStudent(); // Jan..Mar
      await h.fees.pauseFees(s.id, ym(2026, 4));
      expect((await h.students.getById(s.id))!.status, 'paused');

      await h.advanceTo(ym(2026, 6));
      expect(await months(s.id), ['2026-01', '2026-02', '2026-03']);

      await h.fees.resumeFees(s.id, ym(2026, 6));
      expect((await h.students.getById(s.id))!.status, 'active');
      expect(await months(s.id), ['2026-01', '2026-02', '2026-03', '2026-06']);
    });

    test('resuming from the pause month cancels it entirely', () async {
      final s = await h.addStudent();
      await h.fees.pauseFees(s.id, ym(2026, 4));
      await h.fees.resumeFees(s.id, ym(2026, 4));
      expect(await h.db.select(h.db.pauses).get(), isEmpty);
    });

    test('pausing twice, or resuming when not paused, is refused', () async {
      final s = await h.addStudent();
      await expectLater(
        h.fees.resumeFees(s.id, ym(2026, 4)),
        throwsA(anything),
      );
      await h.fees.pauseFees(s.id, ym(2026, 4));
      await expectLater(h.fees.pauseFees(s.id, ym(2026, 5)), throwsA(anything));
    });
  });

  group('batch fee overrides', () {
    test('an override lowers the due by default minus override', () async {
      final batch = await h.batches.create(
        const BatchDraft(name: 'Math', scheduleDays: [1], defaultFee: 1500),
      );
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      await h.batches.addMembers(batch.id, [s.id], const LocalDate(2026, 3, 1));
      await h.batches.setFeeOverride(batch.id, s.id, 1000);
      await h.db.customStatement('DELETE FROM fee_records');
      await h.dues.generateForStudent(s.id);
      expect((await h.dueFor(s.id, ym(2026, 3))).amountDue, 1000);
    });

    test('archived batches no longer adjust new dues', () async {
      final batch = await h.batches.create(
        const BatchDraft(name: 'Math', scheduleDays: [1], defaultFee: 1500),
      );
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      await h.batches.addMembers(batch.id, [s.id], const LocalDate(2026, 3, 1));
      await h.batches.setFeeOverride(batch.id, s.id, 1000);
      await h.batches.archive(batch.id);
      await h.db.customStatement('DELETE FROM fee_records');
      await h.dues.generateForStudent(s.id);
      expect((await h.dueFor(s.id, ym(2026, 3))).amountDue, 1500);
    });
  });

  group('credit auto-apply (S2-07)', () {
    test(
      'an advance payment for 3 future months settles them as they appear',
      () async {
        final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
        // March is owed now; pay March plus April, May and June in advance.
        await h.pay(s.id, 6000);
        expect(await h.payments.creditBalance(s.id), 4500);

        await h.advanceTo(ym(2026, 4));
        expect((await h.dueFor(s.id, ym(2026, 4))).balance, 0);
        expect(await h.payments.creditBalance(s.id), 3000);

        await h.advanceTo(ym(2026, 5));
        await h.advanceTo(ym(2026, 6));
        for (final m in [3, 4, 5, 6]) {
          final due = await h.dueFor(s.id, ym(2026, m));
          expect(due.balance, 0, reason: 'month $m');
          expect(due.paid, 1500);
        }
        expect(await h.payments.creditBalance(s.id), 0);

        // July is the first one left unpaid.
        await h.advanceTo(ym(2026, 7));
        expect((await h.dueFor(s.id, ym(2026, 7))).balance, 1500);
      },
    );

    test('credit smaller than a due part-pays it and is used up', () async {
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      await h.pay(s.id, 2000); // March 1500 + 500 credit
      await h.advanceTo(ym(2026, 4));
      final april = await h.dueFor(s.id, ym(2026, 4));
      expect(april.paid, 500);
      expect(april.balance, 1000);
      expect(await h.payments.creditBalance(s.id), 0);
    });

    test('the original payment link is kept', () async {
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      final p = await h.pay(s.id, 3000);
      await h.advanceTo(ym(2026, 4));
      final allocations = await h.payments.allocationsOf(p.payment.id);
      expect(allocations.every((a) => a.paymentId == p.payment.id), isTrue);
      expect(allocations.fold<int>(0, (a, b) => a + b.amount), 3000);
      expect(allocations.where((a) => a.feeRecordId == null), isEmpty);
    });

    test('credit stays credit when no due is open', () async {
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      await h.pay(s.id, 1500);
      await h.pay(s.id, 700);
      await h.dues.generateForStudent(s.id);
      expect(await h.payments.creditBalance(s.id), 700);
    });
  });
}
