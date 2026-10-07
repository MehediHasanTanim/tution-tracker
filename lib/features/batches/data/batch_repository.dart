import 'dart:convert';

import 'package:drift/drift.dart' hide Batch;
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/text_normalizer.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:uuid/uuid.dart';

extension BatchRow on Batch {
  bool get isArchived => status == 'archived';

  /// ISO weekdays, ascending.
  List<int> get scheduleDayList =>
      (jsonDecode(scheduleDays) as List<dynamic>).cast<int>();

  ClockTime? get startTimeValue {
    final raw = startTime;
    return raw == null ? null : ClockTime.parse(raw);
  }
}

class BatchSummary {
  const BatchSummary(this.batch, this.memberCount);

  final Batch batch;

  /// Current members (those who have not left).
  final int memberCount;
}

class BatchMemberView {
  const BatchMemberView(this.member, this.student);

  final BatchMember member;
  final Student student;

  /// The fee this student pays for the batch: their override, or the batch
  /// default.
  int effectiveFee(Batch batch) => member.feeOverride ?? batch.defaultFee;
}

class BatchRepository {
  BatchRepository(
    this._db, {
    DateTime Function()? now,
    String Function()? newId,
  }) : _now = now ?? DateTime.now,
       _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final DateTime Function() _now;
  final String Function() _newId;

  int get _timestamp => _now().toUtc().millisecondsSinceEpoch;

  /// Throws [BatchValidationException] for an invalid [draft].
  Future<Batch> create(BatchDraft draft) async {
    _check(draft);
    final id = _newId();
    final ts = _timestamp;
    await _db
        .into(_db.batches)
        .insert(
          BatchesCompanion.insert(
            id: id,
            name: normalizeText(draft.name),
            scheduleDays: _days(draft.scheduleDays),
            subject: Value(_text(draft.subject)),
            classLevel: Value(_text(draft.classLevel)),
            startTime: Value(draft.startTime?.toKey()),
            durationMin: Value(draft.durationMin),
            defaultFee: Value(draft.defaultFee),
            createdAt: ts,
            updatedAt: ts,
          ),
        );
    return (await getById(id))!;
  }

  Future<Batch> update(String id, BatchDraft draft) async {
    _check(draft);
    final updated =
        await (_db.update(_db.batches)..where((t) => t.id.equals(id))).write(
          BatchesCompanion(
            name: Value(normalizeText(draft.name)),
            scheduleDays: Value(_days(draft.scheduleDays)),
            subject: Value(_text(draft.subject)),
            classLevel: Value(_text(draft.classLevel)),
            startTime: Value(draft.startTime?.toKey()),
            durationMin: Value(draft.durationMin),
            defaultFee: Value(draft.defaultFee),
            updatedAt: Value(_timestamp),
          ),
        );
    if (updated == 0) throw StateError('No batch with id $id');
    return (await getById(id))!;
  }

  Future<void> _setStatus(String id, String status) async {
    await (_db.update(_db.batches)..where((t) => t.id.equals(id))).write(
      BatchesCompanion(status: Value(status), updatedAt: Value(_timestamp)),
    );
  }

  /// Hides the batch from the default list; members and history are kept.
  Future<void> archive(String id) => _setStatus(id, 'archived');

  Future<void> restore(String id) => _setStatus(id, 'active');

