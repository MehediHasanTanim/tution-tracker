import 'package:drift/drift.dart' show TableUpdate;
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/attendance/data/attendance_repository.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_stats.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/features/batches/data/batch_repository.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:tution_tracker/features/fees/data/due_service.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';
import 'package:uuid/uuid.dart';

/// Every row the sample data creates has an id starting with this, which is
/// how it is found and removed again.
const sampleIdPrefix = 'sample_';

/// Example students, batches, payments and attendance for exploring the app
/// (spec ON-5). Removing it deletes exactly those rows and puts back the
/// receipt counter, so nothing is left behind.
class SampleDataService {
  SampleDataService(this._db, this._settings, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final SettingsStore _settings;
  final DateTime Function() _now;

  static String _newId() => '$sampleIdPrefix${const Uuid().v4()}';

  Future<bool> isLoaded() async {
    final row = await _db
        .customSelect(
          "SELECT EXISTS(SELECT 1 FROM students WHERE id LIKE 'sample\\_%' "
          "ESCAPE '\\') AS e",
        )
        .getSingle();
    return row.read<int>('e') == 1;
  }

  /// Adds the sample data. Does nothing if it is already there.
  Future<void> load(AppLanguage language) async {
    if (await isLoaded()) return;
    final bn = language == AppLanguage.bn;
    final today = LocalDate.fromDateTime(_now());
    final monthStart = LocalDate(today.year, today.month, 1);
    final joined = LocalDate(
      monthStart.addDays(-70).year,
      monthStart.addDays(-70).month,
      1,
    );

    // What the receipt counter was, so removal can restore it.
    final priorReceipt = await _settings.get(SettingKeys.nextReceiptNo);
    await _settings.set(SettingKeys.samplePriorReceiptNo, priorReceipt);

    final payments = PaymentRepository(
      _db,
      _settings,
      now: _now,
      newId: _newId,
    );
    final dues = DueService(_db, _settings, payments, now: _now, newId: _newId);
    final students = StudentRepository(
      _db,
      now: _now,
      newId: _newId,
      onStudentChanged: (id) async {
        await dues.generateForStudent(id);
      },
    );
    final batches = BatchRepository(_db, now: _now, newId: _newId);
    final attendance = AttendanceRepository(_db, newId: _newId);

    final math = await batches.create(
      BatchDraft(
        name: bn ? 'নবম শ্রেণি · গণিত' : 'Class 9 · Math',
        scheduleDays: const [6, 1, 3],
        startTime: const ClockTime(17, 0),
        durationMin: 60,
        defaultFee: 1500,
      ),
    );
    final science = await batches.create(
      BatchDraft(
        name: bn ? 'দশম শ্রেণি · বিজ্ঞান' : 'Class 10 · Science',
        scheduleDays: const [7, 2, 4],
        startTime: const ClockTime(18, 30),
        durationMin: 60,
        defaultFee: 2000,
      ),
    );

    Future<Student> student(String name, int fee, String phone) =>
        students.create(
          StudentDraft(
            name: name,
            monthlyFee: fee,
            joinedOn: joined,
            guardianPhone: phone,
          ),
        );

    final names = bn
        ? [
            'রাহিম উদ্দিন',
            'ফাতেমা আক্তার',
            'করিম হোসেন',
            'সুমাইয়া ইসলাম',
            'তানভীর আহমেদ',
            'নুসরাত জাহান',
          ]
        : [
            'Rahim Uddin',
            'Fatema Akter',
            'Karim Hossain',
            'Sumaiya Islam',
            'Tanvir Ahmed',
            'Nusrat Jahan',
          ];
    final s = [
      await student(names[0], 1500, '01711000001'),
      await student(names[1], 1500, '01711000002'),
      await student(names[2], 1500, '01711000003'),
      await student(names[3], 2000, '01711000004'),
      await student(names[4], 2000, '01711000005'),
      await student(names[5], 2000, '01711000006'),
    ];
    await batches.addMembers(math.id, [s[0].id, s[1].id, s[2].id], joined);
    await batches.addMembers(science.id, [s[3].id, s[4].id, s[5].id], joined);
    await dues.generateForAll();

    // Rahim is fully paid; Fatema has paid part; Sumaiya paid ahead.
    Future<void> pay(Student who, int amount, LocalDate on) async {
      await payments.record(
        PaymentInput(studentId: who.id, amount: amount, receivedOn: on),
      );
    }

    await pay(s[0], 1500 * 4, joined.addDays(12));
    await pay(s[1], 2000, joined.addDays(40));
    await pay(s[3], 2000 * 5, joined.addDays(60));

    // Two weeks of attendance on the days each batch meets.
    for (var back = 14; back >= 1; back--) {
      final day = today.addDays(-back);
      for (final entry in [
        (math, s.sublist(0, 3), const [6, 1, 3], const ClockTime(17, 0)),
        (science, s.sublist(3), const [7, 2, 4], const ClockTime(18, 30)),
      ]) {
        final batch = entry.$1;
        if (!entry.$3.contains(day.isoWeekday)) continue;
        final marks = <String, AttendanceStatus>{
          for (final (i, st) in entry.$2.indexed)
            st.id: (day.day + i) % 5 == 0
                ? AttendanceStatus.absent
                : (day.day + i) % 7 == 0
                ? AttendanceStatus.late
                : AttendanceStatus.present,
        };
        await attendance.saveAttendance(
          owner: ClassOwner.batch(batch.id, batch.name),
          date: day,
          startTime: entry.$4,
          marks: marks,
        );
      }
    }
  }

  /// Removes everything the sample data added.
  Future<void> remove() async {
    await _db.transaction(() async {
      const like = r"LIKE 'sample\_%' ESCAPE '\'";
      Future<void> run(String sql) => _db.customStatement(sql);
      // Children first. Rows made by the app for sample students (dues,
      // allocations) carry sample ids too, because every repository was given
      // the prefixed id source; the student/batch links catch the rest.
      const students = '(SELECT id FROM students WHERE id $like)';
      const batches = '(SELECT id FROM batches WHERE id $like)';
      await run(
        'DELETE FROM attendance WHERE student_id IN $students '
        'OR session_id IN (SELECT id FROM class_sessions WHERE batch_id IN '
        '$batches OR student_id IN $students)',
      );
      await run(
        'DELETE FROM class_sessions WHERE batch_id IN $batches '
        'OR student_id IN $students',
      );
      await run(
        'DELETE FROM payment_allocations WHERE student_id IN $students '
        'OR payment_id IN (SELECT id FROM payments WHERE student_id IN '
        '$students)',
      );
      await run('DELETE FROM payments WHERE student_id IN $students');
      await run('DELETE FROM fee_records WHERE student_id IN $students');
      await run('DELETE FROM fee_changes WHERE student_id IN $students');
      await run('DELETE FROM pauses WHERE student_id IN $students');
      await run(
        'DELETE FROM batch_members WHERE student_id IN $students '
        'OR batch_id IN $batches',
      );
      await run(
        'DELETE FROM audit_log WHERE entity_id $like OR id $like '
        'OR entity_id IN $students',
      );
      await run('DELETE FROM students WHERE id $like');
      await run('DELETE FROM batches WHERE id $like');
    });

    // The deletes above were raw SQL, which Drift cannot see: tell everything
    // that is watching these tables (lists, the sample banner) to refresh.
    _db.notifyUpdates({
      for (final t in _db.allTables) TableUpdate(t.actualTableName),
    });

    // Guardian reminders marked for sample students.
    final log = await _settings.get(SettingKeys.feeRemindersSent);
    if (log.contains(sampleIdPrefix)) {
      await _settings.reset(SettingKeys.feeRemindersSent);
    }
    // Receipt numbers: if no real payment exists, start again from where the
    // counter was before the sample data used some.
    final remaining = await _db
        .customSelect('SELECT COUNT(*) AS c FROM payments')
        .getSingle();
    if (remaining.read<int>('c') == 0) {
      final prior = await _settings.get(SettingKeys.samplePriorReceiptNo);
      // The default needs no stored row, so none is left behind.
      if (prior == SettingKeys.nextReceiptNo.defaultValue) {
        await _settings.reset(SettingKeys.nextReceiptNo);
      } else {
        await _settings.set(SettingKeys.nextReceiptNo, prior);
      }
    }
    await _settings.reset(SettingKeys.samplePriorReceiptNo);
  }
}
