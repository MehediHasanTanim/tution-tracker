import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/fees/data/consistency_checker.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/fees/domain/allocation.dart';

import '../../support/fee_harness.dart';

YearMonth ym(int y, int m) => YearMonth(y, m);

void main() {
  late FeeHarness h;
  late ConsistencyChecker checker;

  setUp(() {
    h = FeeHarness();
    checker = ConsistencyChecker(h.db, h.settings);
  });
  tearDown(() => h.close());

  Future<Set<ConsistencyIssueKind>> kinds() async => {
    for (final i in await checker.run()) i.kind,
  };

  group('clean data', () {
    test('an empty database passes', () async {
      expect(await checker.run(), isEmpty);
    });

    test('passes after ordinary use', () async {
      final s = await h.addStudent();
      await h.pay(s.id, 2200);
      await h.pay(s.id, 9000);
      expect(await checker.run(), isEmpty);
    });
  });

  group('corruption is reported', () {
    Future<void> raw(String sql) async {
      await h.db.customStatement('PRAGMA foreign_keys = OFF');
      await h.db.customStatement(sql);
      await h.db.customStatement('PRAGMA foreign_keys = ON');
    }

    test('an allocation left on a deleted payment', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 1500)).payment;
      await raw('UPDATE payments SET deleted_at = 1 WHERE id = \'${p.id}\'');
      expect(
        await kinds(),
        contains(ConsistencyIssueKind.allocationOnDeletedPayment),
      );
    });

    test('allocations that do not add up to the payment', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 1500)).payment;
      await raw('UPDATE payments SET amount = 1700 WHERE id = \'${p.id}\'');
      final issues = await checker.run();
      expect(
        issues.map((i) => i.kind),
        contains(ConsistencyIssueKind.allocationSumMismatch),
      );
      expect(issues.first.entityId, p.id);
    });

    test('a due paid more than it is payable', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 1500)).payment;
      await raw(
        'UPDATE fee_records SET discount = 1000 WHERE month = \'2026-01\'',
      );
      expect(p.id, isNotEmpty);
      expect(await kinds(), contains(ConsistencyIssueKind.negativeBalance));
    });

    test('a waived due that still holds a payment', () async {
      final s = await h.addStudent();
      await h.pay(s.id, 1500);
      await raw('UPDATE fee_records SET waived = 1 WHERE month = \'2026-01\'');
      expect(
        await kinds(),
        contains(ConsistencyIssueKind.waivedDueHoldsPayment),
      );
    });

    test('two monthly dues for the same student and month', () async {
      final s = await h.addStudent();
      await raw('DROP INDEX uq_fee_monthly');
      await raw(
        'INSERT INTO fee_records (id, student_id, month, kind, amount_due, discount, waived, due_date, created_at) '
        "VALUES ('dup', '${s.id}', '2026-01', 'monthly', 1500, 0, 0, '2026-01-10', 0)",
      );
      expect(await kinds(), contains(ConsistencyIssueKind.duplicateMonthlyDue));
    });

    test('an allocation that belongs to another student', () async {
      final a = await h.addStudent(name: 'A');
      final b = await h.addStudent(name: 'B');
      final p = (await h.pay(a.id, 1500)).payment;
      await raw(
        'UPDATE payment_allocations SET student_id = \'${b.id}\' WHERE payment_id = \'${p.id}\'',
      );
      expect(
        await kinds(),
        contains(ConsistencyIssueKind.allocationStudentMismatch),
      );
    });

    test('a receipt counter that is not above the issued numbers', () async {
      final s = await h.addStudent();
      await h.pay(s.id, 100);
      await h.pay(s.id, 100);
      await h.settings.set(SettingKeys.nextReceiptNo, 2);
      expect(
        await kinds(),
        contains(ConsistencyIssueKind.receiptCounterBehind),
      );
    });

    test('messages carry ids and amounts but no names', () async {
      final s = await h.addStudent(name: 'Secret Person');
      final p = (await h.pay(s.id, 1500)).payment;
      await raw('UPDATE payments SET amount = 1700 WHERE id = \'${p.id}\'');
      for (final i in await checker.run()) {
        expect(i.toString(), isNot(contains('Secret')));
      }
    });
  });

  group('randomized operations keep the ledger consistent', () {
    // The sprint's exit criterion: payments, edits and deletes in any order,
    // plus fee changes, waivers, discounts, pauses and one-time fees.
    for (final seed in [1, 2, 3, 4, 5]) {
      test('seed $seed', () async {
        final random = Random(seed);
        final students = <Student>[
          for (var i = 0; i < 4; i++)
            await h.addStudent(
              name: 'S$i',
              fee: 1000 + 250 * i,
              joinedOn: LocalDate(
                2026,
                1 + random.nextInt(3),
                1 + random.nextInt(25),
              ),
              dueDay: 1 + random.nextInt(28),
            ),
        ];
        final live = <String>[]; // ids of payments that are not deleted
        var month = 3;

        for (var step = 0; step < 80; step++) {
          final s = students[random.nextInt(students.length)];
          switch (random.nextInt(11)) {
            case 0 || 1 || 2:
              final r = await h.pay(
                s.id,
                100 + random.nextInt(4000),
                target: random.nextBool()
                    ? const OldestFirst()
                    : SpecificMonths([ym(2026, 1 + random.nextInt(month))]),
              );
              live.add(r.payment.id);
            case 3:
              if (live.isNotEmpty) {
                final id = live[random.nextInt(live.length)];
                await h.payments.edit(
                  id,
                  PaymentEdit(
                    amount: 100 + random.nextInt(5000),
                    receivedOn: h.today,
                  ),
                );
              }
            case 4:
              if (live.isNotEmpty) {
                final id = live.removeAt(random.nextInt(live.length));
                await h.payments.delete(id);
              }
            case 5:
              if (month < 8) {
                month++;
                await h.advanceTo(ym(2026, month));
              }
            case 6:
              final ledger = await h.ledger(s.id);
              if (ledger.isNotEmpty) {
                final due = ledger[random.nextInt(ledger.length)];
                if (due.waived == 0) {
                  await h.fees.waive(due.feeRecordId, reason: 'r');
                } else {
                  await h.fees.unwaive(due.feeRecordId);
                }
              }
            case 7:
              final ledger = await h.ledger(s.id);
              if (ledger.isNotEmpty) {
                final due = ledger[random.nextInt(ledger.length)];
                await h.fees.setDiscount(
                  due.feeRecordId,
                  random.nextInt(due.amountDue + 1),
                );
              }
            case 8:
              await h.fees.changeFee(
                s.id,
                ym(2026, 1 + random.nextInt(month)),
                500 + random.nextInt(3000),
              );
            case 9:
              await h.fees.addOneTimeFee(
                s.id,
                label: 'Book',
                amount: 50 + random.nextInt(900),
              );
            case 10:
              final pauses = await h.fees.watchPauses(s.id).first;
              final isPaused = pauses.any((p) => p.toMonth == null);
              if (isPaused) {
                await h.fees.resumeFees(s.id, ym(2026, month));
              } else {
                await h.fees.pauseFees(s.id, ym(2026, month));
              }
          }

          final issues = await checker.run();
          expect(issues, isEmpty, reason: 'seed $seed step $step: $issues');
        }

        // Money is conserved per student: everything paid is either applied
        // to a due or held as credit.
        for (final s in students) {
          final paid = (await h.payments.watchForStudent(s.id).first).fold<int>(
            0,
            (a, p) => a + p.amount,
          );
          final onDues = (await h.ledger(s.id))
              .fold<int>(0, (a, b) => a + b.paid);
          final credit = await h.payments.creditBalance(s.id);
          expect(onDues + credit, paid, reason: 'seed $seed');
        }
      });
    }
  });
}
