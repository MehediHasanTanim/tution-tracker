import 'package:drift/drift.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/features/fees/domain/payment_method.dart';
import 'package:tution_tracker/features/receipts/domain/receipt_data.dart';

/// Builds [ReceiptData] from a stored payment.
class ReceiptRepository {
  ReceiptRepository(this._db);

  final AppDatabase _db;

  /// The receipt for [paymentId], or null if there is no such payment or it
  /// was deleted (a deleted payment has no receipt).
  Future<ReceiptData?> forPayment(String paymentId) async {
    final payment =
        await (_db.select(_db.payments)
              ..where((p) => p.id.equals(paymentId) & p.deletedAt.isNull()))
            .getSingleOrNull();
    if (payment == null) return null;
    final student = await (_db.select(
      _db.students,
    )..where((s) => s.id.equals(payment.studentId))).getSingle();

    final rows = await (_db.select(_db.paymentAllocations).join([
      leftOuterJoin(
        _db.feeRecords,
        _db.feeRecords.id.equalsExp(_db.paymentAllocations.feeRecordId),
      ),
    ])..where(_db.paymentAllocations.paymentId.equals(paymentId))).get();

    final allocations = [
      for (final r in rows)
        () {
          final a = r.readTable(_db.paymentAllocations);
          final fee = r.readTableOrNull(_db.feeRecords);
          return AllocationInfo(
            amount: a.amount,
            month: fee == null ? null : YearMonth.parse(fee.month),
            label: fee?.kind == 'one_time' ? fee?.label : null,
            dueKey: a.feeRecordId,
          );
        }(),
    ];

    return ReceiptData(
      receiptNo: payment.receiptNo,
      date: LocalDate.parse(payment.receivedOn),
      studentName: student.name,
      guardianName: student.guardianName,
      amount: payment.amount,
      method: PaymentMethod.values.byName(payment.method),
      reference: payment.reference,
      lines: receiptLines(allocations),
    );
  }
}
