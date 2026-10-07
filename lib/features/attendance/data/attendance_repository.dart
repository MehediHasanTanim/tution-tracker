import 'dart:convert';

import 'package:drift/drift.dart' hide Batch;
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/text_normalizer.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_stats.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:uuid/uuid.dart';

/// A student on an attendance sheet, with the mark saved so far (null if none).
class RosterEntry {
  const RosterEntry(this.student, this.status);

  final Student student;
  final AttendanceStatus? status;
}

/// Classes, the students in them, and attendance marks.
///
/// Sessions are not generated ahead of time (design 8.1): a `class_sessions`
/// row is created when attendance is saved, a class is cancelled or marked a
/// holiday, or an extra class is added. A class is identified by its owner
/// (batch or student), date and start time.
class AttendanceRepository {
  AttendanceRepository(this._db, {String Function()? newId})
    : _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final String Function() _newId;

  // ---- schedule ---------------------------------------------------------

  /// Every batch's weekly schedule; archived batches are marked inactive.
  Stream<List<ScheduleRule>> watchBatchRules() {
    return _db
        .select(_db.batches)
        .watch()
        .map(
          (rows) => [
            for (final b in rows)
              ScheduleRule(
                owner: ClassOwner.batch(b.id, b.name),
                days: (jsonDecode(b.scheduleDays) as List<dynamic>).cast<int>(),
                startTime: b.startTime == null
                    ? null
                    : ClockTime.parse(b.startTime!),
                durationMin: b.durationMin,
                active: b.status == 'active',
              ),
          ],
        );
  }

  /// One-to-one classes: students who have class days of their own. Archived
  /// students are marked inactive.
  Stream<List<ScheduleRule>> watchOneToOneRules() {
    final query = _db.select(_db.students)
      ..where((s) => s.classDays.isNotNull());
    return query.watch().map(
      (rows) => [
        for (final s in rows)
          ScheduleRule(
            owner: ClassOwner.student(s.id, s.name),
            days: (jsonDecode(s.classDays!) as List<dynamic>).cast<int>(),
            startTime: s.classTime == null
                ? null
                : ClockTime.parse(s.classTime!),
            active: s.status != 'left',
          ),
      ],
    );
  }

  // ---- sessions ---------------------------------------------------------

  static const _sessionSql = '''
    SELECT s.id, s.batch_id, s.student_id, s.date, s.start_time, s.status,
           s.topic, s.note,
           COALESCE(b.name, st.name) AS owner_name,
           (SELECT COUNT(*) FROM attendance a WHERE a.session_id = s.id)
             AS att_count,
           (SELECT COUNT(*) FROM attendance a
              WHERE a.session_id = s.id AND a.status IN ('present', 'late'))
             AS attended
    FROM class_sessions s
    LEFT JOIN batches b ON b.id = s.batch_id
    LEFT JOIN students st ON st.id = s.student_id
  ''';

  SessionRecord _record(QueryRow r) {
    final batchId = r.read<String?>('batch_id');
    final owner = batchId != null
        ? ClassOwner.batch(batchId, r.read<String>('owner_name'))
        : ClassOwner.student(
            r.read<String>('student_id'),
            r.read<String>('owner_name'),
          );
    final time = r.read<String?>('start_time');
    return SessionRecord(
      id: r.read<String>('id'),
      owner: owner,
      date: LocalDate.parse(r.read<String>('date')),
      startTime: time == null ? null : ClockTime.parse(time),
      status: SessionStatus.values.byName(r.read<String>('status')),
      topic: r.read<String?>('topic'),
      note: r.read<String?>('note'),
      attendanceCount: r.read<int>('att_count'),
      attendedCount: r.read<int>('attended'),
    );
  }

  Set<TableInfo<Table, dynamic>> get _sessionTables => {
    _db.classSessions,
    _db.attendance,
    _db.batches,
    _db.students,
  };

  /// Saved classes on [date], with how many were marked.
  Stream<List<SessionRecord>> watchSessionsOn(LocalDate date) => _db
      .customSelect(
        '$_sessionSql WHERE s.date = ?',
        variables: [Variable.withString(date.toIso())],
        readsFrom: _sessionTables,
      )
      .watch()
      .map((rows) => [for (final r in rows) _record(r)]);

