import 'package:drift/drift.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/text_normalizer.dart';
import 'package:tution_tracker/features/fees/data/audit_log.dart';
import 'package:tution_tracker/features/fees/data/due_service.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/fees/domain/due_generation.dart';
import 'package:uuid/uuid.dart';

/// Thrown when a fee operation is not allowed, such as pausing a student who
/// is already paused.
class FeeException implements Exception {
  const FeeException(this.message);

  final String message;

  @override
  String toString() => 'FeeException($message)';
}

/// One student's outstanding balance, for the due list.
class DueListEntry {
  const DueListEntry({
    required this.student,
    required this.totalBalance,
    required this.oldestDueDate,
    required this.openCount,
    required this.dues,
  });

  final Student student;
  final int totalBalance;

  /// The earliest due date among the open dues.
  final LocalDate oldestDueDate;
  final int openCount;
  final List<FeeBalance> dues;
}

/// Fee adjustments and read models over dues. Payments live in
/// [PaymentRepository].
class FeeRepository {
  FeeRepository(
    this._db,
    this._payments,
    this._dues, {
    DateTime Function()? now,
    String Function()? newId,
  }) : _now = now ?? DateTime.now,
       _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final PaymentRepository _payments;
  final DueService _dues;
  final DateTime Function() _now;
  final String Function() _newId;

  int get _timestamp => _now().toUtc().millisecondsSinceEpoch;

  // ---- reading ----------------------------------------------------------

  Future<FeeBalance?> balanceOf(String feeRecordId) => (_db.select(
    _db.feeBalances,
  )..where((b) => b.feeRecordId.equals(feeRecordId))).getSingleOrNull();

  /// Every due of a student, waived ones included, oldest first.
  Stream<List<FeeBalance>> watchLedger(String studentId) =>
      (_db.select(_db.feeBalances)
            ..where((b) => b.studentId.equals(studentId))
            ..orderBy([
              (b) => OrderingTerm.asc(b.month),
              (b) => OrderingTerm.asc(b.dueDate),
              (b) => OrderingTerm.asc(b.feeRecordId),
            ]))
          .watch();

  /// Students who owe something, with their open dues. Unsorted: the screen
  /// sorts by overdue days or amount.
  Stream<List<DueListEntry>> watchDueList() {
    final b = _db.feeBalances;
    final s = _db.students;
    final query =
        _db.select(b).join([innerJoin(s, s.id.equalsExp(b.studentId))])
          ..where(b.waived.equals(0) & b.balance.isBiggerThanValue(0))
          ..orderBy([OrderingTerm.asc(b.month), OrderingTerm.asc(b.dueDate)]);
    return query.watch().map((rows) {
      final byStudent = <String, List<TypedResult>>{};
      for (final r in rows) {
        byStudent.putIfAbsent(r.readTable(s).id, () => []).add(r);
      }
      return [
        for (final group in byStudent.values)
          DueListEntry(
            student: group.first.readTable(s),
            totalBalance: group.fold(0, (a, r) => a + r.readTable(b).balance),
            oldestDueDate: group
                .map((r) => LocalDate.parse(r.readTable(b).dueDate))
                .reduce((a, c) => a < c ? a : c),
            openCount: group.length,
            dues: [for (final r in group) r.readTable(b)],
          ),
      ];
    });
  }

  Future<List<FeeChange>> feeChanges(String studentId) =>
      (_db.select(_db.feeChanges)
            ..where((c) => c.studentId.equals(studentId))
            ..orderBy([(c) => OrderingTerm.asc(c.effectiveMonth)]))
          .get();

  Stream<List<Pause>> watchPauses(String studentId) => (_db.select(
    _db.pauses,
  )..where((p) => p.studentId.equals(studentId))).watch();

  // ---- waive and discount ------------------------------------------------

