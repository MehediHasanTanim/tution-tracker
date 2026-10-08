import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/features/fees/domain/payment_method.dart';

/// One line of a receipt: an amount applied to a month (or to a labelled
/// one-time fee), or advance credit.
class ReceiptLine {
  const ReceiptLine({this.month, this.label, required this.amount});

  /// The month paid for; null for advance credit.
  final YearMonth? month;

  /// The name of a one-time fee such as "Admission".
  final String? label;
  final int amount;

  bool get isCredit => month == null;

  @override
  bool operator ==(Object other) =>
      other is ReceiptLine &&
      other.month == month &&
      other.label == label &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(month, label, amount);

  @override
  String toString() => 'ReceiptLine(${month ?? 'credit'} $label $amount)';
}

/// What a receipt says, apart from how it looks.
class ReceiptData {
  const ReceiptData({
    required this.receiptNo,
    required this.date,
    required this.studentName,
    required this.amount,
    required this.method,
    required this.lines,
    this.guardianName,
    this.reference,
  });

  final int receiptNo;
  final LocalDate date;
  final String studentName;
  final String? guardianName;
  final int amount;
  final PaymentMethod method;
  final String? reference;
  final List<ReceiptLine> lines;
}

/// One stored allocation, as the receipt builder sees it.
class AllocationInfo {
  const AllocationInfo({
    required this.amount,
    this.month,
    this.label,
    this.dueKey,
  });

  final int amount;
  final YearMonth? month;
  final String? label;

  /// The due it went to; allocations to the same due are merged. Null for
  /// credit.
  final String? dueKey;
}

/// Turns allocations into receipt lines: one line per due (a due paid by
/// several allocations shows once), oldest month first, one-time fees after
/// the monthly fee of the same month, and advance credit last.
List<ReceiptLine> receiptLines(List<AllocationInfo> allocations) {
  final byDue = <String, ReceiptLine>{};
  var credit = 0;
  for (final a in allocations) {
    final key = a.dueKey;
    if (key == null || a.month == null) {
      credit += a.amount;
      continue;
    }
    final existing = byDue[key];
    byDue[key] = ReceiptLine(
      month: a.month,
      label: a.label,
      amount: (existing?.amount ?? 0) + a.amount,
    );
  }
  final lines = byDue.values.toList()
    ..sort((x, y) {
      final byMonth = x.month!.compareTo(y.month!);
      if (byMonth != 0) return byMonth;
      // Monthly fee (no label) before one-time fees.
      if ((x.label == null) != (y.label == null)) {
        return x.label == null ? -1 : 1;
      }
      return (x.label ?? '').compareTo(y.label ?? '');
    });
  if (credit > 0) lines.add(ReceiptLine(amount: credit));
  return lines;
}