  Future<SessionRecord?> findSession(
    ClassOwner owner,
    LocalDate date,
    ClockTime? startTime,
  ) async {
    final column = owner.kind == OwnerKind.batch
        ? 's.batch_id'
        : 's.student_id';
    final rows = await _db
        .customSelect(
          '$_sessionSql WHERE $column = ? AND s.date = ? '
          "AND COALESCE(s.start_time, '') = ?",
          variables: [
            Variable.withString(owner.id),
            Variable.withString(date.toIso()),
            Variable.withString(startTime?.toKey() ?? ''),
          ],
          readsFrom: _sessionTables,
        )
        .get();
    return rows.isEmpty ? null : _record(rows.first);
  }

  Future<SessionRecord?> sessionById(String id) async {
    final rows = await _db
        .customSelect(
          '$_sessionSql WHERE s.id = ?',
          variables: [Variable.withString(id)],
          readsFrom: _sessionTables,
        )
        .get();
    return rows.isEmpty ? null : _record(rows.first);
  }

  // ---- roster -----------------------------------------------------------

  /// Who is on the sheet for this class: those enrolled on [date], plus
  /// anyone who already has a mark (so a student who left since is not lost
  /// from an old record). Sorted by name.
  ///
  /// Enrolled means joined on or before the date and not yet gone: a student
  /// removed on a date is not enrolled for that day or later (design 8.2).
  /// Archived students are left out of a sheet that has no marks yet.
  Future<List<RosterEntry>> roster(
    ClassOwner owner,
    LocalDate date,
    ClockTime? startTime,
  ) async {
    final session = await findSession(owner, date, startTime);
    final marks = <String, AttendanceStatus>{};
    if (session != null) {
      final rows = await (_db.select(
        _db.attendance,
      )..where((a) => a.sessionId.equals(session.id))).get();
      for (final a in rows) {
        marks[a.studentId] = AttendanceStatus.values.byName(a.status);
      }
    }

    final students = <String, Student>{};
    if (owner.kind == OwnerKind.batch) {
      final rows =
          await (_db.select(_db.batchMembers).join([
                innerJoin(
                  _db.students,
                  _db.students.id.equalsExp(_db.batchMembers.studentId),
                ),
              ])..where(
                _db.batchMembers.batchId.equals(owner.id) &
                    _db.batchMembers.joinedOn.isSmallerOrEqualValue(
                      date.toIso(),
                    ) &
                    (_db.batchMembers.leftOn.isNull() |
                        _db.batchMembers.leftOn.isBiggerThanValue(
                          date.toIso(),
                        )) &
                    _db.students.status.isNotValue('left'),
              ))
              .get();
      for (final r in rows) {
        final s = r.readTable(_db.students);
        students[s.id] = s;
      }
    } else {
      final s = await (_db.select(
        _db.students,
      )..where((t) => t.id.equals(owner.id))).getSingleOrNull();
      if (s != null && (s.status != 'left' || marks.containsKey(s.id))) {
        students[s.id] = s;
      }
    }

    // Keep anyone who already has a mark.
    final missing = marks.keys
        .where((id) => !students.containsKey(id))
        .toList();
    if (missing.isNotEmpty) {
      final rows = await (_db.select(
        _db.students,
      )..where((t) => t.id.isIn(missing))).get();
      for (final s in rows) {
        students[s.id] = s;
      }
    }

    final entries =
        [for (final s in students.values) RosterEntry(s, marks[s.id])]..sort(
          (a, b) => a.student.name.toLowerCase().compareTo(
            b.student.name.toLowerCase(),
          ),
        );
    return entries;
  }

  // ---- writing ----------------------------------------------------------

