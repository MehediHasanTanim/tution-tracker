import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';

/// A due that still has something to pay.
class OpenDue {
  const OpenDue({
    required this.id,
    required this.month,
    required this.dueDate,
    required this.balance,
  });

  final String id;
  final YearMonth month;
  final LocalDate dueDate;

  /// What is still owed, in taka. Dues with a balance of zero or less are
  /// ignored by [allocate].
  final int balance;
}

/// Where a payment should go first (spec business rule 4).
sealed class AllocationTarget {
  const AllocationTarget();
}

/// Oldest due first. The default.
class OldestFirst extends AllocationTarget {
  const OldestFirst();
}

/// The named months first, then everything else oldest first.
class SpecificMonths extends AllocationTarget {
  const SpecificMonths(this.months);

  final List<YearMonth> months;
}

/// Part of a payment applied to one due, or to advance credit when
/// [feeRecordId] is null (design 7.3).
class AllocationLine {
  const AllocationLine({required this.feeRecordId, required this.amount});

  final String? feeRecordId;
  final int amount;

  bool get isCredit => feeRecordId == null;

  @override
  bool operator ==(Object other) =>
      other is AllocationLine &&
      other.feeRecordId == feeRecordId &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(feeRecordId, amount);

  @override
  String toString() => 'Line(${feeRecordId ?? 'credit'}: $amount)';
}

/// Splits [paymentAmount] across [openDues].
///
/// Pure and total: every taka goes somewhere, so the returned amounts always
/// sum to [paymentAmount]. Whatever no due can take becomes one advance-credit
/// line. Waived dues have a zero balance and so are never paid, which makes a
/// payment "against" a waived month credit by default.
///
/// Throws [ArgumentError] when [paymentAmount] is not positive.
List<AllocationLine> allocate({
  required int paymentAmount,
  required List<OpenDue> openDues,
  AllocationTarget target = const OldestFirst(),
}) {
  if (paymentAmount <= 0) {
    throw ArgumentError.value(paymentAmount, 'paymentAmount', 'must be > 0');
  }

  final open =
      [
        for (final d in openDues)
          if (d.balance > 0) d,
      ]..sort((a, b) {
        final byMonth = a.month.compareTo(b.month);
        if (byMonth != 0) return byMonth;
        final byDue = a.dueDate.compareTo(b.dueDate);
        return byDue != 0 ? byDue : a.id.compareTo(b.id);
      });

  final ordered = switch (target) {
    OldestFirst() => open,
    SpecificMonths(:final months) => [
      ...open.where((d) => months.contains(d.month)),
      ...open.where((d) => !months.contains(d.month)),
    ],
  };

  final lines = <AllocationLine>[];
  var remaining = paymentAmount;
  for (final due in ordered) {
    if (remaining == 0) break;
    final applied = remaining < due.balance ? remaining : due.balance;
    lines.add(AllocationLine(feeRecordId: due.id, amount: applied));
    remaining -= applied;
  }
  if (remaining > 0) {
    lines.add(AllocationLine(feeRecordId: null, amount: remaining));
  }
  return lines;
}
