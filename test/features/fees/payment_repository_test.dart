import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/fees/domain/allocation.dart';
import 'package:tution_tracker/features/fees/domain/payment_method.dart';

import '../../support/fee_harness.dart';

YearMonth ym(int y, int m) => YearMonth(y, m);

void main() {
  late FeeHarness
  h; // clock: 2026-03-15; a student joined 2026-01-01 owes Jan..Mar

  setUp(() => h = FeeHarness());
  tearDown(() => h.close());

  Future<int> rowCount(String table) async =>
      (await h.db.customSelect('SELECT COUNT(*) c FROM $table').getSingle())
          .read<int>('c');

  group('record', () {
    test('an exact payment settles the oldest month', () async {
      final s = await h.addStudent();
      final r = await h.pay(s.id, 1500);
      expect(r.lines, hasLength(1));
      expect(r.lines.single.amount, 1500);
      expect((await h.dueFor(s.id, ym(2026, 1))).balance, 0);
      expect((await h.dueFor(s.id, ym(2026, 2))).balance, 1500);
      expect(r.payment.receiptNo, 1);
      expect(r.payment.method, 'cash');
      expect(r.payment.receivedOn, '2026-03-15');
    });

    test('a partial payment leaves the balance visible', () async {
      final s = await h.addStudent();
      await h.pay(s.id, 600);
      final jan = await h.dueFor(s.id, ym(2026, 1));
      expect(jan.paid, 600);
      expect(jan.balance, 900);
      expect(await h.balanceOf(s.id), 4500 - 600);
    });

    test('a multi-month payment fills months in order', () async {
      final s = await h.addStudent();
      final r = await h.pay(s.id, 3000);
      expect(r.lines.map((l) => l.amount), [1500, 1500]);
      expect((await h.dueFor(s.id, ym(2026, 1))).balance, 0);
      expect((await h.dueFor(s.id, ym(2026, 2))).balance, 0);
      expect((await h.dueFor(s.id, ym(2026, 3))).balance, 1500);
    });

    test('an overpayment becomes advance credit', () async {
      final s = await h.addStudent();
      final r = await h.pay(s.id, 5000); // 4500 owed
      expect(r.lines.last.isCredit, isTrue);
      expect(r.lines.last.amount, 500);
      expect(await h.balanceOf(s.id), 0);
      expect(await h.payments.creditBalance(s.id), 500);
    });

    test(
      'a payment targeted at one month is paid first, remainder to oldest',
      () async {
        final s = await h.addStudent();
        final r = await h.pay(
          s.id,
          2000,
          target: SpecificMonths([ym(2026, 3)]),
        );
        expect(r.lines.map((l) => l.amount), [1500, 500]);
        expect((await h.dueFor(s.id, ym(2026, 3))).balance, 0);
        expect((await h.dueFor(s.id, ym(2026, 1))).balance, 1000);
        expect((await h.dueFor(s.id, ym(2026, 2))).balance, 1500);
      },
    );

    test('stores method, reference and note', () async {
      final s = await h.addStudent();
      final r = await h.payments.record(
        PaymentInput(
          studentId: s.id,
          amount: 1500,
          receivedOn: const LocalDate(2026, 3, 1),
          method: PaymentMethod.bkash,
          reference: ' TX123 ',
          note: '   ',
        ),
      );
      expect(r.payment.method, 'bkash');
      expect(r.payment.reference, 'TX123');
      expect(r.payment.note, isNull);
      expect(r.payment.receivedOn, '2026-03-01');
    });

    test('a payment against a waived month becomes credit', () async {
      final s = await h.addStudent();
      final jan = await h.dueFor(s.id, ym(2026, 1));
      await h.fees.waive(jan.feeRecordId, reason: 'hardship');
      await h.db.customStatement(
        "DELETE FROM fee_records WHERE month != '2026-01'",
      );
      final r = await h.pay(s.id, 1500, target: SpecificMonths([ym(2026, 1)]));
      expect(r.lines.single.isCredit, isTrue);
      expect(await h.payments.creditBalance(s.id), 1500);
    });

    test('rejects zero and negative amounts', () async {
      final s = await h.addStudent();
      await expectLater(h.pay(s.id, 0), throwsA(isA<PaymentException>()));
      await expectLater(h.pay(s.id, -5), throwsA(isA<PaymentException>()));
      expect(await rowCount('payments'), 0);
    });

    test('writes an audit entry without personal data', () async {
      final s = await h.addStudent(name: 'Secret Name');
      final r = await h.pay(s.id, 1500);
      final log = await (h.db.select(
        h.db.auditLog,
      )..where((a) => a.entity.equals('payment'))).getSingle();
      expect(log.entityId, r.payment.id);
      expect(log.action, 'create');
      final details = jsonDecode(log.details!) as Map<String, dynamic>;
      expect(details, {'amount': 1500, 'receipt_no': 1});
      expect(log.details, isNot(contains('Secret')));
    });
  });

  group('receipt numbers', () {
    test('are sequential from 1', () async {
      final s = await h.addStudent();
      final numbers = [
        for (var i = 0; i < 4; i++) (await h.pay(s.id, 100)).payment.receiptNo,
      ];
      expect(numbers, [1, 2, 3, 4]);
    });

    test('rapid concurrent entry leaves no gaps or repeats', () async {
      final s = await h.addStudent();
      final results = await Future.wait([
        for (var i = 0; i < 25; i++) h.pay(s.id, 100),
      ]);
      final numbers = results.map((r) => r.payment.receiptNo).toList()..sort();
      expect(numbers, List.generate(25, (i) => i + 1));
      expect(await h.settings.get(SettingKeys.nextReceiptNo), 26);
    });

    test(
      'a failure part-way leaves no rows and does not use up a number',
      () async {
        final s = await h.addStudent();
        await h.pay(s.id, 100); // receipt 1

        // An unknown student fails at the payment insert, after the receipt
        // number was already taken inside the same transaction.
        await expectLater(h.pay('no-such-student', 500), throwsA(anything));

        expect(await rowCount('payments'), 1);
        expect(await rowCount('payment_allocations'), 1);
        expect(
          await (h.db.select(h.db.auditLog)
                ..where((a) => a.entity.equals('payment')))
              .get()
              .then((l) => l.length),
          1,
        );
        expect(await h.settings.get(SettingKeys.nextReceiptNo), 2);
        expect((await h.pay(s.id, 100)).payment.receiptNo, 2);
      },
    );
  });

  group('edit', () {
    test('lowering the amount re-opens dues', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 3000)).payment; // Jan + Feb paid
      await h.payments.edit(
        p.id,
        PaymentEdit(amount: 1500, receivedOn: h.today),
      );
      expect((await h.dueFor(s.id, ym(2026, 1))).balance, 0);
      expect((await h.dueFor(s.id, ym(2026, 2))).balance, 1500);
      expect(await h.balanceOf(s.id), 3000);
    });

    test('raising the amount pays more dues', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 1500)).payment;
      await h.payments.edit(
        p.id,
        PaymentEdit(amount: 3500, receivedOn: h.today),
      );
      expect((await h.dueFor(s.id, ym(2026, 2))).balance, 0);
      expect((await h.dueFor(s.id, ym(2026, 3))).balance, 1000);
    });

    test('raising it past everything owed leaves credit', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 1500)).payment;
      await h.payments.edit(
        p.id,
        PaymentEdit(amount: 6000, receivedOn: h.today),
      );
      expect(await h.balanceOf(s.id), 0);
      expect(await h.payments.creditBalance(s.id), 1500);
    });

    test('keeps the receipt number and updates the other fields', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 1500)).payment;
      final r = await h.payments.edit(
        p.id,
        const PaymentEdit(
          amount: 1000,
          receivedOn: LocalDate(2026, 3, 2),
          method: PaymentMethod.nagad,
          reference: 'N9',
          note: 'fixed',
        ),
      );
      expect(r.payment.receiptNo, p.receiptNo);
      expect(r.payment.amount, 1000);
      expect(r.payment.receivedOn, '2026-03-02');
      expect(r.payment.method, 'nagad');
      expect(r.payment.reference, 'N9');
      expect(r.payment.note, 'fixed');
    });

    test(
      'allocations always sum to the payment amount after repeated edits',
      () async {
        final s = await h.addStudent();
        final p = (await h.pay(s.id, 1500)).payment;
        for (final amount in [700, 4000, 1500, 9000, 100]) {
          await h.payments.edit(
            p.id,
            PaymentEdit(amount: amount, receivedOn: h.today),
          );
          final sum = (await h.payments.allocationsOf(p.id))
              .fold<int>(0, (a, b) => a + b.amount);
          expect(sum, amount);
        }
      },
    );

    test('can retarget a different month', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 1500)).payment; // pays January
      await h.payments.edit(
        p.id,
        PaymentEdit(
          amount: 1500,
          receivedOn: h.today,
          target: SpecificMonths([ym(2026, 3)]),
        ),
      );
      expect((await h.dueFor(s.id, ym(2026, 1))).balance, 1500);
      expect((await h.dueFor(s.id, ym(2026, 3))).balance, 0);
    });

    test('is audited', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 1500)).payment;
      await h.payments.edit(
        p.id,
        PaymentEdit(amount: 1000, receivedOn: h.today),
      );
      final log = await (h.db.select(
        h.db.auditLog,
      )..where((a) => a.action.equals('edit'))).getSingle();
      expect(jsonDecode(log.details!), {
        'old_amount': 1500,
        'new_amount': 1000,
        'receipt_no': 1,
      });
    });

    test('rejects bad amounts, unknown and deleted payments', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 1500)).payment;
      await expectLater(
        h.payments.edit(p.id, PaymentEdit(amount: 0, receivedOn: h.today)),
        throwsA(isA<PaymentException>()),
      );
      await expectLater(
        h.payments.edit('nope', PaymentEdit(amount: 5, receivedOn: h.today)),
        throwsA(isA<PaymentException>()),
      );
      await h.payments.delete(p.id);
      await expectLater(
        h.payments.edit(p.id, PaymentEdit(amount: 5, receivedOn: h.today)),
        throwsA(isA<PaymentException>()),
      );
    });
  });

  group('delete', () {
    test('re-opens the dues it had paid', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 3000)).payment;
      expect(await h.balanceOf(s.id), 1500);
      await h.payments.delete(p.id);
      expect(await h.balanceOf(s.id), 4500);
      expect((await h.dueFor(s.id, ym(2026, 1))).paid, 0);
    });

    test('soft-deletes: the row and its receipt number stay', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 1500)).payment;
      await h.payments.delete(p.id);
      final row = (await h.payments.getById(p.id))!;
      expect(row.deletedAt, isNotNull);
      expect(row.receiptNo, 1);
      expect(await h.payments.allocationsOf(p.id), isEmpty);
    });

    test('the receipt number is never reused', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 100)).payment; // 1
      await h.payments.delete(p.id);
      expect((await h.pay(s.id, 100)).payment.receiptNo, 2);
    });

    test('is logged, including whether a receipt was shared', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 1500)).payment;
      await h.payments.markReceiptShared(p.id);
      await h.payments.delete(p.id);
      final log = await (h.db.select(
        h.db.auditLog,
      )..where((a) => a.action.equals('delete'))).getSingle();
      expect(jsonDecode(log.details!), {
        'amount': 1500,
        'receipt_no': 1,
        'receipt_shared': true,
      });
    });

    test(
      'deleted payments are hidden from the history unless asked for',
      () async {
        final s = await h.addStudent();
        final a = (await h.pay(s.id, 100)).payment;
        await h.pay(s.id, 200);
        await h.payments.delete(a.id);
        final live = await h.payments.watchForStudent(s.id).first;
        expect(live.map((p) => p.amount), [200]);
        final all = await h.payments
            .watchForStudent(s.id, includeDeleted: true)
            .first;
        expect(all, hasLength(2));
      },
    );

    test('deleting twice is harmless; an unknown id is an error', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 100)).payment;
      await h.payments.delete(p.id);
      await h.payments.delete(p.id);
      expect(await rowCount('audit_log WHERE action = \'delete\''), 1);
      await expectLater(
        h.payments.delete('nope'),
        throwsA(isA<PaymentException>()),
      );
    });

    test('existing credit settles the due that a deletion re-opens', () async {
      final s = await h.addStudent();
      final first = (await h.pay(s.id, 1500)).payment; // pays Jan
      await h.pay(s.id, 12000); // pays Feb, Mar (3000), then 9000 credit
      expect(await h.payments.creditBalance(s.id), 9000);

      await h.payments.delete(first.id); // January re-opens...
      expect(
        (await h.dueFor(s.id, ym(2026, 1))).balance,
        0,
      ); // ...credit pays it
      expect(await h.payments.creditBalance(s.id), 7500);
    });

    test('receipt shared flag is stored', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 100)).payment;
      expect(p.receiptSharedAt, isNull);
      await h.payments.markReceiptShared(p.id);
      expect((await h.payments.getById(p.id))!.receiptSharedAt, isNotNull);
    });
  });

  group('watching', () {
    test('credit balance stream follows payments', () async {
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      final seen = <int>[];
      final sub = h.payments.watchCreditBalance(s.id).listen(seen.add);
      await pumpEventQueue();
      await h.pay(s.id, 2000);
      await pumpEventQueue();
      await sub.cancel();
      expect(seen.first, 0);
      expect(seen.last, 500);
    });
  });
}