  /// Saves a class and its marks in one transaction. Saving again for the same
  /// class updates it; it never adds a second class or a second mark for a
  /// student. The class becomes held (clearing any cancellation). Marks for
  /// students not in [marks] are left as they are.
  Future<SessionRecord> saveAttendance({
    required ClassOwner owner,
    required LocalDate date,
    ClockTime? startTime,
    String? topic,
    required Map<String, AttendanceStatus> marks,
  }) {
    return _db.transaction(() async {
      final id = await _upsertSession(
        owner,
        date,
        startTime,
        status: SessionStatus.held,
        topic: _clean(topic),
        note: null,
        setTopic: true,
      );
      for (final entry in marks.entries) {
        await _db
            .into(_db.attendance)
            .insert(
              AttendanceCompanion.insert(
                id: _newId(),
                sessionId: id,
                studentId: entry.key,
                status: entry.value.name,
              ),
              onConflict: DoUpdate(
                (old) => AttendanceCompanion(status: Value(entry.value.name)),
                target: [_db.attendance.sessionId, _db.attendance.studentId],
              ),
            );
      }
      return (await sessionById(id))!;
    });
  }

  /// Marks a class cancelled or a holiday, with an optional [reason] (spec
  /// AT-4). Marks already saved are kept but no longer counted.
  Future<SessionRecord> markOff({
    required ClassOwner owner,
    required LocalDate date,
    ClockTime? startTime,
    required SessionStatus status,
    String? reason,
  }) {
    assert(status != SessionStatus.held, 'use saveAttendance for held classes');
    return _db.transaction(() async {
      final id = await _upsertSession(
        owner,
        date,
        startTime,
        status: status,
        note: _clean(reason),
      );
      return (await sessionById(id))!;
    });
  }

  /// Undoes a cancellation or holiday: the class is held again.
  Future<void> reopen(String sessionId) async {
    await (_db.update(
      _db.classSessions,
    )..where((s) => s.id.equals(sessionId))).write(
      const ClassSessionsCompanion(status: Value('held'), note: Value(null)),
    );
  }

  /// Adds a class that is not on the schedule (spec AT-3). If that class
  /// already exists it is returned unchanged.
  Future<SessionRecord> addExtraClass({
    required ClassOwner owner,
    required LocalDate date,
    ClockTime? startTime,
  }) {
    return _db.transaction(() async {
      final existing = await findSession(owner, date, startTime);
      if (existing != null) return existing;
      final id = await _upsertSession(
        owner,
        date,
        startTime,
        status: SessionStatus.held,
      );
      return (await sessionById(id))!;
    });
  }

  /// Removes a class and, with it, its marks.
  Future<void> deleteSession(String sessionId) async {
    await (_db.delete(
      _db.classSessions,
    )..where((s) => s.id.equals(sessionId))).go();
  }

  Future<String> _upsertSession(
    ClassOwner owner,
    LocalDate date,
    ClockTime? startTime, {
    required SessionStatus status,
    String? topic,
    String? note,
    bool setTopic = false,
  }) async {
    final existing = await findSession(owner, date, startTime);
    if (existing != null) {
      await (_db.update(
        _db.classSessions,
      )..where((s) => s.id.equals(existing.id))).write(
        ClassSessionsCompanion(
          status: Value(status.name),
          note: Value(note),
          topic: setTopic ? Value(topic) : const Value.absent(),
        ),
      );
      return existing.id;
    }
    final id = _newId();
    await _db
        .into(_db.classSessions)
        .insert(
          ClassSessionsCompanion.insert(
            id: id,
            batchId: Value(owner.kind == OwnerKind.batch ? owner.id : null),
            studentId: Value(owner.kind == OwnerKind.student ? owner.id : null),
            date: date.toIso(),
            startTime: Value(startTime?.toKey()),
            status: Value(status.name),
            topic: Value(topic),
            note: Value(note),
          ),
        );
    return id;
  }

  // ---- statistics -------------------------------------------------------

  AttendanceCounts _counts(List<QueryRow> rows) {
    final byStatus = {
      for (final r in rows) r.read<String>('status'): r.read<int>('n'),
    };
    return AttendanceCounts(
      present: byStatus['present'] ?? 0,
      absent: byStatus['absent'] ?? 0,
      late: byStatus['late'] ?? 0,
      excused: byStatus['excused'] ?? 0,
    );
  }

  Set<TableInfo<Table, dynamic>> get _attendanceTables => {
    _db.attendance,
    _db.classSessions,
  };

