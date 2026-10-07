import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/digits.dart';
import 'package:tution_tracker/core/i18n/text_normalizer.dart';
import 'package:tution_tracker/core/utils/phone.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';
import 'package:tution_tracker/features/students/domain/student_filter.dart';
import 'package:tution_tracker/features/students/domain/student_status.dart';
import 'package:uuid/uuid.dart';

extension StudentRow on Student {
  StudentStatus get statusValue => StudentStatus.values.byName(status);

  List<String> get subjectList {
    final raw = subjects;
    if (raw == null || raw.isEmpty) return const [];
    return (jsonDecode(raw) as List<dynamic>).cast<String>();
  }
}

class StudentRepository {
  StudentRepository(
    this._db, {
    DateTime Function()? now,
    String Function()? newId,
  }) : _now = now ?? DateTime.now,
       _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final DateTime Function() _now;
  final String Function() _newId;

  int get _timestamp => _now().toUtc().millisecondsSinceEpoch;

  /// Saves a new student and its initial fee as the first `fee_changes` row,
  /// so fee lookup is uniform (design 7.1).
  /// Throws [StudentValidationException] for an invalid [draft].
  Future<Student> create(StudentDraft draft) async {
    _check(draft);
    return _db.transaction(() async {
      final id = _newId();
      final ts = _timestamp;
      await _db
          .into(_db.students)
          .insert(
            StudentsCompanion.insert(
              id: id,
              name: normalizeText(draft.name),
              joinedOn: draft.joinedOn.toIso(),
              monthlyFee: draft.monthlyFee,
              feeDueDay: Value(draft.feeDueDay),
              classLevel: Value(_text(draft.classLevel)),
              school: Value(_text(draft.school)),
              guardianName: Value(_text(draft.guardianName)),
              guardianPhone: Value(_phone(draft.guardianPhone)),
              studentPhone: Value(_phone(draft.studentPhone)),
              address: Value(_text(draft.address)),
              photoPath: Value(draft.photoPath),
              subjects: Value(_subjects(draft.subjects)),
              notes: Value(_text(draft.notes)),
              createdAt: ts,
              updatedAt: ts,
            ),
          );
      await _db
          .into(_db.feeChanges)
          .insert(
            FeeChangesCompanion.insert(
              id: _newId(),
              studentId: id,
              effectiveMonth: YearMonth.from(draft.joinedOn).toKey(),
              newAmount: draft.monthlyFee,
            ),
          );
      return (await getById(id))!;
    });
  }

  /// Updates every field except the monthly fee. Fee changes are dated
  /// events (`fee_changes`) so history is never rewritten (spec FE-7); that
  /// flow arrives with the fee adjustments in S2-12.
  Future<Student> update(String id, StudentDraft draft) async {
    _check(draft);
    final updated =
        await (_db.update(_db.students)..where((t) => t.id.equals(id))).write(
          StudentsCompanion(
            name: Value(normalizeText(draft.name)),
            joinedOn: Value(draft.joinedOn.toIso()),
            feeDueDay: Value(draft.feeDueDay),
            classLevel: Value(_text(draft.classLevel)),
            school: Value(_text(draft.school)),
            guardianName: Value(_text(draft.guardianName)),
            guardianPhone: Value(_phone(draft.guardianPhone)),
            studentPhone: Value(_phone(draft.studentPhone)),
            address: Value(_text(draft.address)),
            photoPath: Value(draft.photoPath),
            subjects: Value(_subjects(draft.subjects)),
            notes: Value(_text(draft.notes)),
            updatedAt: Value(_timestamp),
          ),
        );
    if (updated == 0) throw StateError('No student with id $id');
    return (await getById(id))!;
  }

  Future<void> setStatus(String id, StudentStatus status) async {
    await (_db.update(_db.students)..where((t) => t.id.equals(id))).write(
      StudentsCompanion(
        status: Value(status.name),
        updatedAt: Value(_timestamp),
      ),
    );
  }

  /// Hides the student from the default list; all history is kept.
  Future<void> archive(String id) => setStatus(id, StudentStatus.left);

  Future<void> restore(String id) => setStatus(id, StudentStatus.active);

