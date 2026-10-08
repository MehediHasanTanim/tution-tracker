import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/fees/domain/payment_method.dart';
import 'package:tution_tracker/features/receipts/data/receipt_repository.dart';
import 'package:tution_tracker/features/receipts/domain/receipt_data.dart';

import '../../support/fee_harness.dart';

YearMonth ym(int y, int m) => YearMonth(y, m);

AllocationInfo alloc(
  int amount, {
  YearMonth? month,
  String? label,
  String? key,
}) => AllocationInfo(amount: amount, month: month, label: label, dueKey: key);

void main() {
  group('receiptLines', () {
    test('one line per due, oldest month first', () {
      final lines = receiptLines([
        alloc(1500, month: ym(2026, 3), key: 'mar'),
        alloc(1500, month: ym(2026, 1), key: 'jan'),
        alloc(1500, month: ym(2026, 2), key: 'feb'),
      ]);
      expect(lines.map((l) => l.month), [
        ym(2026, 1),
        ym(2026, 2),
        ym(2026, 3),
      ]);
    });

    test('allocations to the same due are merged', () {
      final lines = receiptLines([
        alloc(500, month: ym(2026, 1), key: 'jan'),
        alloc(1000, month: ym(2026, 1), key: 'jan'),
      ]);
      expect(lines, [ReceiptLine(month: ym(2026, 1), amount: 1500)]);
    });

    test('advance credit comes last and is summed', () {
      final lines = receiptLines([
        alloc(300),
        alloc(1500, month: ym(2026, 1), key: 'jan'),
        alloc(200),
      ]);
      expect(lines.last.isCredit, isTrue);
      expect(lines.last.amount, 500);
      expect(lines, hasLength(2));
    });

    test('a one-time fee follows the monthly fee of the same month', () {
      final lines = receiptLines([
        alloc(300, month: ym(2026, 3), label: 'Book', key: 'book'),
        alloc(1500, month: ym(2026, 3), key: 'mar'),
        alloc(200, month: ym(2026, 2), label: 'Exam', key: 'exam'),
      ]);
      expect(lines.map((l) => l.label), ['Exam', null, 'Book']);
    });

    test('the lines add up to the allocations', () {
      final input = [
        alloc(700, month: ym(2026, 1), key: 'jan'),
        alloc(800, month: ym(2026, 1), key: 'jan'),
        alloc(1500, month: ym(2026, 2), key: 'feb'),
        alloc(250),
      ];
      expect(
        receiptLines(input).fold<int>(0, (s, l) => s + l.amount),
        input.fold<int>(0, (s, a) => s + a.amount),
      );
    });

    test('no allocations gives no lines', () {
      expect(receiptLines(const []), isEmpty);
    });
  });

  group('ReceiptRepository', () {
    late FeeHarness h;
    late ReceiptRepository receipts;

    setUp(() {
      h = FeeHarness();
      receipts = ReceiptRepository(h.db);
    });
    tearDown(() => h.close());

    test('describes a multi-month payment', () async {
      final s = await h.addStudent(name: 'রহিম উদ্দিন');
      await h.db.customStatement(
        "UPDATE students SET guardian_name = 'আব্দুল করিম' WHERE id = '${s.id}'",
      );
      final p = (await h.payments.record(
        PaymentInput(
          studentId: s.id,
          amount: 3000,
          receivedOn: const LocalDate(2026, 3, 9),
          method: PaymentMethod.bkash,
          reference: 'TX9',
        ),
      )).payment;

      final r = (await receipts.forPayment(p.id))!;
      expect(r.receiptNo, 1);
      expect(r.date, const LocalDate(2026, 3, 9));
      expect(r.studentName, 'রহিম উদ্দিন');
      expect(r.guardianName, 'আব্দুল করিম');
      expect(r.amount, 3000);
      expect(r.method, PaymentMethod.bkash);
      expect(r.reference, 'TX9');
      expect(r.lines.map((l) => l.month), [ym(2026, 1), ym(2026, 2)]);
      expect(r.lines.map((l) => l.amount), [1500, 1500]);
    });

    test('shows advance credit and one-time fee labels', () async {
      final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      await h.fees.addOneTimeFee(s.id, label: 'Admission', amount: 500);
      final p = (await h.pay(s.id, 2300)).payment; // 1500 + 500 + 300 credit
      final r = (await receipts.forPayment(p.id))!;
      expect(r.lines.map((l) => l.label), [null, 'Admission', null]);
      expect(r.lines.last.isCredit, isTrue);
      expect(r.lines.last.amount, 300);
      expect(r.lines.fold<int>(0, (a, l) => a + l.amount), 2300);
    });

    test(
      'after credit is applied, the receipt shows the months it paid',
      () async {
        final s = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
        final p = (await h.pay(s.id, 3000)).payment; // March + 1500 credit
        await h.advanceTo(ym(2026, 4));
        final r = (await receipts.forPayment(p.id))!;
        expect(r.lines.map((l) => l.month), [ym(2026, 3), ym(2026, 4)]);
      },
    );

    test('a deleted or unknown payment has no receipt', () async {
      final s = await h.addStudent();
      final p = (await h.pay(s.id, 100)).payment;
      await h.payments.delete(p.id);
      expect(await receipts.forPayment(p.id), isNull);
      expect(await receipts.forPayment('nope'), isNull);
    });
  });
}
