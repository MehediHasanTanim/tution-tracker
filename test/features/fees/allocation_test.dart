import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/features/fees/domain/allocation.dart';

YearMonth ym(int y, int m) => YearMonth(y, m);

OpenDue due(String id, int month, int balance, {int day = 10}) => OpenDue(
  id: id,
  month: ym(2026, month),
  dueDate: LocalDate(2026, month, day),
  balance: balance,
);

AllocationLine line(String? id, int amount) =>
    AllocationLine(feeRecordId: id, amount: amount);

int sum(List<AllocationLine> l) => l.fold(0, (a, b) => a + b.amount);

void main() {
  final jan = due('jan', 1, 1500);
  final feb = due('feb', 2, 1500);
  final mar = due('mar', 3, 1500);

  group('oldest first', () {
    test('an exact payment settles the oldest due', () {
      expect(allocate(paymentAmount: 1500, openDues: [jan, feb]), [
        line('jan', 1500),
      ]);
    });

    test('a partial payment pays part of the oldest due', () {
      expect(allocate(paymentAmount: 600, openDues: [jan, feb]), [
        line('jan', 600),
      ]);
    });

    test('a multi-month payment fills dues in order', () {
      expect(allocate(paymentAmount: 3000, openDues: [jan, feb, mar]), [
        line('jan', 1500),
        line('feb', 1500),
      ]);
    });

    test('a payment that ends mid-due splits across dues', () {
      expect(allocate(paymentAmount: 2200, openDues: [jan, feb, mar]), [
        line('jan', 1500),
        line('feb', 700),
      ]);
    });

    test('a partly paid due only takes its remaining balance', () {
      final partial = due('jan', 1, 400);
      expect(allocate(paymentAmount: 1000, openDues: [partial, feb]), [
        line('jan', 400),
        line('feb', 600),
      ]);
    });

    test('input order does not matter; month then due date decides', () {
      expect(allocate(paymentAmount: 3000, openDues: [mar, jan, feb]), [
        line('jan', 1500),
        line('feb', 1500),
      ]);
      final late = due('b', 1, 100, day: 20);
      final early = due('a', 1, 100, day: 5);
      expect(allocate(paymentAmount: 100, openDues: [late, early]), [
        line('a', 100),
      ]);
    });

    test('dues with no balance are ignored', () {
      expect(
        allocate(
          paymentAmount: 500,
          openDues: [due('paid', 1, 0), due('neg', 2, -5), mar],
        ),
        [line('mar', 500)],
      );
    });
  });

  group('overpayment', () {
    test('the surplus becomes one advance-credit line', () {
      expect(allocate(paymentAmount: 2000, openDues: [jan]), [
        line('jan', 1500),
        line(null, 500),
      ]);
    });

    test('with no open dues the whole payment is credit', () {
      expect(allocate(paymentAmount: 1500, openDues: const []), [
        line(null, 1500),
      ]);
    });

    test('credit lines are flagged', () {
      expect(line(null, 1).isCredit, isTrue);
      expect(line('jan', 1).isCredit, isFalse);
    });
  });

  group('specific months', () {
    test('targeted month is paid first although older dues are open', () {
      expect(
        allocate(
          paymentAmount: 1500,
          openDues: [jan, feb, mar],
          target: SpecificMonths([ym(2026, 3)]),
        ),
        [line('mar', 1500)],
      );
    });

    test('the remainder after the targeted month goes to the oldest', () {
      expect(
        allocate(
          paymentAmount: 2000,
          openDues: [jan, feb, mar],
          target: SpecificMonths([ym(2026, 3)]),
        ),
        [line('mar', 1500), line('jan', 500)],
      );
    });

    test('several targeted months are paid oldest-first among themselves', () {
      expect(
        allocate(
          paymentAmount: 3500,
          openDues: [jan, feb, mar],
          target: SpecificMonths([ym(2026, 3), ym(2026, 2)]),
        ),
        [line('feb', 1500), line('mar', 1500), line('jan', 500)],
      );
    });

    test('a targeted month that is not open is ignored', () {
      expect(
        allocate(
          paymentAmount: 1000,
          openDues: [jan],
          target: SpecificMonths([ym(2026, 5)]),
        ),
        [line('jan', 1000)],
      );
    });

    test('a targeted month that is already paid does not eat the payment', () {
      expect(
        allocate(
          paymentAmount: 500,
          openDues: [due('paid', 2, 0), jan],
          target: SpecificMonths([ym(2026, 2)]),
        ),
        [line('jan', 500)],
      );
    });

    test('overpaying a targeted set spills to others then credit', () {
      expect(
        allocate(
          paymentAmount: 5000,
          openDues: [jan, feb],
          target: SpecificMonths([ym(2026, 2)]),
        ),
        [line('feb', 1500), line('jan', 1500), line(null, 2000)],
      );
    });
  });

  group('waived months', () {
    test(
      'a waived due (balance 0) is skipped and the payment becomes credit',
      () {
        final waived = due('jan', 1, 0);
        expect(
          allocate(
            paymentAmount: 1500,
            openDues: [waived],
            target: SpecificMonths([ym(2026, 1)]),
          ),
          [line(null, 1500)],
        );
      },
    );
  });

  group('validation', () {
    test('rejects zero and negative payments', () {
      expect(
        () => allocate(paymentAmount: 0, openDues: [jan]),
        throwsArgumentError,
      );
      expect(
        () => allocate(paymentAmount: -1, openDues: [jan]),
        throwsArgumentError,
      );
    });
  });

  test('property: lines always sum to the payment, never exceed a balance', () {
    final random = Random(42);
    for (var i = 0; i < 500; i++) {
      final dues = [
        for (var m = 1; m <= random.nextInt(8) + 1; m++)
          due('d$m', m, random.nextInt(3000)),
      ];
      final amount = random.nextInt(9000) + 1;
      final target = random.nextBool()
          ? const OldestFirst()
          : SpecificMonths([ym(2026, random.nextInt(8) + 1)]);
      final lines = allocate(
        paymentAmount: amount,
        openDues: dues,
        target: target,
      );

      expect(sum(lines), amount, reason: 'iteration $i');
      expect(lines.every((l) => l.amount > 0), isTrue);
      expect(lines.where((l) => l.isCredit).length, lessThanOrEqualTo(1));
      for (final l in lines.where((l) => !l.isCredit)) {
        final d = dues.firstWhere((d) => d.id == l.feeRecordId);
        expect(l.amount, lessThanOrEqualTo(d.balance));
      }
      // Credit only exists when every open due is fully covered.
      if (lines.any((l) => l.isCredit)) {
        final covered = {for (final l in lines) l.feeRecordId: l.amount};
        for (final d in dues.where((d) => d.balance > 0)) {
          expect(covered[d.id], d.balance);
        }
      }
    }
  });
}
