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

  /// [generateForStudent] for every student. Returns the dues created.
  Future<int> generateForAll() {
    return _db.transaction(() async {
      final students = await (_db.select(
        _db.students,
      )..where((s) => s.status.isNotValue('left'))).get();
      var created = 0;
      for (final s in students) {
        created += await generateForStudent(s.id);
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
