import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';

import '../../support/fee_harness.dart';

void main() {
  late FeeHarness h;

  setUp(() => h = FeeHarness());
  tearDown(() => h.close());

  test(
    'an unpaid due has payable = amount, paid 0, balance = payable',
    () async {
      final s = await h.addStudent();
      final due = await h.dueFor(s.id, const YearMonth(2026, 1));
      expect(due.amountDue, 1500);
      expect(due.discount, 0);
      expect(due.payable, 1500);
      expect(due.paid, 0);
      expect(due.balance, 1500);
      expect(due.waived, 0);
    },
  );

  test('payments reduce the balance', () async {
    final s = await h.addStudent();
    await h.pay(s.id, 600);
    final jan = await h.dueFor(s.id, const YearMonth(2026, 1));
    expect(jan.paid, 600);
    expect(jan.balance, 900);
    expect(jan.payable, 1500);
  });

  test('several payments add up', () async {
    final s = await h.addStudent();
    await h.pay(s.id, 500);
    await h.pay(s.id, 400);
    final jan = await h.dueFor(s.id, const YearMonth(2026, 1));
    expect(jan.paid, 900);
    expect(jan.balance, 600);
  });

  test('a discount lowers payable and balance', () async {
    final s = await h.addStudent();
    final jan = await h.dueFor(s.id, const YearMonth(2026, 1));
    await h.fees.setDiscount(jan.feeRecordId, 300, reason: 'sibling');
    final after = await h.dueFor(s.id, const YearMonth(2026, 1));
    expect(after.discount, 300);
    expect(after.payable, 1200);
    expect(after.balance, 1200);
  });

  test('a waived due has balance 0 whatever it is owed', () async {
    final s = await h.addStudent();
    final jan = await h.dueFor(s.id, const YearMonth(2026, 1));
    await h.fees.waive(jan.feeRecordId, reason: 'hardship');
    final after = await h.dueFor(s.id, const YearMonth(2026, 1));
    expect(after.waived, 1);
    expect(after.balance, 0);
    expect(after.payable, 1500);
  });

  test('soft-deleted payments are excluded from paid', () async {
    final s = await h.addStudent();
    final p = await h.pay(s.id, 1000);
    // Mark the payment deleted WITHOUT removing its allocation rows, to prove
    // the view itself ignores them (not just the delete routine).
    await h.db.customStatement(
      'UPDATE payments SET deleted_at = 1 WHERE id = ?',
      [p.payment.id],
    );
    final jan = await h.dueFor(s.id, const YearMonth(2026, 1));
    expect(jan.paid, 0);
    expect(jan.balance, 1500);
  });

  test('credit allocations (no due) never count towards any due', () async {
    final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
    await h.pay(s.id, 4000); // 1500 due + 2500 credit
    final ledger = await h.ledger(s.id);
    expect(ledger.single.paid, 1500);
    expect(ledger.single.balance, 0);
  });

  test('one-time dues appear alongside monthly ones', () async {
    final s = await h.addStudent();
    await h.fees.addOneTimeFee(s.id, label: 'Admission', amount: 500);
    final ledger = await h.ledger(s.id);
    final oneTime = ledger.firstWhere((b) => b.kind == 'one_time');
    expect(oneTime.label, 'Admission');
    expect(oneTime.balance, 500);
    expect(ledger.where((b) => b.kind == 'monthly'), hasLength(3));
  });

  test('the view is read-only data: it follows later changes live', () async {
    final s = await h.addStudent();
    final balances = <int>[];
    final sub = h.fees
        .watchLedger(s.id)
        .listen((l) => balances.add(l.first.balance));
    await pumpEventQueue();
    await h.pay(s.id, 500);
    await pumpEventQueue();
    await sub.cancel();
    expect(balances.first, 1500);
    expect(balances.last, 1000);
  });
}
