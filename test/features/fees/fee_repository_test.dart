import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/features/fees/data/fee_repository.dart';
import 'package:tution_tracker/features/fees/domain/allocation.dart';
import 'package:tution_tracker/features/fees/domain/fee_status.dart';

import '../../support/fee_harness.dart';

YearMonth ym(int y, int m) => YearMonth(y, m);

void main() {
  late FeeHarness
  h; // clock 2026-03-15; students joined 2026-01-01 owe Jan..Mar

  setUp(() => h = FeeHarness());
  tearDown(() => h.close());

  FeeStatus statusFor(FeeBalance b) => _status(b, h.today);

  group('waive', () {
    test('zeroes the balance, shows as waived and keeps the reason', () async {
      final s = await h.addStudent();
      final jan = await h.dueFor(s.id, ym(2026, 1));
      await h.fees.waive(jan.feeRecordId, reason: '  scholarship  ');
      final after = await h.dueFor(s.id, ym(2026, 1));
      expect(after.balance, 0);
      expect(statusFor(after), FeeStatus.waived);
      final record = await (h.db.select(
        h.db.feeRecords,
      )..where((f) => f.id.equals(jan.feeRecordId))).getSingle();
      expect(record.note, 'scholarship');
      expect(await h.balanceOf(s.id), 3000);
    });

    test(
      'money already paid against it becomes credit and settles other dues',
      () async {
        final s = await h.addStudent();
        await h.pay(s.id, 1500); // pays January
        final jan = await h.dueFor(s.id, ym(2026, 1));
        await h.fees.waive(jan.feeRecordId, reason: 'hardship');

        // The 1500 became credit and immediately paid February.
        expect((await h.dueFor(s.id, ym(2026, 1))).paid, 0);
        expect((await h.dueFor(s.id, ym(2026, 2))).balance, 0);
        expect(await h.payments.creditBalance(s.id), 0);
      },
    );

    test('credit that no due can take stays as credit', () async {
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      await h.pay(s.id, 1500);
      final mar = await h.dueFor(s.id, ym(2026, 3));
      await h.fees.waive(mar.feeRecordId, reason: 'x');
      expect(await h.payments.creditBalance(s.id), 1500);
    });

    test('waiving twice is harmless; unknown dues are refused', () async {
      final s = await h.addStudent();
      final jan = await h.dueFor(s.id, ym(2026, 1));
      await h.fees.waive(jan.feeRecordId, reason: 'a');
      await h.fees.waive(jan.feeRecordId, reason: 'b');
      expect(
        await h.db
            .customSelect(
              "SELECT COUNT(*) c FROM audit_log WHERE action = 'waive'",
            )
            .getSingle()
            .then((r) => r.read<int>('c')),
        1,
      );
      await expectLater(
        h.fees.waive('nope', reason: 'x'),
        throwsA(isA<FeeException>()),
      );
    });

    test('unwaive makes the due payable again', () async {
      final s = await h.addStudent();
      final jan = await h.dueFor(s.id, ym(2026, 1));
      await h.fees.waive(jan.feeRecordId, reason: 'x');
      await h.fees.unwaive(jan.feeRecordId);
      final after = await h.dueFor(s.id, ym(2026, 1));
      expect(after.waived, 0);
      expect(after.balance, 1500);
    });

    test('a waived month is skipped by later payments', () async {
      final s = await h.addStudent();
      final jan = await h.dueFor(s.id, ym(2026, 1));
      await h.fees.waive(jan.feeRecordId, reason: 'x');
      await h.pay(s.id, 1500);
      expect((await h.dueFor(s.id, ym(2026, 2))).balance, 0); // not January
      expect((await h.dueFor(s.id, ym(2026, 1))).paid, 0);
    });
  });

  group('discount', () {
    test('reduces what is payable', () async {
      final s = await h.addStudent();
      final jan = await h.dueFor(s.id, ym(2026, 1));
      await h.fees.setDiscount(jan.feeRecordId, 500, reason: 'sibling');
      final after = await h.dueFor(s.id, ym(2026, 1));
      expect(after.payable, 1000);
      expect(after.balance, 1000);
    });

    test('paying the discounted amount settles it', () async {
      final s = await h.addStudent();
      final jan = await h.dueFor(s.id, ym(2026, 1));
      await h.fees.setDiscount(jan.feeRecordId, 500);
      await h.pay(s.id, 1000);
      expect(statusFor(await h.dueFor(s.id, ym(2026, 1))), FeeStatus.paid);
    });

    test(
      'a discount beyond what was paid releases the excess as credit',
      () async {
        final s = await h.addStudent();
        await h.pay(s.id, 1500);
        final jan = await h.dueFor(s.id, ym(2026, 1));
        await h.fees.setDiscount(jan.feeRecordId, 600);
        final after = await h.dueFor(s.id, ym(2026, 1));
        expect(after.paid, 900);
        expect(after.balance, 0);
        // 600 went to credit and straight onto February.
        expect((await h.dueFor(s.id, ym(2026, 2))).paid, 600);
      },
    );

    test('0 clears a discount; out of range is refused', () async {
      final s = await h.addStudent();
      final jan = await h.dueFor(s.id, ym(2026, 1));
      await h.fees.setDiscount(jan.feeRecordId, 400);
      await h.fees.setDiscount(jan.feeRecordId, 0);
      expect((await h.dueFor(s.id, ym(2026, 1))).payable, 1500);
      await expectLater(
        h.fees.setDiscount(jan.feeRecordId, -1),
        throwsA(isA<FeeException>()),
      );
      await expectLater(
        h.fees.setDiscount(jan.feeRecordId, 1501),
        throwsA(isA<FeeException>()),
      );
    });

    test('a full discount makes the due paid with nothing to pay', () async {
      final s = await h.addStudent();
      final jan = await h.dueFor(s.id, ym(2026, 1));
      await h.fees.setDiscount(jan.feeRecordId, 1500);
      final after = await h.dueFor(s.id, ym(2026, 1));
      expect(after.payable, 0);
      expect(statusFor(after), FeeStatus.paid);
    });

    test('is audited with the month and amount only', () async {
      final s = await h.addStudent(name: 'Private');
      final jan = await h.dueFor(s.id, ym(2026, 1));
      await h.fees.setDiscount(jan.feeRecordId, 300);
      final log = await (h.db.select(
        h.db.auditLog,
      )..where((a) => a.action.equals('discount'))).getSingle();
      expect(jsonDecode(log.details!), {'month': '2026-01', 'discount': 300});
    });
  });

  group('one-time fees', () {
    test('appear as a due with a label and accept payment', () async {
      final s = await h.addStudent();
      final fee = await h.fees.addOneTimeFee(
        s.id,
        label: '  Admission  ',
        amount: 800,
      );
      expect(fee.kind, 'one_time');
      expect(fee.label, 'Admission');
      expect(fee.month, '2026-03');
      expect(fee.dueDate, '2026-03-15');

      await h.pay(s.id, 4500 + 800); // everything
      expect((await h.ledger(s.id)).every((b) => b.balance == 0), isTrue);
    });

    test('an oldest-first payment reaches it in month order', () async {
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      await h.fees.addOneTimeFee(
        s.id,
        label: 'Book',
        amount: 300,
        month: ym(2026, 3),
      );
      await h.pay(
        s.id,
        1500,
      ); // March monthly (due Mar 10) before the book (Mar 15)
      final ledger = await h.ledger(s.id);
      expect(ledger.firstWhere((b) => b.kind == 'monthly').balance, 0);
      expect(ledger.firstWhere((b) => b.kind == 'one_time').balance, 300);
    });

    test('can be targeted by its month', () async {
      final s = await h.addStudent();
      await h.fees.addOneTimeFee(
        s.id,
        label: 'Exam',
        amount: 200,
        month: ym(2026, 3),
      );
      await h.pay(s.id, 200, target: SpecificMonths([ym(2026, 3)]));
      // March's monthly (due Mar 10) sorts before the exam fee (due Mar 15).
      expect((await h.dueFor(s.id, ym(2026, 3))).paid, 200);
    });

    test('a month can hold several one-time fees', () async {
      final s = await h.addStudent();
      await h.fees.addOneTimeFee(s.id, label: 'A', amount: 100);
      await h.fees.addOneTimeFee(s.id, label: 'B', amount: 200);
      expect(
        (await h.ledger(s.id)).where((b) => b.kind == 'one_time'),
        hasLength(2),
      );
    });

    test('existing credit pays a new one-time fee', () async {
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      await h.pay(s.id, 2000);
      await h.fees.addOneTimeFee(s.id, label: 'Book', amount: 500);
      final book = (await h.ledger(s.id))
          .firstWhere((b) => b.kind == 'one_time');
      expect(book.balance, 0);
      expect(await h.payments.creditBalance(s.id), 0);
    });

    test('needs a label and a positive amount', () async {
      final s = await h.addStudent();
      await expectLater(
        h.fees.addOneTimeFee(s.id, label: '  ', amount: 10),
        throwsA(isA<FeeException>()),
      );
      await expectLater(
        h.fees.addOneTimeFee(s.id, label: 'X', amount: 0),
        throwsA(isA<FeeException>()),
      );
    });
  });

  group('due list', () {
    test('groups open dues per student', () async {
      final a = await h.addStudent(name: 'A');
      await h.addStudent(name: 'B', fee: 2000);
      await h.pay(a.id, 1500);

      final list = await h.fees.watchDueList().first;
      final byName = {for (final e in list) e.student.name: e};
      expect(byName['A']!.totalBalance, 3000);
      expect(byName['A']!.openCount, 2);
      expect(byName['A']!.oldestDueDate, const LocalDate(2026, 2, 10));
      expect(byName['B']!.totalBalance, 6000);
      expect(byName['B']!.openCount, 3);
    });

    test('students who owe nothing, and waived dues, are left out', () async {
      final a = await h.addStudent(name: 'A');
      final b = await h.addStudent(name: 'B');
      await h.pay(a.id, 4500);
      for (final d in await h.ledger(b.id)) {
        await h.fees.waive(d.feeRecordId, reason: 'x');
      }
      expect(await h.fees.watchDueList().first, isEmpty);
    });

    test('archived students who still owe money stay on the list', () async {
      final a = await h.addStudent(name: 'A');
      await h.students.archive(a.id);
      expect((await h.fees.watchDueList().first).single.student.name, 'A');
    });

    test('updates live as payments arrive', () async {
      final a = await h.addStudent(name: 'A');
      final totals = <int>[];
      final sub = h.fees.watchDueList().listen(
        (l) => totals.add(l.fold(0, (s, e) => s + e.totalBalance)),
      );
      await pumpEventQueue();
      await h.pay(a.id, 1000);
      await pumpEventQueue();
      await sub.cancel();
      expect(totals.first, 4500);
      expect(totals.last, 3500);
    });

    test('20 students: the due list matches the sum of balances', () async {
      final ids = <String>[];
      for (var i = 0; i < 20; i++) {
        final s = await h.addStudent(
          name: 'Student $i',
          fee: 1000 + 100 * i,
          joinedOn: LocalDate(2026, 1 + i % 3, 1 + i % 20),
          dueDay: 5 + i % 20,
        );
        ids.add(s.id);
      }
      // A mix: paid up, partial, multi-month, overpaid, untouched.
      await h.pay(ids[0], 99999);
      await h.pay(ids[1], 700);
      await h.pay(ids[2], 3000);
      await h.pay(ids[3], 1300, target: SpecificMonths([ym(2026, 3)]));
      await h.fees.waive(
        (await h.ledger(ids[4])).first.feeRecordId,
        reason: 'x',
      );

      final list = await h.fees.watchDueList().first;
      final listed = {for (final e in list) e.student.id: e.totalBalance};
      var expectedTotal = 0;
      for (final id in ids) {
        final balance = await h.balanceOf(id);
        expectedTotal += balance;
        expect(listed[id] ?? 0, balance, reason: id);
      }
      expect(list.fold<int>(0, (s, e) => s + e.totalBalance), expectedTotal);
      expect(listed.containsKey(ids[0]), isFalse); // overpaid: nothing owed
    });
  });
}

FeeStatus _status(FeeBalance b, LocalDate today) => statusOf(
  waived: b.waived == 1,
  balance: b.balance,
  paid: b.paid,
  dueDate: LocalDate.parse(b.dueDate),
  today: today,
);
