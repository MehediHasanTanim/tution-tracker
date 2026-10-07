import 'package:drift/drift.dart';
import 'package:tution_tracker/core/db/app_database.dart';

/// Minimal row builders so constraint tests stay short.
Future<void> insertStudent(
  AppDatabase db,
  String id, {
  String name = 'Rahim',
}) => db
    .into(db.students)
    .insert(
      StudentsCompanion.insert(
        id: id,
        name: name,
        joinedOn: '2026-01-01',
        monthlyFee: 1500,
        createdAt: 0,
        updatedAt: 0,
      ),
    );

Future<void> insertBatch(AppDatabase db, String id) => db
    .into(db.batches)
    .insert(
      BatchesCompanion.insert(
        id: id,
        name: 'Math 9',
        scheduleDays: '[1,3,5]',
        createdAt: 0,
        updatedAt: 0,
      ),
    );

Future<void> insertFee(
  AppDatabase db,
  String id,
  String studentId,
  String month, {
  String kind = 'monthly',
}) => db
    .into(db.feeRecords)
    .insert(
      FeeRecordsCompanion.insert(
        id: id,
        studentId: studentId,
        month: month,
        kind: Value(kind),
        amountDue: 1500,
        dueDate: '$month-10',
        createdAt: 0,
      ),
    );

Future<void> insertPayment(
  AppDatabase db,
  String id,
  String studentId, {
  int amount = 1500,
  int receiptNo = 1,
}) => db
    .into(db.payments)
    .insert(
      PaymentsCompanion.insert(
        id: id,
        studentId: studentId,
        amount: amount,
        receivedOn: '2026-01-10',
        receiptNo: receiptNo,
        createdAt: 0,
      ),
    );
