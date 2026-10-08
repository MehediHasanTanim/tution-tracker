import 'package:drift/drift.dart';
import 'package:tution_tracker/core/db/app_database.dart';

/// What the stress dataset holds (spec section 6 and plan S5-03).
class StressSizes {
  const StressSizes({
    this.students = 500,
    this.batches = 25,
    this.sessionsPerBatch = 40,
    this.dueMonths = 14,
    this.paidMonths = 12,
  });

  final int students;
  final int batches;

  /// Class sessions per batch; with 20 students each, 40 sessions is 800 rows
  /// of attendance per batch, 20,000 in all.
  final int sessionsPerBatch;

  /// Months of fee records per student, ending October 2026.
  final int dueMonths;

  /// How many of the oldest months are paid; the rest stay open.
  final int paidMonths;

  int get payments => students * paidMonths;
}

String _two(int v) => v.toString().padLeft(2, '0');

/// Fills [db] with a realistic busy tutor: 500 students in 25 batches, a year
/// of dues and payments, 20,000 attendance marks. Deterministic.
Future<void> seedStress(
  AppDatabase db, [
  StressSizes sizes = const StressSizes(),
]) async {
  final months = <String>[];
  var y = 2025, m = 9;
  for (var i = 0; i < sizes.dueMonths; i++) {
    months.add('$y-${_two(m)}');
    m++;
    if (m > 12) {
      m = 1;
      y++;
    }
  }

  await db.batch((b) {
    for (var i = 0; i < sizes.batches; i++) {
      b.insert(
        db.batches,
        BatchesCompanion.insert(
          id: 'b$i',
          name: 'Batch $i',
          scheduleDays: '[1,3,5]',
          createdAt: 1,
          updatedAt: 1,
          startTime: Value('${_two(15 + i % 6)}:00'),
        ),
      );
    }
    for (var i = 0; i < sizes.students; i++) {
      b.insert(
        db.students,
        StudentsCompanion.insert(
          id: 's$i',
          name: i.isEven ? 'শিক্ষার্থী নম্বর $i' : 'Student Number $i',
          joinedOn: '2025-08-15',
          monthlyFee: 1000 + (i % 5) * 250,
          createdAt: 1,
          updatedAt: 1,
          feeDueDay: Value(1 + i % 28),
          guardianPhone: Value('017${(10000000 + i).toString()}'),
        ),
      );
      b.insert(
        db.batchMembers,
        BatchMembersCompanion.insert(
          id: 'bm$i',
          batchId: 'b${i % sizes.batches}',
          studentId: 's$i',
          joinedOn: '2025-08-15',
        ),
      );
    }
  });

  await db.batch((b) {
    var receipt = 1;
    for (var i = 0; i < sizes.students; i++) {
      final fee = 1000 + (i % 5) * 250;
      for (var k = 0; k < months.length; k++) {
        final month = months[k];
        b.insert(
          db.feeRecords,
          FeeRecordsCompanion.insert(
            id: 'f${i}_$k',
            studentId: 's$i',
            month: month,
            amountDue: fee,
            dueDate: '$month-${_two(1 + i % 28)}',
            createdAt: 1,
          ),
        );
        if (k < sizes.paidMonths) {
          b.insert(
            db.payments,
            PaymentsCompanion.insert(
              id: 'p${i}_$k',
              studentId: 's$i',
              amount: fee,
              receivedOn: '$month-${_two(1 + (i + k) % 28)}',
              receiptNo: receipt++,
              createdAt: 1,
            ),
          );
          b.insert(
            db.paymentAllocations,
            PaymentAllocationsCompanion.insert(
              id: 'a${i}_$k',
              paymentId: 'p${i}_$k',
              feeRecordId: Value('f${i}_$k'),
              studentId: 's$i',
              amount: fee,
            ),
          );
        }
      }
    }
  });

  // The receipt counter, as the app would have left it.
  await db.customStatement(
    "INSERT INTO settings (key, value) VALUES ('next_receipt_no', '${sizes.payments + 1}')",
  );

  final perBatch = sizes.students ~/ sizes.batches;
  await db.batch((b) {
    for (var bi = 0; bi < sizes.batches; bi++) {
      for (var s = 0; s < sizes.sessionsPerBatch; s++) {
        final month = months[s % months.length];
        final day = 1 + (s ~/ months.length) * 9;
        b.insert(
          db.classSessions,
          ClassSessionsCompanion.insert(
            id: 'cs${bi}_$s',
            batchId: Value('b$bi'),
            date: '$month-${_two(day)}',
            startTime: Value('${_two(15 + bi % 6)}:00'),
          ),
        );
        for (var k = 0; k < perBatch; k++) {
          final student = bi + k * sizes.batches;
          b.insert(
            db.attendance,
            AttendanceCompanion.insert(
              id: 'at${bi}_${s}_$k',
              sessionId: 'cs${bi}_$s',
              studentId: 's$student',
              status: (s + k) % 9 == 0 ? 'absent' : 'present',
            ),
          );
        }
      }
    }
  });
}
