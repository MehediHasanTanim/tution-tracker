import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/attendance/data/attendance_repository.dart';
import 'package:tution_tracker/features/fees/data/consistency_checker.dart';
import 'package:tution_tracker/features/fees/data/due_service.dart';
import 'package:tution_tracker/features/fees/data/fee_repository.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/reports/data/report_repository.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_filter.dart';

import '../support/stress_data.dart';

// Timings on the dev machine are far better than on a 2 GB phone, so the
// limits below (milliseconds, on the dev machine) are a fraction of the real
// budget (screens and reports under 1 s, cold start under 2 s): a regression
// that crosses them would be felt on a phone.

Future<Duration> _time(Future<void> Function() work) async {
  final watch = Stopwatch()..start();
  await work();
  return watch.elapsed;
}

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 7, 10);
  final today = LocalDate.fromDateTime(now);

  setUpAll(() async {
    db = openInMemoryDatabase();
    await seedStress(db);
  });

  tearDownAll(() => db.close());

  Future<int> count(String sql) async =>
      (await db.customSelect(sql).getSingle()).data.values.first! as int;

  test('the dataset is the size the spec asks for', () async {
    expect(await count('SELECT COUNT(*) FROM students'), 500);
    expect(await count('SELECT COUNT(*) FROM payments'), 6000);
    expect(await count('SELECT COUNT(*) FROM attendance'), 20000);
    expect(await count('SELECT COUNT(*) FROM fee_records'), 7000);
  });

  test('the dataset is consistent', () async {
    final issues = await ConsistencyChecker(db, SettingsStore(db)).run();
    expect(issues, isEmpty);
  });

  group('screens load fast enough for a 2 GB phone', () {
    Future<void> within(
      String name,
      Future<void> Function() work, {
      int ms = 1000,
    }) async {
      final took = await _time(work);
      // ignore: avoid_print
      print('PERF $name: ${took.inMilliseconds} ms');
      expect(took.inMilliseconds, lessThan(ms), reason: '$name took $took');
    }

    test('due list (Fees tab)', () async {
      final payments = PaymentRepository(db, SettingsStore(db), now: () => now);
      final dues = DueService(db, SettingsStore(db), payments, now: () => now);
      final fees = FeeRepository(db, payments, dues, now: () => now);
      late List<DueListEntry> list;
      await within(
        'due list',
        () async => list = await fees.watchDueList().first,
        ms: 150,
      );
      expect(list, isNotEmpty);
    });

    test('student list and search', () async {
      final repo = StudentRepository(db, now: () => now);
      await within('student list', () async {
        expect((await repo.watch().first).length, 500);
      }, ms: 150);
      await within('student search', () async {
        expect(
          await repo.watch(const StudentFilter(query: 'Number 4')).first,
          isNotEmpty,
        );
      }, ms: 150);
    });

    test('home dashboard numbers', () async {
      final report = ReportRepository(db, AttendanceRepository(db));
      await within(
        'month summary',
        () => report.monthSummary(YearMonth.from(today)),
        ms: 100,
      );
      await within('owing', () => report.owing(today), ms: 100);
      await within('upcoming dues', () => report.upcomingDues(today), ms: 100);
    });

    test('monthly report and income chart', () async {
      final report = ReportRepository(db, AttendanceRepository(db));
      await within(
        'batch breakdown',
        () => report.batchBreakdown(const YearMonth(2026, 3)),
        ms: 300,
      );
      await within(
        '12-month income',
        () => report.income(YearMonth.from(today)),
        ms: 150,
      );
    });

    test('a student attendance month and calendar', () async {
      final repo = AttendanceRepository(db);
      await within(
        'student month',
        () => repo.watchStudentMonth('s7', const YearMonth(2026, 3)).first,
        ms: 100,
      );
      await within(
        'student calendar',
        () => repo.watchStudentCalendar('s7', const YearMonth(2026, 3)).first,
        ms: 100,
      );
    });

    test('today\'s classes', () async {
      final repo = AttendanceRepository(db);
      await within('rules and sessions', () async {
        await repo.watchBatchRules().first;
        await repo.watchSessionsOn(const LocalDate(2026, 3, 2)).first;
      }, ms: 100);
    });

    // This runs at every start and resume: it must cost next to nothing.
    test('generating dues at app start finds nothing to do, quickly', () async {
      final payments = PaymentRepository(db, SettingsStore(db), now: () => now);
      final dues = DueService(db, SettingsStore(db), payments, now: () => now);
      await within('generate dues (steady state)', () async {
        expect(await dues.generateForAll(), 0);
      }, ms: 100);
    });

    test('the consistency check', () async {
      await within('consistency check', () async {
        await ConsistencyChecker(db, SettingsStore(db)).run();
      }, ms: 1500);
    });
  });

  group('queries use indexes', () {
    /// The plan lines SQLite reports for [sql].
    Future<List<String>> plan(String sql) async => [
      for (final r in await db.customSelect('EXPLAIN QUERY PLAN $sql').get())
        r.read<String>('detail'),
    ];

    /// A full scan of [table] in [sql] is a performance bug.
    Future<void> noScan(String sql, String table) async {
      final lines = await plan(sql);
      expect(
        lines.where((l) => l.startsWith('SCAN $table') && !l.contains('INDEX')),
        isEmpty,
        reason: 'full scan of $table in: $sql\n${lines.join('\n')}',
      );
    }

    test(
      'a student\'s dues',
      () => noScan(
        "SELECT * FROM fee_balances WHERE student_id = 's7'",
        'fee_records',
      ),
    );
    test(
      'a student\'s payments',
      () =>
          noScan("SELECT * FROM payments WHERE student_id = 's7'", 'payments'),
    );
    test(
      'a day\'s sessions',
      () => noScan(
        "SELECT * FROM class_sessions WHERE date = '2026-03-02'",
        'class_sessions',
      ),
    );
    test(
      'a student\'s attendance',
      () => noScan(
        "SELECT * FROM attendance WHERE student_id = 's7'",
        'attendance',
      ),
    );
    test(
      'payments in a date range',
      () => noScan(
        "SELECT SUM(amount) FROM payments WHERE received_on BETWEEN '2026-03-01' AND '2026-03-31' AND deleted_at IS NULL",
        'payments',
      ),
    );
    test(
      'a session\'s marks',
      () => noScan(
        "SELECT * FROM attendance WHERE session_id = 'cs3_4'",
        'attendance',
      ),
    );
  });
}
