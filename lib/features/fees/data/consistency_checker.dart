import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';

enum ConsistencyIssueKind {
  /// A deleted payment still has allocation rows.
  allocationOnDeletedPayment,

  /// A live payment's allocations do not add up to its amount.
  allocationSumMismatch,

  /// A due has been paid more than it is payable.
  negativeBalance,

  /// A waived due still holds payments (they should have become credit).
  waivedDueHoldsPayment,

  /// Two monthly dues for one student and month.
  duplicateMonthlyDue,

  /// An allocation's student differs from its payment's or due's student.
  allocationStudentMismatch,

  /// The next receipt number is not above every issued receipt number.
  receiptCounterBehind,
}

class ConsistencyIssue {
  const ConsistencyIssue(this.kind, this.entityId, this.message);

  final ConsistencyIssueKind kind;

  /// The id of the offending row. No names or phone numbers are included.
  final String entityId;
  final String message;

  @override
  String toString() => '${kind.name}: $message ($entityId)';
}

/// Checks the money data for the inconsistencies the design says can never
/// happen (design section 15). Run it from the developer menu and after a
/// restore. An empty result means the ledger is sound.
class ConsistencyChecker {
  ConsistencyChecker(this._db, this._settings);

  final AppDatabase _db;
  final SettingsStore _settings;

  Future<List<ConsistencyIssue>> run() async {
    final issues = <ConsistencyIssue>[];

    Future<void> check(
      String sql,
      ConsistencyIssueKind kind,
      String Function(Map<String, Object?> row) message, {
      String idColumn = 'id',
    }) async {
      final rows = await _db.customSelect(sql).get();
      for (final r in rows) {
        issues.add(
          ConsistencyIssue(kind, '${r.data[idColumn]}', message(r.data)),
        );
      }
    }

    await check(
      '''
      SELECT a.id AS id, a.payment_id AS payment_id
      FROM payment_allocations a
      JOIN payments p ON p.id = a.payment_id
      WHERE p.deleted_at IS NOT NULL
      ''',
      ConsistencyIssueKind.allocationOnDeletedPayment,
      (r) => 'allocation of deleted payment ${r['payment_id']}',
    );

    await check(
      '''
      SELECT p.id AS id, p.amount AS amount,
             COALESCE(SUM(a.amount), 0) AS allocated
      FROM payments p
      LEFT JOIN payment_allocations a ON a.payment_id = p.id
      WHERE p.deleted_at IS NULL
      GROUP BY p.id
      HAVING allocated != p.amount
      ''',
      ConsistencyIssueKind.allocationSumMismatch,
      (r) => 'payment of ${r['amount']} has ${r['allocated']} allocated',
    );

    await check(
      '''
      SELECT fee_record_id AS id, balance, month
      FROM fee_balances
      WHERE balance < 0
      ''',
      ConsistencyIssueKind.negativeBalance,
      (r) => 'balance ${r['balance']} for month ${r['month']}',
    );

    await check(
      '''
      SELECT fee_record_id AS id, paid, month
      FROM fee_balances
      WHERE waived = 1 AND paid > 0
      ''',
      ConsistencyIssueKind.waivedDueHoldsPayment,
      (r) => 'waived month ${r['month']} holds ${r['paid']}',
    );

    await check(
      '''
      SELECT student_id || '/' || month AS id, COUNT(*) AS n
      FROM fee_records
      WHERE kind = 'monthly'
      GROUP BY student_id, month
      HAVING n > 1
      ''',
      ConsistencyIssueKind.duplicateMonthlyDue,
      (r) => '${r['n']} monthly dues for one month',
    );

    await check(
      '''
      SELECT a.id AS id
      FROM payment_allocations a
      JOIN payments p ON p.id = a.payment_id
      LEFT JOIN fee_records f ON f.id = a.fee_record_id
      WHERE a.student_id != p.student_id
         OR (a.fee_record_id IS NOT NULL AND f.student_id != a.student_id)
      ''',
      ConsistencyIssueKind.allocationStudentMismatch,
      (_) =>
          'allocation belongs to a different student than its payment or due',
    );

    final maxReceipt =
        (await _db
                .customSelect(
                  'SELECT COALESCE(MAX(receipt_no), 0) AS m FROM payments',
                )
                .getSingle())
            .read<int>('m');
    final next = await _settings.get(SettingKeys.nextReceiptNo);
    if (next <= maxReceipt) {
      issues.add(
        ConsistencyIssue(
          ConsistencyIssueKind.receiptCounterBehind,
          'next_receipt_no',
          'next receipt number $next is not above the highest issued $maxReceipt',
        ),
      );
    }

    return issues;
  }
}
