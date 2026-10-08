import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/features/attendance/data/attendance_repository.dart';
import 'package:tution_tracker/features/reports/data/report_repository.dart';

import '../support/fee_ui.dart';
import '../support/stress_data.dart';
import '../support/test_app.dart';

void main() {
  test('cold start: opening a 500-student database and the Home queries', () async {
    final dir = Directory.systemTemp.createTempSync('tk_perf_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File(p.join(dir.path, 'data.sqlite'));
    final seed = await openDatabaseFile(file);
    await seedStress(seed);
    await seed.close();

    final watch = Stopwatch()..start();
    final db = await openDatabaseFile(file);
    await db.customSelect('SELECT 1').get();
    final opened = watch.elapsed;
    final today = LocalDate.fromDateTime(DateTime(2026, 10, 7));
    final report = ReportRepository(db, AttendanceRepository(db));
    await report.monthSummary(YearMonth.from(today));
    await report.owing(today);
    await report.upcomingDues(today);
    await AttendanceRepository(db).watchBatchRules().first;
    final ready = watch.elapsed;
    await db.close();

    // ignore: avoid_print
    print(
      'PERF cold open: ${opened.inMilliseconds} ms, Home data: ${ready.inMilliseconds} ms',
    );
    // The whole budget is 2 s on a 2 GB phone, for everything including the
    // first frame; the database part must be a small slice of it.
    expect(opened.inMilliseconds, lessThan(200));
    expect(ready.inMilliseconds, lessThan(400));
  });

  group('lists with 500 students only build what is on screen', () {
    feeUiTest('Students tab', (tester, h) async {
      await real(tester, () => seedStress(h.db));
      await pumpHarnessApp(tester, h);
      final watch = Stopwatch()..start();
      await goTab(tester, 'শিক্ষার্থী');
      for (var i = 0; i < 40 && find.byType(ListTile).evaluate().isEmpty; i++) {
        await settle(tester);
      }
      // ignore: avoid_print
      print('PERF students tab first paint: ${watch.elapsedMilliseconds} ms');
      final built = find.byType(ListTile).evaluate().length;
      expect(built, greaterThan(2));
      expect(built, lessThan(40), reason: 'built $built of 500 rows');
    });

    feeUiTest('Fees tab', (tester, h) async {
      await real(tester, () => seedStress(h.db));
      await pumpHarnessApp(tester, h);
      await goTab(tester, 'ফি');
      for (var i = 0; i < 40 && find.byType(ListTile).evaluate().isEmpty; i++) {
        await settle(tester);
      }
      final built = find.byType(ListTile).evaluate().length;
      expect(built, greaterThan(2));
      expect(built, lessThan(40), reason: 'built $built rows');
    });
  });
}
