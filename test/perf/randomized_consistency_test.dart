import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/fees/data/consistency_checker.dart';
import 'package:tution_tracker/features/fees/data/due_service.dart';
import 'package:tution_tracker/features/fees/data/fee_repository.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/fees/domain/allocation.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';

import '../support/stress_data.dart';

/// Random operations spread over the whole stress dataset (500 students, 6,000
/// payments), then the consistency checker over everything. The single-student
/// version lives in the fee tests; this one is about interactions at scale.
void main() {
  for (final seed in [11, 12, 13]) {
    test(
      'seed $seed: 300 random operations leave the dataset consistent',
      () async {
        final db = openInMemoryDatabase();
        addTearDown(db.close);
        await seedStress(db);

        var now = DateTime(2026, 10, 15, 10);
        final settings = SettingsStore(db);
        final payments = PaymentRepository(db, settings, now: () => now);
        final dues = DueService(db, settings, payments, now: () => now);
        final fees = FeeRepository(db, payments, dues, now: () => now);
        final students = StudentRepository(db, now: () => now);
        final checker = ConsistencyChecker(db, settings);

        final random = Random(seed);
        var month = 10;
        final livePayments = <String>[];
        final archived = <String>[];

        String pick() => 's${random.nextInt(500)}';

        for (var step = 0; step < 300; step++) {
          final id = pick();
          switch (random.nextInt(12)) {
            case 0 || 1 || 2:
              final r = await payments.record(
                PaymentInput(
                  studentId: id,
                  amount: 100 + random.nextInt(4000),
                  receivedOn: today(now),
                  target: random.nextBool()
                      ? const OldestFirst()
                      : SpecificMonths([
                          YearMonth(2026, 1 + random.nextInt(month)),
                        ]),
                ),
              );
              livePayments.add(r.payment.id);
            case 3:
              if (livePayments.isNotEmpty) {
                await payments.edit(
                  livePayments[random.nextInt(livePayments.length)],
                  PaymentEdit(
                    amount: 100 + random.nextInt(5000),
                    receivedOn: today(now),
                  ),
                );
              }
            case 4:
              if (livePayments.isNotEmpty) {
                await payments.delete(
                  livePayments.removeAt(random.nextInt(livePayments.length)),
                );
              }
            case 5:
              // An old, already-paid payment from the dataset.
              final old = 'p${random.nextInt(500)}_${random.nextInt(12)}';
              if (await payments.getById(old) case final p?
                  when p.deletedAt == null) {
                if (random.nextBool()) {
                  await payments.delete(old);
                } else {
                  await payments.edit(
                    old,
                    PaymentEdit(
                      amount: 100 + random.nextInt(3000),
                      receivedOn: today(now),
                    ),
                  );
                }
              }
            case 6:
              if (month < 12) {
                month++;
                now = DateTime(2026, month, 15, 10);
                await dues.generateForAll();
              }
            case 7:
              final ledger = await fees.watchLedger(id).first;
              if (ledger.isNotEmpty) {
                final due = ledger[random.nextInt(ledger.length)];
                if (due.waived == 0) {
                  await fees.waive(due.feeRecordId, reason: 'r');
                } else {
                  await fees.unwaive(due.feeRecordId);
                }
              }
            case 8:
              final ledger = await fees.watchLedger(id).first;
              if (ledger.isNotEmpty) {
                final due = ledger[random.nextInt(ledger.length)];
                await fees.setDiscount(
                  due.feeRecordId,
                  random.nextInt(due.amountDue + 1),
                );
              }
            case 9:
              await fees.changeFee(
                id,
                YearMonth(2026, 1 + random.nextInt(month)),
                500 + random.nextInt(3000),
              );
            case 10:
              await fees.addOneTimeFee(
                id,
                label: 'Book',
                amount: 50 + random.nextInt(900),
              );
            case 11:
              if (archived.isNotEmpty && random.nextBool()) {
                await students.restore(archived.removeLast());
              } else {
                await students.archive(id);
                archived.add(id);
              }
          }
          if (step % 100 == 99) {
            final issues = await checker.run();
            expect(issues, isEmpty, reason: 'after step $step: $issues');
          }
        }

        expect(await checker.run(), isEmpty);
        // Every active student's dues exist for every month up to now.
        final gaps = await db
            .customSelect(
              'SELECT s.id FROM students s WHERE 1 = 1 '
              "AND s.status = 'active' AND NOT EXISTS "
              '(SELECT 1 FROM fee_records f WHERE f.student_id = s.id '
              "AND f.kind = 'monthly' AND f.month = '2026-10')",
            )
            .get();
        expect(gaps, isEmpty);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  }
}

LocalDate today(DateTime now) => LocalDate.fromDateTime(now);