  /// Permanently removes the student and everything recorded for them
  /// (spec ST-6). Returns the photo path so the caller can delete the file.
  Future<String?> deleteForever(String id) {
    return _db.transaction(() async {
      final student = await getById(id);
      if (student == null) return null;

      Future<void> where<T extends Table, D>(
        TableInfo<T, D> table,
        Expression<bool> Function(T t) filter,
      ) => (_db.delete(table)..where(filter)).go();

      await where(_db.paymentAllocations, (t) => t.studentId.equals(id));
      await where(_db.payments, (t) => t.studentId.equals(id));
      await where(_db.feeRecords, (t) => t.studentId.equals(id));
      await where(_db.feeChanges, (t) => t.studentId.equals(id));
      await where(_db.pauses, (t) => t.studentId.equals(id));
      await where(_db.attendance, (t) => t.studentId.equals(id));
      await where(_db.classSessions, (t) => t.studentId.equals(id));
      await where(_db.batchMembers, (t) => t.studentId.equals(id));
      await where(_db.students, (t) => t.id.equals(id));
      await _db
          .into(_db.auditLog)
          .insert(
            AuditLogCompanion.insert(
              id: _newId(),
              entity: 'student',
              entityId: id,
              action: 'delete',
              at: _timestamp,
            ),
          );
      return student.photoPath;
    });
  }

  Future<Student?> getById(String id) => (_db.select(
    _db.students,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Student?> watchById(String id) => (_db.select(
    _db.students,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<List<Student>> list([StudentFilter filter = const StudentFilter()]) =>
      _filtered(filter).get();

  /// Emits the matching students, again after any write that affects them.
  Stream<List<Student>> watch([StudentFilter filter = const StudentFilter()]) =>
      _filtered(filter).watch();

  /// Distinct class levels in use, for the filter picker.
  Stream<List<String>> watchClassLevels() {
    final query = _db.selectOnly(_db.students, distinct: true)
      ..addColumns([_db.students.classLevel])
      ..where(_db.students.classLevel.isNotNull())
      ..orderBy([OrderingTerm.asc(_db.students.classLevel)]);
    return query.watch().map(
      (rows) => [for (final r in rows) r.read(_db.students.classLevel)!],
    );
  }

  SimpleSelectStatement<Students, Student> _filtered(StudentFilter f) {
    final t = _db.students;
    final query = _db.select(t)
      ..where((s) {
        final conditions = <Expression<bool>>[
          s.status.isIn(f.statuses.map((e) => e.name)),
          ?(f.classLevel == null ? null : s.classLevel.equals(f.classLevel!)),
          ?_inBatch(s, f.batchId),
          ?_matchesQuery(s, f.query),
        ];
        return conditions.reduce((a, b) => a & b);
      })
      ..orderBy([
        (s) => OrderingTerm.asc(s.name.collate(Collate.noCase)),
        (s) => OrderingTerm.asc(s.id),
      ]);
    return query;
  }

  Expression<bool>? _inBatch(Students s, String? batchId) {
    if (batchId == null) return null;
    final members = _db.selectOnly(_db.batchMembers)
      ..addColumns([_db.batchMembers.studentId])
      ..where(
        _db.batchMembers.batchId.equals(batchId) &
            _db.batchMembers.leftOn.isNull(),
      );
    return s.id.isInQuery(members);
  }

  Expression<bool>? _matchesQuery(Students s, String raw) {
    final q = searchKey(raw);
    if (q.isEmpty) return null;
    final matches = <Expression<bool>>[
      _Contains(s.name, q),
      _Contains(s.guardianName, q),
      _Contains(s.school, q),
    ];
    // Phones are stored as 01XXXXXXXXX; let "1712", "০১৭১২" or "+8801712" find them.
    final digits = toWesternDigits(raw).replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 3) {
      final local = digits.startsWith('880') ? digits.substring(3) : digits;
      matches
        ..add(_Contains(s.guardianPhone, local))
        ..add(_Contains(s.studentPhone, local));
    }
    return matches.reduce((a, b) => a | b);
  }

  void _check(StudentDraft draft) {
    final errors = draft.validate();
    if (errors.isNotEmpty) throw StudentValidationException(errors);
  }

  String? _text(String? value) {
    if (value == null) return null;
    final text = normalizeText(value);
    return text.isEmpty ? null : text;
  }

  String? _phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return parseBdPhone(value)!.local;
  }

  String? _subjects(List<String> subjects) {
    final cleaned = [
      for (final s in subjects)
        if (normalizeText(s).isNotEmpty) normalizeText(s),
    ];
    return cleaned.isEmpty ? null : jsonEncode(cleaned);
  }
}

/// `column LIKE '%needle%' ESCAPE '\'` with the needle's own `%`, `_` and `\`
/// escaped, so a search for "100%" matches literally. Drift's built-in
/// `contains` does not escape wildcards.
class _Contains extends Expression<bool> {
  _Contains(this._column, String needle)
    : _pattern =
          '%${needle.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}')}%';

  final Expression<String> _column;
  final String _pattern;

  @override
  Precedence get precedence => Precedence.comparisonEq;

  @override
  void writeInto(GenerationContext context) {
    _column.writeInto(context);
    context.buffer.write(' LIKE ');
    Variable<String>(_pattern).writeInto(context);
    context.buffer.write(r" ESCAPE '\'");
  }
}
