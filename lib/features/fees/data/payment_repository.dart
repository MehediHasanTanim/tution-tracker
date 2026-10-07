import 'package:drift/drift.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/fees/data/audit_log.dart';
import 'package:tution_tracker/features/fees/domain/allocation.dart';
import 'package:tution_tracker/features/fees/domain/payment_method.dart';
import 'package:uuid/uuid.dart';

/// What the tutor enters when recording a payment.
class PaymentInput {
  const PaymentInput({
    required this.studentId,
    required this.amount,
    required this.receivedOn,
    this.method = PaymentMethod.cash,
    this.reference,
    this.note,
    this.target = const OldestFirst(),
  });

  final String studentId;
  final int amount;
  final LocalDate receivedOn;
  final PaymentMethod method;
  final String? reference;
  final String? note;

  /// Defaults to the oldest unpaid month.
  final AllocationTarget target;
}

/// The fields of a payment that can be edited afterwards.
class PaymentEdit {
  const PaymentEdit({
    required this.amount,
    required this.receivedOn,
    this.method = PaymentMethod.cash,
    this.reference,
    this.note,
    this.target = const OldestFirst(),
  });

  final int amount;
  final LocalDate receivedOn;
  final PaymentMethod method;
  final String? reference;
  final String? note;
  final AllocationTarget target;
}

/// A due a payment could go to, with what the screens need to label it.
class PayableDue {
  const PayableDue({required this.due, required this.kind, this.label});

  final OpenDue due;

  /// `monthly` or `one_time`.
  final String kind;
  final String? label;
}

class RecordedPayment {
  const RecordedPayment(this.payment, this.lines);

  final Payment payment;

  /// How the payment was applied, in order. A null fee record is advance
  /// credit.
  final List<AllocationLine> lines;
}

/// Thrown for payments that can never be valid, such as a non-positive
/// amount or editing a deleted payment.
class PaymentException implements Exception {
  const PaymentException(this.message);

  final String message;

  @override
  String toString() => 'PaymentException($message)';
}

/// Payments and the allocations that tie them to dues.
///
/// Every multi-row change runs in one transaction. Balances are never stored:
/// they are derived from allocations (view `fee_balances`), so editing or
/// deleting a payment only has to rewrite its own allocation rows.
class PaymentRepository {
  PaymentRepository(
    this._db,
    this._settings, {
    DateTime Function()? now,
    String Function()? newId,
  }) : _now = now ?? DateTime.now,
       _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final SettingsStore _settings;
  final DateTime Function() _now;
  final String Function() _newId;

  int get _timestamp => _now().toUtc().millisecondsSinceEpoch;

  // ---- reading ----------------------------------------------------------