  /// Waives a due with a [reason] (spec FE-6). Anything already paid against
  /// it becomes advance credit, and credit may then settle other dues.
  Future<void> waive(String feeRecordId, {required String reason}) {
    return _db.transaction(() async {
      final due = await _requireBalance(feeRecordId);
      if (due.waived == 1) return;
      await _update(
        feeRecordId,
        FeeRecordsCompanion(
          waived: const Value(1),
          note: Value(_clean(reason)),
        ),
      );
      if (due.paid > 0) await _payments.releaseToCredit(feeRecordId, due.paid);
      await _payments.applyCredit(due.studentId);
      await writeAudit(
        _db,
        entity: 'fee_record',
        entityId: feeRecordId,
        action: 'waive',
        at: _timestamp,
        details: {
          'month': due.month,
          'amount_due': due.amountDue,
          'paid': due.paid,
        },
        newId: _newId,
      );
    });
  }

  /// Undoes a waiver. The due becomes payable again, and existing credit may
  /// settle it.
  Future<void> unwaive(String feeRecordId) {
    return _db.transaction(() async {
      final due = await _requireBalance(feeRecordId);
      if (due.waived == 0) return;
      await _update(feeRecordId, const FeeRecordsCompanion(waived: Value(0)));
      await _payments.applyCredit(due.studentId);
      await writeAudit(
        _db,
        entity: 'fee_record',
        entityId: feeRecordId,
        action: 'unwaive',
        at: _timestamp,
        details: {'month': due.month},
        newId: _newId,
      );
    });
  }

  /// Sets a discount on a due, from 0 to the full amount. If it leaves the
  /// due paid beyond what is now payable, the excess becomes credit.
  Future<void> setDiscount(
    String feeRecordId,
    int discount, {
    String? reason,
  }) async {
    return _db.transaction(() async {
      final due = await _requireBalance(feeRecordId);
      if (discount < 0 || discount > due.amountDue) {
        throw FeeException('Discount must be between 0 and ${due.amountDue}');
      }
      await _update(
        feeRecordId,
        FeeRecordsCompanion(
          discount: Value(discount),
          note: Value(_clean(reason)),
        ),
      );
      final payable = due.amountDue - discount;
      if (due.waived == 0 && due.paid > payable) {
        await _payments.releaseToCredit(feeRecordId, due.paid - payable);
      }
      await _payments.applyCredit(due.studentId);
      await writeAudit(
        _db,
        entity: 'fee_record',
        entityId: feeRecordId,
        action: 'discount',
        at: _timestamp,
        details: {'month': due.month, 'discount': discount},
        newId: _newId,
      );
    });
  }

  // ---- fee changes -------------------------------------------------------

