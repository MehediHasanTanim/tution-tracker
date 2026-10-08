import 'package:drift/drift.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/fees/domain/due_generation.dart';
import 'package:uuid/uuid.dart';

/// Creates the monthly dues that are missing, then lets advance credit settle
/// them (design 7.1).
///
/// Generation is lazy and idempotent: it runs on app start and resume, and
/// whenever a student, fee or pause changes, and only ever fills months that
/// have no due yet. Running it twice creates nothing the second time.
class DueService {
  DueService(
    this._db,
    this._settings,
    this._payments, {
    DateTime Function()? now,
    String Function()? newId,
  }) : _now = now ?? DateTime.now,
       _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final SettingsStore _settings;
  final PaymentRepository _payments;
  final DateTime Function() _now;
  final String Function() _newId;

  YearMonth get currentMonth => YearMonth.from(todayFrom(_now));

  /// Generates [studentId]'s missing dues up to the current month and applies
  /// credit to them. Returns how many dues were created. Archived students
  /// get nothing.
  Future<int> generateForStudent(String studentId) {
    return _db.transaction(() async {
      final student = await (_db.select(
        _db.students,
      )..where((s) => s.id.equals(studentId))).getSingleOrNull();
      if (student == null || student.status == 'left') return 0;

      final existing =
          await (_db.select(_db.feeRecords)..where(
                (f) => f.studentId.equals(studentId) & f.kind.equals('monthly'),
              ))
              .get();
      final changes = await (_db.select(
        _db.feeChanges,
      )..where((c) => c.studentId.equals(studentId))).get();
      final pauses = await (_db.select(
        _db.pauses,
      )..where((p) => p.studentId.equals(studentId))).get();

      final drafts = generateDues(
        studentId: studentId,
        joinedOn: LocalDate.parse(student.joinedOn),
        feeDueDay: student.feeDueDay,
        baseFee: student.monthlyFee,
        upTo: currentMonth,
        rule: await _settings.get(SettingKeys.proration),
        changes: [
          for (final c in changes)
            FeeChangeEntry(YearMonth.parse(c.effectiveMonth), c.newAmount),
        ],
        pauses: [
          for (final p in pauses)
            PauseEntry(
              YearMonth.parse(p.fromMonth),
              p.toMonth == null ? null : YearMonth.parse(p.toMonth!),
            ),
        ],
        batchAdjustments: await _batchAdjustments(studentId),
        existing: {for (final f in existing) YearMonth.parse(f.month)},
      );

      final createdAt = _now().toUtc().millisecondsSinceEpoch;
      for (final d in drafts) {
        // OR IGNORE: the partial unique index makes a concurrent duplicate a
        // no-op instead of an error.
        await _db
            .into(_db.feeRecords)
            .insert(
              FeeRecordsCompanion.insert(
                id: _newId(),
                studentId: studentId,
                month: d.month.toKey(),
                amountDue: d.amountDue,
                dueDate: d.dueDate.toIso(),
                createdAt: createdAt,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      await _payments.applyCredit(studentId);
      return drafts.length;
    });
  }

  /// [generateForStudent] for every student that could need it. Returns the
  /// dues created.
  ///
  /// This runs at every app start and resume, so the common case (everyone is
  /// up to date) must cost one query, not a handful per student. A student is
  /// only looked at when they have no due yet for the current month (a new
  /// month, a restored older backup, a pause) or hold advance credit still to
  /// be applied.
  Future<int> generateForAll() {
    return _db.transaction(() async {
      final rows = await _db
          .customSelect(
            'SELECT s.id AS id FROM students s '
            "WHERE s.status != 'left' AND ("
            ' NOT EXISTS (SELECT 1 FROM fee_records f '
            "  WHERE f.student_id = s.id AND f.kind = 'monthly' AND f.month >= ?)"
            ' OR EXISTS (SELECT 1 FROM payment_allocations a '
            '  WHERE a.student_id = s.id AND a.fee_record_id IS NULL))',
            variables: [Variable.withString(currentMonth.toKey())],
            readsFrom: {_db.students, _db.feeRecords, _db.paymentAllocations},
          )
          .get();
      var created = 0;
      for (final r in rows) {
        created += await generateForStudent(r.read<String>('id'));
      }
      return created;
    });
  }

  Future<List<BatchFeeAdjustment>> _batchAdjustments(String studentId) async {
    final rows =
        await (_db.select(_db.batchMembers).join([
              innerJoin(
                _db.batches,
                _db.batches.id.equalsExp(_db.batchMembers.batchId),
              ),
            ])..where(
              _db.batchMembers.studentId.equals(studentId) &
                  _db.batchMembers.feeOverride.isNotNull() &
                  _db.batches.status.equals('active'),
            ))
            .get();
    return [
      for (final r in rows)
        BatchFeeAdjustment(
          reduction:
              r.readTable(_db.batches).defaultFee -
              r.readTable(_db.batchMembers).feeOverride!,
          from: YearMonth.from(
            LocalDate.parse(r.readTable(_db.batchMembers).joinedOn),
          ),
          to: r.readTable(_db.batchMembers).leftOn == null
              ? null
              : YearMonth.from(
                  LocalDate.parse(r.readTable(_db.batchMembers).leftOn!),
                ),
        ),
    ];
  }
}
