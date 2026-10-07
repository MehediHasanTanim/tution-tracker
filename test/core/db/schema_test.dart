import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';

import '../../support/db_fixtures.dart';

/// Runs [body] and expects SQLite to reject it with a constraint error.
Future<void> expectConstraintViolation(Future<Object?> Function() body) async {
  await expectLater(
    body,
    throwsA(
      isA<Object>().having(
        (e) => e.toString(),
        'message',
        contains('constraint'),
      ),
    ),
  );
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = openInMemoryDatabase();
    await insertStudent(db, 's1');
  });

  tearDown(() => db.close());

  test('schema creates cleanly with foreign keys on', () async {
    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.data.values.single, 1);
    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    expect(
      tables.map((r) => r.read<String>('name')),
      containsAll([
        'students',
        'batches',
        'batch_members',
        'class_sessions',
        'attendance',
        'fee_records',
        'payments',
        'payment_allocations',
        'fee_changes',
        'pauses',
        'settings',
        'message_templates',
        'audit_log',
      ]),
    );
    expect(db.schemaVersion, 1);
  });

  group('fee_records', () {
    test(
      'rejects a duplicate monthly due for the same student and month',
      () async {
        await insertFee(db, 'f1', 's1', '2026-01');
        await expectConstraintViolation(
          () => insertFee(db, 'f2', 's1', '2026-01'),
        );
      },
    );

    test(
      'allows the same month for another student or another month',
      () async {
        await insertStudent(db, 's2');
        await insertFee(db, 'f1', 's1', '2026-01');
        await insertFee(db, 'f2', 's2', '2026-01');
        await insertFee(db, 'f3', 's1', '2026-02');
      },
    );

    test('one-time fees are not limited to one per month', () async {
      await insertFee(db, 'f1', 's1', '2026-01', kind: 'one_time');
      await insertFee(db, 'f2', 's1', '2026-01', kind: 'one_time');
      await insertFee(db, 'f3', 's1', '2026-01'); // plus the monthly one
    });

    test('INSERT OR IGNORE makes due generation idempotent', () async {
      await insertFee(db, 'f1', 's1', '2026-01');
      await db.customStatement(
        'INSERT OR IGNORE INTO fee_records (id, student_id, month, amount_due, due_date, created_at) '
        "VALUES ('f2', 's1', '2026-01', 1500, '2026-01-10', 0)",
      );
      final count = await db
          .customSelect('SELECT COUNT(*) c FROM fee_records')
          .getSingle();
      expect(count.read<int>('c'), 1);
    });

    test('rejects unknown kind and bad waived flag', () async {
      await expectConstraintViolation(
        () => insertFee(db, 'f1', 's1', '2026-01', kind: 'weekly'),
      );
      await expectConstraintViolation(
        () => db.customStatement(
          'INSERT INTO fee_records (id, student_id, month, amount_due, waived, due_date, created_at) '
          "VALUES ('f9', 's1', '2026-03', 1500, 2, '2026-03-10', 0)",
        ),
      );
    });
  });

  group('attendance', () {
    setUp(() async {
      await insertBatch(db, 'b1');
      await db
          .into(db.classSessions)
          .insert(
            ClassSessionsCompanion.insert(
              id: 'c1',
              batchId: const Value('b1'),
              date: '2026-01-05',
            ),
          );
    });

    Future<void> mark(String id, String status) => db
        .into(db.attendance)
        .insert(
          AttendanceCompanion.insert(
            id: id,
            sessionId: 'c1',
            studentId: 's1',
            status: status,
          ),
        );

    test('rejects a duplicate row for the same session and student', () async {
      await mark('a1', 'present');
      await expectConstraintViolation(() => mark('a2', 'absent'));
    });

    test('rejects an unknown status', () async {
      await expectConstraintViolation(() => mark('a1', 'sleeping'));
    });

    test('deleting a session cascades to its attendance', () async {
      await mark('a1', 'present');
      await (db.delete(db.classSessions)..where((t) => t.id.equals('c1'))).go();
      final rows = await db.select(db.attendance).get();
      expect(rows, isEmpty);
    });
  });

  group('class_sessions', () {
    setUp(() => insertBatch(db, 'b1'));

    Future<void> session(
      String id, {
      String? start,
      String date = '2026-01-05',
    }) => db
        .into(db.classSessions)
        .insert(
          ClassSessionsCompanion.insert(
            id: id,
            batchId: const Value('b1'),
            date: date,
            startTime: Value(start),
          ),
        );

    test('rejects the same batch, date and start time twice', () async {
      await session('c1', start: '17:00');
      await expectConstraintViolation(() => session('c2', start: '17:00'));
    });

    test('rejects two sessions with no start time on the same day', () async {
      await session('c1');
      await expectConstraintViolation(() => session('c2'));
    });

    test('allows two classes at different times on one day', () async {
      await session('c1', start: '09:00');
      await session('c2', start: '17:00');
    });

    test('rejects a one-to-one duplicate for the same student', () async {
      Future<void> one(String id) => db
          .into(db.classSessions)
          .insert(
            ClassSessionsCompanion.insert(
              id: id,
              studentId: const Value('s1'),
              date: '2026-01-05',
              startTime: const Value('16:00'),
            ),
          );
      await one('c1');
      await expectConstraintViolation(() => one('c2'));
    });

    test('requires a batch or a student', () async {
      await expectConstraintViolation(
        () => db
            .into(db.classSessions)
            .insert(
              ClassSessionsCompanion.insert(id: 'c1', date: '2026-01-05'),
            ),
      );
    });
  });

  group('payments', () {
    test('amount must be positive', () async {
      await expectConstraintViolation(
        () => insertPayment(db, 'p1', 's1', amount: 0),
      );
      await expectConstraintViolation(
        () => insertPayment(db, 'p1', 's1', amount: -5),
      );
    });

    test('receipt numbers are unique', () async {
      await insertPayment(db, 'p1', 's1', receiptNo: 7);
      await expectConstraintViolation(
        () => insertPayment(db, 'p2', 's1', receiptNo: 7),
      );
    });

    test('allocation amount must be positive and payment must exist', () async {
      await insertPayment(db, 'p1', 's1');
      Future<void> alloc(String id, String paymentId, int amount) => db
          .into(db.paymentAllocations)
          .insert(
            PaymentAllocationsCompanion.insert(
              id: id,
              paymentId: paymentId,
              studentId: 's1',
              amount: amount,
            ),
          );
      await alloc('al1', 'p1', 1500); // NULL fee record = advance credit
      await expectConstraintViolation(() => alloc('al2', 'p1', 0));
      await expectConstraintViolation(() => alloc('al3', 'missing', 100));
    });

    test('deleting a payment row cascades to its allocations', () async {
      await insertPayment(db, 'p1', 's1');
      await db
          .into(db.paymentAllocations)
          .insert(
            PaymentAllocationsCompanion.insert(
              id: 'al1',
              paymentId: 'p1',
              studentId: 's1',
              amount: 1500,
            ),
          );
      await (db.delete(db.payments)..where((t) => t.id.equals('p1'))).go();
      expect(await db.select(db.paymentAllocations).get(), isEmpty);
    });
  });

  group('other constraints', () {
    test('foreign keys are enforced', () async {
      await expectConstraintViolation(
        () => insertFee(db, 'f1', 'nobody', '2026-01'),
      );
    });

    test('batch membership is unique per batch and student', () async {
      await insertBatch(db, 'b1');
      Future<void> join(String id) => db
          .into(db.batchMembers)
          .insert(
            BatchMembersCompanion.insert(
              id: id,
              batchId: 'b1',
              studentId: 's1',
              joinedOn: '2026-01-01',
            ),
          );
      await join('m1');
      await expectConstraintViolation(() => join('m2'));
    });

    test('a student can be in several batches', () async {
      await insertBatch(db, 'b1');
      await insertBatch(db, 'b2');
      for (final (i, b) in ['b1', 'b2'].indexed) {
        await db
            .into(db.batchMembers)
            .insert(
              BatchMembersCompanion.insert(
                id: 'm$i',
                batchId: b,
                studentId: 's1',
                joinedOn: '2026-01-01',
              ),
            );
      }
    });

    test('fee changes are unique per student and effective month', () async {
      Future<void> change(String id) => db
          .into(db.feeChanges)
          .insert(
            FeeChangesCompanion.insert(
              id: id,
              studentId: 's1',
              effectiveMonth: '2026-03',
              newAmount: 2000,
            ),
          );
      await change('c1');
      await expectConstraintViolation(() => change('c2'));
    });

    test('student status and due day are validated', () async {
      Future<void> raw(String status, int dueDay) => db.customStatement(
        'INSERT INTO students (id, name, joined_on, status, monthly_fee, fee_due_day, created_at, updated_at) '
        "VALUES ('x$status$dueDay', 'X', '2026-01-01', '$status', 100, $dueDay, 0, 0)",
      );
      await raw('active', 31);
      await expectConstraintViolation(() => raw('gone', 10));
      await expectConstraintViolation(() => raw('active', 0));
      await expectConstraintViolation(() => raw('active', 32));
    });

    test('settings is a key/value table', () async {
      await db
          .into(db.settings)
          .insert(SettingsCompanion.insert(key: 'language', value: 'bn'));
      final row = await db.select(db.settings).getSingle();
      expect(row.key, 'language');
      expect(row.value, 'bn');
    });
  });
}
