import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/features/fees/domain/fee_status.dart';

const due = LocalDate(2026, 3, 10);

FeeStatus status({
  bool waived = false,
  int balance = 1500,
  int paid = 0,
  LocalDate today = const LocalDate(2026, 3, 1),
}) => statusOf(
  waived: waived,
  balance: balance,
  paid: paid,
  dueDate: due,
  today: today,
);

void main() {
  group('due date boundary', () {
    test('the day before the due date is due', () {
      expect(status(today: const LocalDate(2026, 3, 9)), FeeStatus.due);
    });

    test('on the due date itself it is still due, not overdue', () {
      expect(status(today: due), FeeStatus.due);
    });

    test('the day after the due date is overdue', () {
      expect(status(today: const LocalDate(2026, 3, 11)), FeeStatus.overdue);
    });

    test('far past the due date stays overdue', () {
      expect(status(today: const LocalDate(2027, 1, 1)), FeeStatus.overdue);
    });
  });

  group('partial payments', () {
    test('some paid before the due date is partial', () {
      expect(
        status(paid: 500, balance: 1000, today: const LocalDate(2026, 3, 5)),
        FeeStatus.partial,
      );
    });

    test('some paid on the due date is partial', () {
      expect(status(paid: 500, balance: 1000, today: due), FeeStatus.partial);
    });

    test('some paid but past the due date is overdue', () {
      expect(
        status(paid: 500, balance: 1000, today: const LocalDate(2026, 3, 11)),
        FeeStatus.overdue,
      );
    });
  });

  group('paid and waived', () {
    test('a zero balance is paid, before or after the due date', () {
      expect(status(balance: 0, paid: 1500), FeeStatus.paid);
      expect(
        status(balance: 0, paid: 1500, today: const LocalDate(2027, 1, 1)),
        FeeStatus.paid,
      );
    });

    test('a negative balance counts as paid', () {
      expect(status(balance: -100, paid: 1600), FeeStatus.paid);
    });

    test('a fully discounted due (nothing payable) is paid', () {
      expect(status(balance: 0, paid: 0), FeeStatus.paid);
    });

    test('waived wins over everything, even past the due date', () {
      expect(status(waived: true, balance: 0), FeeStatus.waived);
      expect(
        status(
          waived: true,
          balance: 0,
          paid: 0,
          today: const LocalDate(2027, 1, 1),
        ),
        FeeStatus.waived,
      );
      expect(status(waived: true, balance: 1500), FeeStatus.waived);
    });
  });

  group('overdueDays', () {
    test('zero until the day after the due date', () {
      expect(overdueDays(due, const LocalDate(2026, 3, 1)), 0);
      expect(overdueDays(due, due), 0);
      expect(overdueDays(due, const LocalDate(2026, 3, 11)), 1);
      expect(overdueDays(due, const LocalDate(2026, 4, 10)), 31);
    });
  });
}
