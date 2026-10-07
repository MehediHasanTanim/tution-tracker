import 'package:tution_tracker/core/dates/local_date.dart';

enum FeeStatus { paid, partial, due, overdue, waived }

/// The status of one due, computed from its balance and today's date. It is
/// never stored (design 7.6).
///
///  - waived: the due was waived (whatever was paid is credit);
///  - paid: nothing left to pay (including a fully discounted due);
///  - partial: something paid, balance left, and not yet past the due date;
///  - overdue: balance left and today is after the due date;
///  - due: balance left, nothing paid, due date not passed.
FeeStatus statusOf({
  required bool waived,
  required int balance,
  required int paid,
  required LocalDate dueDate,
  required LocalDate today,
}) {
  if (waived) return FeeStatus.waived;
  if (balance <= 0) return FeeStatus.paid;
  if (today > dueDate) return FeeStatus.overdue;
  return paid > 0 ? FeeStatus.partial : FeeStatus.due;
}

/// Whole days past the due date, or 0 when not yet overdue.
int overdueDays(LocalDate dueDate, LocalDate today) =>
    today > dueDate ? dueDate.daysUntil(today) : 0;