  /// A student's marks in [month], from held classes only.
  Stream<AttendanceCounts> watchStudentMonth(
    String studentId,
    YearMonth month,
  ) => _db
      .customSelect(
        'SELECT a.status AS status, COUNT(*) AS n FROM attendance a '
        'JOIN class_sessions s ON s.id = a.session_id '
        "WHERE a.student_id = ? AND s.status = 'held' "
        'AND s.date BETWEEN ? AND ? GROUP BY a.status',
        variables: [
          Variable.withString(studentId),
          Variable.withString(month.firstDay.toIso()),
          Variable.withString(month.lastDay.toIso()),
        ],
        readsFrom: _attendanceTables,
      )
      .watch()
      .map(_counts);

  /// All marks of a batch's held classes in [month], summed over students.
  Future<AttendanceCounts> batchMonth(String batchId, YearMonth month) async {
    final rows = await _db
        .customSelect(
          'SELECT a.status AS status, COUNT(*) AS n FROM attendance a '
          'JOIN class_sessions s ON s.id = a.session_id '
          "WHERE s.batch_id = ? AND s.status = 'held' "
          'AND s.date BETWEEN ? AND ? GROUP BY a.status',
          variables: [
            Variable.withString(batchId),
            Variable.withString(month.firstDay.toIso()),
            Variable.withString(month.lastDay.toIso()),
          ],
          readsFrom: _attendanceTables,
        )
        .get();
    return _counts(rows);
  }

  /// Held classes of a batch in [month] that have at least one mark.
  Future<int> batchHeldClasses(String batchId, YearMonth month) async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS n FROM class_sessions s '
          "WHERE s.batch_id = ? AND s.status = 'held' AND s.date BETWEEN ? AND ? "
          'AND EXISTS (SELECT 1 FROM attendance a WHERE a.session_id = s.id)',
          variables: [
            Variable.withString(batchId),
            Variable.withString(month.firstDay.toIso()),
            Variable.withString(month.lastDay.toIso()),
          ],
          readsFrom: _attendanceTables,
        )
        .getSingle();
    return row.read<int>('n');
  }

  /// One entry per day with a mark or a cancelled/holiday class in [month].
  Stream<List<DayMark>> watchStudentCalendar(
    String studentId,
    YearMonth month,
  ) {
    final first = Variable.withString(month.firstDay.toIso());
    final last = Variable.withString(month.lastDay.toIso());
    final student = Variable.withString(studentId);
    return _db
        .customSelect(
          '''
          SELECT s.date AS date, a.status AS status, NULL AS off
          FROM attendance a JOIN class_sessions s ON s.id = a.session_id
          WHERE a.student_id = ? AND s.status = 'held' AND s.date BETWEEN ? AND ?
          UNION ALL
          SELECT s.date AS date, NULL AS status, s.status AS off
          FROM class_sessions s
          WHERE s.status IN ('cancelled', 'holiday') AND s.date BETWEEN ? AND ?
            AND (s.student_id = ?
              OR s.batch_id IN (
                SELECT m.batch_id FROM batch_members m
                WHERE m.student_id = ? AND m.joined_on <= s.date
                  AND (m.left_on IS NULL OR s.date < m.left_on)))
          ''',
          variables: [student, first, last, first, last, student, student],
          readsFrom: {_db.attendance, _db.classSessions, _db.batchMembers},
        )
        .watch()
        .map((rows) {
          final marks = <String, List<AttendanceStatus>>{};
          final off = <String, List<SessionKind>>{};
          for (final r in rows) {
            final date = r.read<String>('date');
            final status = r.read<String?>('status');
            final offStatus = r.read<String?>('off');
            if (status != null) {
              marks
                  .putIfAbsent(date, () => [])
                  .add(AttendanceStatus.values.byName(status));
            }
            if (offStatus != null) {
              off
                  .putIfAbsent(date, () => [])
                  .add(SessionKind.values.byName(offStatus));
            }
          }
          final dates = {...marks.keys, ...off.keys}.toList()..sort();
          return [
            for (final d in dates)
              if (dayStatusFor(
                    marks: marks[d] ?? const [],
                    offDays: off[d] ?? const [],
                  )
                  case final status?)
                DayMark(LocalDate.parse(d), status),
          ];
        });
  }

  String? _clean(String? v) {
    if (v == null) return null;
    final t = normalizeText(v);
    return t.isEmpty ? null : t;
  }
}