  Future<Payment?> getById(String id) => (_db.select(
    _db.payments,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// A student's payments, newest first. Deleted ones are left out unless
  /// [includeDeleted].
  Stream<List<Payment>> watchForStudent(
    String studentId, {
    bool includeDeleted = false,
  }) {
    final query = _db.select(_db.payments)
      ..where((t) {
        final mine = t.studentId.equals(studentId);
        return includeDeleted ? mine : mine & t.deletedAt.isNull();
      })
      ..orderBy([
        (t) => OrderingTerm.desc(t.receivedOn),
        (t) => OrderingTerm.desc(t.receiptNo),
      ]);
    return query.watch();
  }

  Future<List<PaymentAllocation>> allocationsOf(String paymentId) =>
      (_db.select(_db.paymentAllocations)
            ..where((a) => a.paymentId.equals(paymentId))
            ..orderBy([(a) => OrderingTerm.asc(a.id)]))
          .get();

  /// Dues with something left to pay, oldest first. Waived dues are excluded.
  Future<List<OpenDue>> openDues(String studentId) async {
    final rows =
        await (_db.select(_db.feeBalances)
              ..where(
                (b) =>
                    b.studentId.equals(studentId) &
                    b.waived.equals(0) &
                    b.balance.isBiggerThanValue(0),
              )
              ..orderBy([
                (b) => OrderingTerm.asc(b.month),
                (b) => OrderingTerm.asc(b.dueDate),
              ]))
            .get();
    return [
      for (final b in rows)
        OpenDue(
          id: b.feeRecordId,
          month: YearMonth.parse(b.month),
          dueDate: LocalDate.parse(b.dueDate),
          balance: b.balance,
        ),
    ];
  }

  /// The dues a payment could be applied to, oldest first, with labels.
  ///
  /// With [excludingPaymentId], that payment's own allocations are treated as
  /// not yet made: the dues it covers show their balance as it would be
  /// without it. This is what editing that payment allocates against.
  Future<List<PayableDue>> payableDues(
    String studentId, {
    String? excludingPaymentId,
  }) async {
    final rows =
        await (_db.select(_db.feeBalances)
              ..where((b) => b.studentId.equals(studentId) & b.waived.equals(0))
              ..orderBy([
                (b) => OrderingTerm.asc(b.month),
                (b) => OrderingTerm.asc(b.dueDate),
              ]))
            .get();
    final own = <String, int>{};
    if (excludingPaymentId != null) {
      for (final a in await allocationsOf(excludingPaymentId)) {
        final id = a.feeRecordId;
        if (id != null) own[id] = (own[id] ?? 0) + a.amount;
      }
    }
    return [
      for (final b in rows)
        if (b.balance + (own[b.feeRecordId] ?? 0) > 0)
          PayableDue(
            due: OpenDue(
              id: b.feeRecordId,
              month: YearMonth.parse(b.month),
              dueDate: LocalDate.parse(b.dueDate),
              balance: b.balance + (own[b.feeRecordId] ?? 0),
            ),
            kind: b.kind,
            label: b.label,
          ),
    ];
  }

  /// Unapplied advance credit: allocations with no due, on live payments.
  Future<int> creditBalance(String studentId) async {
    final sum = _db.paymentAllocations.amount.sum();
    final query =
        _db.selectOnly(_db.paymentAllocations).join([
            innerJoin(
              _db.payments,
              _db.payments.id.equalsExp(_db.paymentAllocations.paymentId),
            ),
          ])
          ..addColumns([sum])
          ..where(
            _db.paymentAllocations.studentId.equals(studentId) &
                _db.paymentAllocations.feeRecordId.isNull() &
                _db.payments.deletedAt.isNull(),
          );
    final row = await query.getSingle();
    return row.read(sum) ?? 0;
  }

  Stream<int> watchCreditBalance(String studentId) {
    final sum = _db.paymentAllocations.amount.sum();
    final query =
        _db.selectOnly(_db.paymentAllocations).join([
            innerJoin(
              _db.payments,
              _db.payments.id.equalsExp(_db.paymentAllocations.paymentId),
            ),
          ])
          ..addColumns([sum])
          ..where(
            _db.paymentAllocations.studentId.equals(studentId) &
                _db.paymentAllocations.feeRecordId.isNull() &
                _db.payments.deletedAt.isNull(),
          );
    return query.watchSingle().map((row) => row.read(sum) ?? 0);
  }

  // ---- writing ----------------------------------------------------------

  /// Records a payment: loads the open dues, allocates, takes the next receipt
  /// number, and writes the payment, its allocations and an audit entry, all
  /// in one transaction. Nothing is written if any step fails, and a failed
  /// attempt does not use up a receipt number.
  Future<RecordedPayment> record(PaymentInput input) async {
    if (input.amount <= 0) {
      throw const PaymentException('Amount must be greater than zero');
    }
    return _db.transaction(() async {
      final dues = await openDues(input.studentId);
      final lines = allocate(
        paymentAmount: input.amount,
        openDues: dues,
        target: input.target,
      );
      final receiptNo = await _settings.nextReceiptNumber();
      final id = _newId();
      final ts = _timestamp;
      await _db
          .into(_db.payments)
          .insert(
            PaymentsCompanion.insert(
              id: id,
              studentId: input.studentId,
              amount: input.amount,
              receivedOn: input.receivedOn.toIso(),
              method: Value(input.method.name),
              reference: Value(_clean(input.reference)),
              receiptNo: receiptNo,
              note: Value(_clean(input.note)),
              createdAt: ts,
            ),
          );
      await _insertLines(id, input.studentId, lines);
      await writeAudit(
        _db,
        entity: 'payment',
        entityId: id,
        action: 'create',
        at: ts,
        details: {'amount': input.amount, 'receipt_no': receiptNo},
        newId: _newId,
      );
      return RecordedPayment((await getById(id))!, lines);
    });
  }

  /// Changes a payment by dropping its allocations, updating its fields, and
  /// allocating again against the dues as they stand without it. If the
  /// amount shrinks, dues re-open; if it grows, the extra goes to later dues
  /// or credit. The receipt number never changes.
  Future<RecordedPayment> edit(String paymentId, PaymentEdit edit) async {
    if (edit.amount <= 0) {
      throw const PaymentException('Amount must be greater than zero');
    }
    return _db.transaction(() async {
      final existing = await getById(paymentId);
      if (existing == null) throw const PaymentException('No such payment');
      if (existing.deletedAt != null) {
        throw const PaymentException('A deleted payment cannot be edited');
      }

      await _deleteAllocations(paymentId);
      final dues = await openDues(existing.studentId);
      final lines = allocate(
        paymentAmount: edit.amount,
        openDues: dues,
        target: edit.target,
      );
      await (_db.update(
        _db.payments,
      )..where((t) => t.id.equals(paymentId))).write(
        PaymentsCompanion(
          amount: Value(edit.amount),
          receivedOn: Value(edit.receivedOn.toIso()),
          method: Value(edit.method.name),
          reference: Value(_clean(edit.reference)),
          note: Value(_clean(edit.note)),
        ),
      );
      await _insertLines(paymentId, existing.studentId, lines);
      // A due this edit re-opened may now be covered by existing credit.
      await applyCredit(existing.studentId);
      await writeAudit(
        _db,
        entity: 'payment',
        entityId: paymentId,
        action: 'edit',
        at: _timestamp,
        details: {
          'old_amount': existing.amount,
          'new_amount': edit.amount,
          'receipt_no': existing.receiptNo,
        },
        newId: _newId,
      );
      return RecordedPayment((await getById(paymentId))!, lines);
    });
  }

  /// Soft-deletes a payment and removes its allocations so its dues re-open.
  /// The row stays (and so does its receipt number, which is never reused)
  /// and the deletion is logged.
  Future<void> delete(String paymentId) {
    return _db.transaction(() async {
      final existing = await getById(paymentId);
      if (existing == null) throw const PaymentException('No such payment');
      if (existing.deletedAt != null) return;
      final ts = _timestamp;
      await (_db.update(_db.payments)..where((t) => t.id.equals(paymentId)))
          .write(PaymentsCompanion(deletedAt: Value(ts)));
      await _deleteAllocations(paymentId);
      // Existing credit may now settle the due this payment used to cover.
      await applyCredit(existing.studentId);
      await writeAudit(
        _db,
        entity: 'payment',
        entityId: paymentId,
        action: 'delete',
        at: ts,
        details: {
          'amount': existing.amount,
          'receipt_no': existing.receiptNo,
          'receipt_shared': existing.receiptSharedAt != null,
        },
        newId: _newId,
      );
    });
  }

  /// Remembers that a receipt for this payment left the app, so editing or
  /// deleting it can warn that the guardian holds an older version.
  Future<void> markReceiptShared(String paymentId) async {
    await (_db.update(_db.payments)..where((t) => t.id.equals(paymentId)))
        .write(PaymentsCompanion(receiptSharedAt: Value(_timestamp)));
  }

  /// Turns advance credit into real allocations against open dues, oldest
  /// credit and oldest due first (design 7.3). Credit that no due can take
  /// stays as credit. Call inside the transaction of whatever created the
  /// credit or the due.
  Future<void> applyCredit(String studentId) {
    return _db.transaction(() async {
      final creditRows =
          await (_db.select(_db.paymentAllocations).join([
                  innerJoin(
                    _db.payments,
                    _db.payments.id.equalsExp(_db.paymentAllocations.paymentId),
                  ),
                ])
                ..where(
                  _db.paymentAllocations.studentId.equals(studentId) &
                      _db.paymentAllocations.feeRecordId.isNull() &
                      _db.payments.deletedAt.isNull(),
                )
                ..orderBy([
                  OrderingTerm.asc(_db.payments.receivedOn),
                  OrderingTerm.asc(_db.payments.receiptNo),
                  OrderingTerm.asc(_db.paymentAllocations.id),
                ]))
              .get();
      if (creditRows.isEmpty) return;

      // Mutable copies: [dueId, balance left].
      final dues = [
        for (final d in await openDues(studentId)) [d.id, d.balance],
      ];
      var index = 0;

      for (final row in creditRows) {
        if (index >= dues.length) break;
        final credit = row.readTable(_db.paymentAllocations);
        var remaining = credit.amount;
        final pieces = <AllocationLine>[];
        while (remaining > 0 && index < dues.length) {
          final balance = dues[index][1] as int;
          final applied = remaining < balance ? remaining : balance;
          pieces.add(
            AllocationLine(
              feeRecordId: dues[index][0] as String,
              amount: applied,
            ),
          );
          remaining -= applied;
          dues[index][1] = balance - applied;
          if (dues[index][1] == 0) index++;
        }
        if (pieces.isEmpty) continue;

        await (_db.delete(
          _db.paymentAllocations,
        )..where((a) => a.id.equals(credit.id))).go();
        await _insertLines(credit.paymentId, studentId, [
          ...pieces,
          if (remaining > 0)
            AllocationLine(feeRecordId: null, amount: remaining),
        ]);
      }
    });
  }

  /// Moves up to [amount] taka paid against [feeRecordId] back to advance
  /// credit, newest payment first. Used when a due is waived or discounted
  /// below what was already paid.
  Future<void> releaseToCredit(String feeRecordId, int amount) {
    return _db.transaction(() async {
      var toRelease = amount;
      final rows =
          await (_db.select(_db.paymentAllocations).join([
                  innerJoin(
                    _db.payments,
                    _db.payments.id.equalsExp(_db.paymentAllocations.paymentId),
                  ),
                ])
                ..where(
                  _db.paymentAllocations.feeRecordId.equals(feeRecordId) &
                      _db.payments.deletedAt.isNull(),
                )
                ..orderBy([
                  OrderingTerm.desc(_db.payments.receivedOn),
                  OrderingTerm.desc(_db.payments.receiptNo),
                  OrderingTerm.desc(_db.paymentAllocations.id),
                ]))
              .get();

      for (final row in rows) {
        if (toRelease <= 0) break;
        final a = row.readTable(_db.paymentAllocations);
        if (a.amount <= toRelease) {
          await (_db.update(
            _db.paymentAllocations,
          )..where((t) => t.id.equals(a.id))).write(
            const PaymentAllocationsCompanion(feeRecordId: Value(null)),
          );
          toRelease -= a.amount;
        } else {
          await (_db.update(
            _db.paymentAllocations,
          )..where((t) => t.id.equals(a.id))).write(
            PaymentAllocationsCompanion(amount: Value(a.amount - toRelease)),
          );
          await _insertLines(a.paymentId, a.studentId, [
            AllocationLine(feeRecordId: null, amount: toRelease),
          ]);
          toRelease = 0;
        }
      }
    });
  }

  // ---- internals --------------------------------------------------------

  Future<void> _insertLines(
    String paymentId,
    String studentId,
    List<AllocationLine> lines,
  ) async {
    for (final line in lines) {
      await _db
          .into(_db.paymentAllocations)
          .insert(
            PaymentAllocationsCompanion.insert(
              id: _newId(),
              paymentId: paymentId,
              feeRecordId: Value(line.feeRecordId),
              studentId: studentId,
              amount: line.amount,
            ),
          );
    }
  }

  Future<void> _deleteAllocations(String paymentId) => (_db.delete(
    _db.paymentAllocations,
  )..where((a) => a.paymentId.equals(paymentId))).go();

  String? _clean(String? v) {
    final t = v?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}
