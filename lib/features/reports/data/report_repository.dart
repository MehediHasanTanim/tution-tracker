import 'package:drift/drift.dart' hide Batch;
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/features/attendance/data/attendance_repository.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_stats.dart';

/// What a month's dues add up to, straight from the ledger (`fee_balances`).
///
/// [expected] is what the month's dues are payable, [collected] what has been
/// paid against them (whenever the money arrived), and [outstanding] what is
/// left, so `expected - collected == outstanding`. Waived dues are left out.
/// [cashReceived] is a different measure: money that came in during the
/// month, for any month's dues or as advance.
class MonthSummary {
  const MonthSummary({
    required this.expected,
    required this.collected,
    required this.outstanding,
    required this.cashReceived,
  });

  static const empty = MonthSummary(
    expected: 0,
    collected: 0,
    outstanding: 0,
    cashReceived: 0,
  );

  final int expected;
  final int collected;
  final int outstanding;
  final int cashReceived;

  /// 0 to 100, or null when nothing was expected.
  int? get collectionPercent =>
      expected == 0 ? null : (collected * 200 + expected) ~/ (2 * expected);
}

/// Everything owed across all months, as the due list shows it.
class OwingSummary {
  const OwingSummary({
    required this.totalOutstanding,
    required this.studentsOwing,
    required this.overdueStudents,
  });

  final int totalOutstanding;
  final int studentsOwing;

  /// Students with at least one open due past its due date.
  final int overdueStudents;
}

/// A due coming up, for the Today screen.
class UpcomingDue {
  const UpcomingDue({
    required this.studentId,
    required this.studentName,
    required this.dueDate,
    required this.balance,
  });

  final String studentId;
  final String studentName;
  final LocalDate dueDate;
  final int balance;
}

/// One row of the monthly report: the month's dues of the students whose
/// "main" batch this is. A student in several batches is counted in exactly
/// one (the one they joined first), so the rows add up to the month total.
/// Students in no batch are the row with a null [batch].
class BatchBreakdown {
  const BatchBreakdown({
    required this.batch,
    required this.students,
    required this.expected,
    required this.collected,
    required this.outstanding,
    required this.attendance,
    required this.heldClasses,
  });

  final Batch? batch;

  /// Students with a due this month.
  final int students;
  final int expected;
  final int collected;
  final int outstanding;

  /// Marks in the batch's held classes this month (empty for no batch).
  final AttendanceCounts attendance;
  final int heldClasses;
}

class MonthIncome {
  const MonthIncome(this.month, this.amount);

  final YearMonth month;
  final int amount;
}

class ReportRepository {
  ReportRepository(this._db, this._attendance);

  final AppDatabase _db;
  final AttendanceRepository _attendance;

  Set<TableInfo<Table, dynamic>> get _moneyTables => {
    _db.feeRecords,
    _db.paymentAllocations,
    _db.payments,
  };

  /// Re-runs [compute] whenever any of the tables the figures depend on
  /// changes.
  Stream<T> _live<T>(
    Set<TableInfo<Table, dynamic>> tables,
    Future<T> Function() compute,
  ) => _db
      .customSelect('SELECT 1', readsFrom: tables)
      .watch()
      .asyncMap((_) => compute());

  // ---- month summary ----------------------------------------------------

  Future<MonthSummary> monthSummary(YearMonth month) async {
    final dues = await _db
        .customSelect(
          'SELECT COALESCE(SUM(payable), 0) AS expected, '
          'COALESCE(SUM(paid), 0) AS collected, '
          'COALESCE(SUM(balance), 0) AS outstanding '
          'FROM fee_balances WHERE month = ? AND waived = 0',
          variables: [Variable.withString(month.toKey())],
          readsFrom: _moneyTables,
        )
        .getSingle();
    final cash = await _cashReceived(month.firstDay, month.lastDay);
    return MonthSummary(
      expected: dues.read<int>('expected'),
      collected: dues.read<int>('collected'),
      outstanding: dues.read<int>('outstanding'),
      cashReceived: cash,
    );
  }

  Stream<MonthSummary> watchMonthSummary(YearMonth month) =>
      _live(_moneyTables, () => monthSummary(month));

  Future<int> _cashReceived(LocalDate from, LocalDate to) async {
    final row = await _db
        .customSelect(
          'SELECT COALESCE(SUM(amount), 0) AS total FROM payments '
          'WHERE deleted_at IS NULL AND received_on BETWEEN ? AND ?',
          variables: [
            Variable.withString(from.toIso()),
            Variable.withString(to.toIso()),
          ],
          readsFrom: {_db.payments},
        )
        .getSingle();
    return row.read<int>('total');
  }

  // ---- everyone who owes ------------------------------------------------

  Future<OwingSummary> owing(LocalDate today) async {
    final row = await _db
        .customSelect(
          'SELECT COALESCE(SUM(balance), 0) AS total, '
          'COUNT(DISTINCT student_id) AS students, '
          'COUNT(DISTINCT CASE WHEN due_date < ? THEN student_id END) AS late '
          'FROM fee_balances WHERE waived = 0 AND balance > 0',
          variables: [Variable.withString(today.toIso())],
          readsFrom: _moneyTables,
        )
        .getSingle();
    return OwingSummary(
      totalOutstanding: row.read<int>('total'),
      studentsOwing: row.read<int>('students'),
      overdueStudents: row.read<int>('late'),
    );
  }

  Stream<OwingSummary> watchOwing(LocalDate today) =>
      _live(_moneyTables, () => owing(today));

