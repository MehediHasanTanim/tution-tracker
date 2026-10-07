import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/features/fees/domain/proration_rule.dart';

/// A monthly fee that takes effect from [effectiveMonth] (spec FE-7).
class FeeChangeEntry {
  const FeeChangeEntry(this.effectiveMonth, this.amount);

  final YearMonth effectiveMonth;
  final int amount;
}

/// A span of months in which no dues are generated (spec FE-11).
class PauseEntry {
  const PauseEntry(this.from, [this.to]);

  final YearMonth from;

  /// Last paused month, or null for an open-ended pause.
  final YearMonth? to;

  bool covers(YearMonth month) => month >= from && (to == null || month <= to!);
}

/// How a batch fee override changes a student's due while it applies.
///
/// A student's monthly fee is one amount covering all their batches. An
/// override replaces the batch's default fee for that student, so the due
/// drops by `batchDefaultFee - overrideFee` (a negative [reduction] raises
/// it). With one batch whose default equals the student's fee, this is just
/// "the override is the fee".
class BatchFeeAdjustment {
  const BatchFeeAdjustment({
    required this.reduction,
    required this.from,
    this.to,
  });

  final int reduction;

  /// First and last month of the membership (inclusive; [to] null while the
  /// student is still in the batch).
  final YearMonth from;
  final YearMonth? to;

  bool covers(YearMonth month) => month >= from && (to == null || month <= to!);
}

/// A due to be created. The id and timestamps are added when it is stored.
class FeeRecordDraft {
  const FeeRecordDraft({
    required this.studentId,
    required this.month,
    required this.amountDue,
    required this.dueDate,
  });

  final String studentId;
  final YearMonth month;
  final int amountDue;
  final LocalDate dueDate;

  @override
  bool operator ==(Object other) =>
      other is FeeRecordDraft &&
      other.studentId == studentId &&
      other.month == month &&
      other.amountDue == amountDue &&
      other.dueDate == dueDate;

  @override
  int get hashCode => Object.hash(studentId, month, amountDue, dueDate);

  @override
  String toString() => 'Due($studentId $month $amountDue by $dueDate)';
}

/// The fee in force for [month]: the change with the greatest effective month
/// not after it, else [fallback] (design 7.1).
int feeFor(YearMonth month, List<FeeChangeEntry> changes, int fallback) {
  FeeChangeEntry? best;
  for (final c in changes) {
    if (c.effectiveMonth <= month &&
        (best == null || c.effectiveMonth > best.effectiveMonth)) {
      best = c;
    }
  }
  return best?.amount ?? fallback;
}

/// The joining month's fee under [rule] (design 7.2), or null when no due is
/// charged for that month ([ProrationRule.nextMonth]).
int? prorate(int base, LocalDate joinedOn, ProrationRule rule) {
  switch (rule) {
    case ProrationRule.fullMonth:
      return base;
    case ProrationRule.nextMonth:
      return null;
    case ProrationRule.byDays:
      final daysInMonth = joinedOn.daysInMonth;
      final remaining = daysInMonth - joinedOn.day + 1; // joining day counts
      // round(base * remaining / daysInMonth), halves up, integers only.
      return (base * remaining * 2 + daysInMonth) ~/ (2 * daysInMonth);
  }
}

/// The due date for [month]: [dueDay] clamped to the month length, so day 31
/// becomes the 28th, 29th or 30th in shorter months.
LocalDate dueDateFor(YearMonth month, int dueDay) => month.dayClamped(dueDay);

/// The monthly dues missing for one student, from the joining month through
/// [upTo]. Pure: it never reads or writes storage, and months in [existing]
/// are left alone so running it twice creates nothing new.
///
/// Rules:
///  - the fee is the latest [FeeChangeEntry] in force for each month, less
///    any [BatchFeeAdjustment] covering it, never below zero;
///  - paused months get no due;
///  - the joining month is prorated by [rule];
///  - a due of zero is not created;
///  - the joining month's due date is never before the joining date, so a
///    student who joins after their due day is not overdue on day one.
List<FeeRecordDraft> generateDues({
  required String studentId,
  required LocalDate joinedOn,
  required int feeDueDay,
  required int baseFee,
  required YearMonth upTo,
  required ProrationRule rule,
  List<FeeChangeEntry> changes = const [],
  List<PauseEntry> pauses = const [],
  List<BatchFeeAdjustment> batchAdjustments = const [],
  Set<YearMonth> existing = const {},
}) {
  final joinMonth = YearMonth.from(joinedOn);
  final drafts = <FeeRecordDraft>[];

  for (var m = joinMonth; m <= upTo; m = m.next()) {
    if (existing.contains(m)) continue;
    if (pauses.any((p) => p.covers(m))) continue;

    var amount = feeFor(m, changes, baseFee);
    for (final a in batchAdjustments) {
      if (a.covers(m)) amount -= a.reduction;
    }
    if (amount < 0) amount = 0;

    var dueDate = dueDateFor(m, feeDueDay);
    if (m == joinMonth) {
      final prorated = prorate(amount, joinedOn, rule);
      if (prorated == null) continue;
      amount = prorated;
      if (dueDate < joinedOn) dueDate = joinedOn;
    }

    if (amount == 0) continue;
    drafts.add(
      FeeRecordDraft(
        studentId: studentId,
        month: m,
        amountDue: amount,
        dueDate: dueDate,
      ),
    );
  }
  return drafts;
}