  Future<Batch?> getById(String id) => (_db.select(
    _db.batches,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Batch?> watchById(String id) => (_db.select(
    _db.batches,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// Batches with their current member counts, sorted by name.
  Stream<List<BatchSummary>> watchSummaries({bool includeArchived = false}) {
    final b = _db.batches;
    final m = _db.batchMembers;
    final count = m.id.count();
    final query =
        _db.select(b).join([
            leftOuterJoin(m, m.batchId.equalsExp(b.id) & m.leftOn.isNull()),
          ])
          ..addColumns([count])
          ..groupBy([b.id])
          ..orderBy([OrderingTerm.asc(b.name.collate(Collate.noCase))]);
    if (!includeArchived) query.where(b.status.equals('active'));
    return query.watch().map(
      (rows) => [
        for (final r in rows) BatchSummary(r.readTable(b), r.read(count) ?? 0),
      ],
    );
  }

  /// Current members, sorted by student name.
  Stream<List<BatchMemberView>> watchMembers(String batchId) {
    final m = _db.batchMembers;
    final s = _db.students;
    final query =
        _db.select(m).join([innerJoin(s, s.id.equalsExp(m.studentId))])
          ..where(m.batchId.equals(batchId) & m.leftOn.isNull())
          ..orderBy([OrderingTerm.asc(s.name.collate(Collate.noCase))]);
    return query.watch().map(
      (rows) => [
        for (final r in rows) BatchMemberView(r.readTable(m), r.readTable(s)),
      ],
    );
  }

  /// Active batches [studentId] currently belongs to.
  Stream<List<Batch>> watchBatchesOfStudent(String studentId) {
    final b = _db.batches;
    final m = _db.batchMembers;
    final query = _db.select(b).join([innerJoin(m, m.batchId.equalsExp(b.id))])
      ..where(
        m.studentId.equals(studentId) &
            m.leftOn.isNull() &
            b.status.equals('active'),
      )
      ..orderBy([OrderingTerm.asc(b.name.collate(Collate.noCase))]);
    return query.watch().map((rows) => [for (final r in rows) r.readTable(b)]);
  }

  /// Adds students to a batch as of [joinedOn]; returns how many were added.
  ///
  /// A student already in the batch is skipped. One who left earlier is
  /// re-activated: the table keeps a single row per batch and student, so
  /// their original join date is kept.
  Future<int> addMembers(
    String batchId,
    List<String> studentIds,
    LocalDate joinedOn,
  ) {
    return _db.transaction(() async {
      var added = 0;
      for (final studentId in studentIds) {
        final existing =
            await (_db.select(_db.batchMembers)..where(
                  (t) =>
                      t.batchId.equals(batchId) & t.studentId.equals(studentId),
                ))
                .getSingleOrNull();
        if (existing == null) {
          await _db
              .into(_db.batchMembers)
              .insert(
                BatchMembersCompanion.insert(
                  id: _newId(),
                  batchId: batchId,
                  studentId: studentId,
                  joinedOn: joinedOn.toIso(),
                ),
              );
          added++;
        } else if (existing.leftOn != null) {
          await (_db.update(_db.batchMembers)
                ..where((t) => t.id.equals(existing.id)))
              .write(const BatchMembersCompanion(leftOn: Value(null)));
          added++;
        }
      }
      return added;
    });
  }

  /// Marks the student as having left on [leftOn]. The row stays, so past
  /// attendance can still tell who was enrolled when.
  Future<void> removeMember(
    String batchId,
    String studentId,
    LocalDate leftOn,
  ) async {
    await (_db.update(_db.batchMembers)..where(
          (t) =>
              t.batchId.equals(batchId) &
              t.studentId.equals(studentId) &
              t.leftOn.isNull(),
        ))
        .write(BatchMembersCompanion(leftOn: Value(leftOn.toIso())));
  }

  /// Sets the student's own fee for this batch; null goes back to the batch
  /// default.
  Future<void> setFeeOverride(
    String batchId,
    String studentId,
    int? fee,
  ) async {
    if (fee != null && fee < 0) throw ArgumentError.value(fee, 'fee');
    await (_db.update(_db.batchMembers)..where(
          (t) => t.batchId.equals(batchId) & t.studentId.equals(studentId),
        ))
        .write(BatchMembersCompanion(feeOverride: Value(fee)));
  }

  void _check(BatchDraft draft) {
    final errors = draft.validate();
    if (errors.isNotEmpty) throw BatchValidationException(errors);
  }

  String? _text(String? value) {
    if (value == null) return null;
    final text = normalizeText(value);
    return text.isEmpty ? null : text;
  }

  String _days(List<int> days) {
    final cleaned = ({...days}.where((d) => d >= 1 && d <= 7).toList())..sort();
    return jsonEncode(cleaned);
  }
}