  /// Changes the monthly fee from [effective] on, without touching dues that
  /// already exist (spec FE-7). Missing dues from that month use the new
  /// fee. Changing the same month twice replaces the earlier change.
  Future<void> changeFee(String studentId, YearMonth effective, int amount) {
    if (amount < 0) throw const FeeException('Fee cannot be negative');
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.feeChanges)..where(
                (c) =>
                    c.studentId.equals(studentId) &
                    c.effectiveMonth.equals(effective.toKey()),
              ))
              .getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.feeChanges)
            .insert(
              FeeChangesCompanion.insert(
                id: _newId(),
                studentId: studentId,
                effectiveMonth: effective.toKey(),
                newAmount: amount,
              ),
            );
      } else {
        await (_db.update(_db.feeChanges)
              ..where((c) => c.id.equals(existing.id)))
            .write(FeeChangesCompanion(newAmount: Value(amount)));
      }

      // students.monthly_fee shows the fee in force this month.
      final changes = await feeChanges(studentId);
      final current = feeFor(_dues.currentMonth, [
        for (final c in changes)
          FeeChangeEntry(YearMonth.parse(c.effectiveMonth), c.newAmount),
      ], amount);
      await (_db.update(
        _db.students,
      )..where((s) => s.id.equals(studentId))).write(
        StudentsCompanion(
          monthlyFee: Value(current),
          updatedAt: Value(_timestamp),
        ),
      );
      await writeAudit(
        _db,
        entity: 'student',
        entityId: studentId,
        action: 'fee_change',
        at: _timestamp,
        details: {'effective_month': effective.toKey(), 'amount': amount},
        newId: _newId,
      );
      await _dues.generateForStudent(studentId);
    });
  }

  // ---- pause and resume --------------------------------------------------

  /// Stops dues from [from] on (spec FE-11). Dues that already exist stay.
  Future<void> pauseFees(String studentId, YearMonth from) {
    return _db.transaction(() async {
      final open = await _openPause(studentId);
      if (open != null) throw const FeeException('Fees are already paused');
      await _db
          .into(_db.pauses)
          .insert(
            PausesCompanion.insert(
              id: _newId(),
              studentId: studentId,
              fromMonth: from.toKey(),
            ),
          );
      await (_db.update(_db.students)
            ..where((s) => s.id.equals(studentId) & s.status.equals('active')))
          .write(
            StudentsCompanion(
              status: const Value('paused'),
              updatedAt: Value(_timestamp),
            ),
          );
      await writeAudit(
        _db,
        entity: 'student',
        entityId: studentId,
        action: 'pause_fees',
        at: _timestamp,
        details: {'from': from.toKey()},
        newId: _newId,
      );
    });
  }

  /// Ends the open pause so dues run again from [resumeMonth]. Months before
  /// it stay paused. Missing dues from [resumeMonth] on are generated.
  Future<void> resumeFees(String studentId, YearMonth resumeMonth) {
    return _db.transaction(() async {
      final open = await _openPause(studentId);
      if (open == null) throw const FeeException('Fees are not paused');
      final from = YearMonth.parse(open.fromMonth);
      if (resumeMonth <= from) {
        await (_db.delete(_db.pauses)..where((p) => p.id.equals(open.id))).go();
      } else {
        await (_db.update(
          _db.pauses,
        )..where((p) => p.id.equals(open.id))).write(
          PausesCompanion(toMonth: Value(resumeMonth.previous().toKey())),
        );
      }
      await (_db.update(_db.students)
            ..where((s) => s.id.equals(studentId) & s.status.equals('paused')))
          .write(
            StudentsCompanion(
              status: const Value('active'),
              updatedAt: Value(_timestamp),
            ),
          );
      await writeAudit(
        _db,
        entity: 'student',
        entityId: studentId,
        action: 'resume_fees',
        at: _timestamp,
        details: {'from': resumeMonth.toKey()},
        newId: _newId,
      );
      await _dues.generateForStudent(studentId);
    });
  }

  Future<Pause?> _openPause(String studentId) =>
      (_db.select(_db.pauses)
            ..where((p) => p.studentId.equals(studentId) & p.toMonth.isNull()))
          .getSingleOrNull();

  // ---- one-time fees -----------------------------------------------------

  /// Adds a one-time due such as an admission, exam or book fee (spec FE-12).
  /// [month] and [dueDate] default to this month and today.
  Future<FeeRecord> addOneTimeFee(
    String studentId, {
    required String label,
    required int amount,
    YearMonth? month,
    LocalDate? dueDate,
  }) async {
    final cleanLabel = normalizeText(label);
    if (cleanLabel.isEmpty) throw const FeeException('A label is required');
    if (amount <= 0) {
      throw const FeeException('Amount must be greater than zero');
    }
    return _db.transaction(() async {
      final id = _newId();
      final today = LocalDate.fromDateTime(_now());
      await _db
          .into(_db.feeRecords)
          .insert(
            FeeRecordsCompanion.insert(
              id: id,
              studentId: studentId,
              month: (month ?? YearMonth.from(today)).toKey(),
              kind: const Value('one_time'),
              label: Value(cleanLabel),
              amountDue: amount,
              dueDate: (dueDate ?? today).toIso(),
              createdAt: _timestamp,
            ),
          );
      await _payments.applyCredit(studentId);
      await writeAudit(
        _db,
        entity: 'fee_record',
        entityId: id,
        action: 'create_one_time',
        at: _timestamp,
        details: {'amount': amount},
        newId: _newId,
      );
      return (await (_db.select(
        _db.feeRecords,
      )..where((f) => f.id.equals(id))).getSingle());
    });
  }

  // ---- internals ---------------------------------------------------------

  Future<FeeBalance> _requireBalance(String feeRecordId) async {
    final b = await balanceOf(feeRecordId);
    if (b == null) throw const FeeException('No such due');
    return b;
  }

  Future<void> _update(String id, FeeRecordsCompanion changes) => (_db.update(
    _db.feeRecords,
  )..where((f) => f.id.equals(id))).write(changes);

  String? _clean(String? v) {
    if (v == null) return null;
    final t = normalizeText(v);
    return t.isEmpty ? null : t;
  }
}