  /// Open dues falling from [today] through the next six days, soonest first.
  Future<List<UpcomingDue>> upcomingDues(LocalDate today) async {
    final rows = await _db
        .customSelect(
          'SELECT b.student_id AS student_id, s.name AS name, '
          'b.due_date AS due_date, b.balance AS balance '
          'FROM fee_balances b JOIN students s ON s.id = b.student_id '
          'WHERE b.waived = 0 AND b.balance > 0 AND b.due_date BETWEEN ? AND ? '
          'ORDER BY b.due_date, s.name',
          variables: [
            Variable.withString(today.toIso()),
            Variable.withString(today.addDays(6).toIso()),
          ],
          readsFrom: {..._moneyTables, _db.students},
        )
        .get();
    return [
      for (final r in rows)
        UpcomingDue(
          studentId: r.read<String>('student_id'),
          studentName: r.read<String>('name'),
          dueDate: LocalDate.parse(r.read<String>('due_date')),
          balance: r.read<int>('balance'),
        ),
    ];
  }

  Stream<List<UpcomingDue>> watchUpcomingDues(LocalDate today) =>
      _live({..._moneyTables, _db.students}, () => upcomingDues(today));

  // ---- per-batch breakdown ----------------------------------------------

  Future<List<BatchBreakdown>> batchBreakdown(YearMonth month) async {
    final dues = await (_db.select(
      _db.feeBalances,
    )..where((b) => b.month.equals(month.toKey()) & b.waived.equals(0))).get();

    // Memberships overlapping the month, in active batches, earliest first.
    final memberships =
        await (_db.select(_db.batchMembers).join([
                innerJoin(
                  _db.batches,
                  _db.batches.id.equalsExp(_db.batchMembers.batchId),
                ),
              ])
              ..where(
                _db.batches.status.equals('active') &
                    _db.batchMembers.joinedOn.isSmallerOrEqualValue(
                      month.lastDay.toIso(),
                    ) &
                    (_db.batchMembers.leftOn.isNull() |
                        _db.batchMembers.leftOn.isBiggerThanValue(
                          month.firstDay.toIso(),
                        )),
              )
              ..orderBy([
                OrderingTerm.asc(_db.batchMembers.joinedOn),
                OrderingTerm.asc(_db.batches.name),
                OrderingTerm.asc(_db.batches.id),
              ]))
            .get();

    final mainBatch = <String, Batch>{};
    for (final m in memberships) {
      mainBatch.putIfAbsent(
        m.readTable(_db.batchMembers).studentId,
        () => m.readTable(_db.batches),
      );
    }

    final groups = <String?, _Totals>{};
    final batchById = <String, Batch>{};
    for (final d in dues) {
      final batch = mainBatch[d.studentId];
      if (batch != null) batchById[batch.id] = batch;
      groups.putIfAbsent(batch?.id, _Totals.new).add(d);
    }

    final result = <BatchBreakdown>[];
    for (final entry in groups.entries) {
      final batch = entry.key == null ? null : batchById[entry.key];
      final t = entry.value;
      result.add(
        BatchBreakdown(
          batch: batch,
          students: t.students.length,
          expected: t.expected,
          collected: t.collected,
          outstanding: t.outstanding,
          attendance: batch == null
              ? AttendanceCounts.none
              : await _attendance.batchMonth(batch.id, month),
          heldClasses: batch == null
              ? 0
              : await _attendance.batchHeldClasses(batch.id, month),
        ),
      );
    }
    result.sort((a, b) {
      // Batches by name, "no batch" last.
      if (a.batch == null) return 1;
      if (b.batch == null) return -1;
      return a.batch!.name.toLowerCase().compareTo(b.batch!.name.toLowerCase());
    });
    return result;
  }

  Stream<List<BatchBreakdown>> watchBatchBreakdown(YearMonth month) => _live({
    ..._moneyTables,
    _db.batchMembers,
    _db.batches,
    _db.attendance,
    _db.classSessions,
  }, () => batchBreakdown(month));

  // ---- income by month --------------------------------------------------

  /// Cash received in each of the [months] months ending at [last], oldest
  /// first. Months with no payments are zero, not missing.
  Future<List<MonthIncome>> income(YearMonth last, {int months = 12}) async {
    final first = last.addMonths(-(months - 1));
    final rows = await _db
        .customSelect(
          'SELECT substr(received_on, 1, 7) AS m, SUM(amount) AS total '
          'FROM payments WHERE deleted_at IS NULL AND received_on BETWEEN ? AND ? '
          'GROUP BY m',
          variables: [
            Variable.withString(first.firstDay.toIso()),
            Variable.withString(last.lastDay.toIso()),
          ],
          readsFrom: {_db.payments},
        )
        .get();
    final byMonth = {
      for (final r in rows) r.read<String>('m'): r.read<int>('total'),
    };
    return [
      for (var i = 0; i < months; i++)
        MonthIncome(
          first.addMonths(i),
          byMonth[first.addMonths(i).toKey()] ?? 0,
        ),
    ];
  }

  Stream<List<MonthIncome>> watchIncome(YearMonth last, {int months = 12}) =>
      _live({_db.payments}, () => income(last, months: months));
}

class _Totals {
  final students = <String>{};
  var expected = 0;
  var collected = 0;
  var outstanding = 0;

  void add(FeeBalance d) {
    students.add(d.studentId);
    expected += d.payable;
    collected += d.paid;
    outstanding += d.balance;
  }
}
