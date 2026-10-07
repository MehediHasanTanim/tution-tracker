import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/features/attendance/data/attendance_repository.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_stats.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:tution_tracker/features/reports/data/report_repository.dart';

import '../../support/fee_harness.dart';

const mar = YearMonth(2026, 3);

void main() {
  late FeeHarness h; // clock: 2026-03-15
  late ReportRepository reports;
  late AttendanceRepository attendance;

  setUp(() {
    h = FeeHarness();
    attendance = AttendanceRepository(h.db);
    reports = ReportRepository(h.db, attendance);
  });
  tearDown(() => h.close());

  /// The month's figures worked out by hand from the ledger rows.
  Future<(int, int, int)> ledgerTotals(List<String> ids, YearMonth m) async {
    var expected = 0, collected = 0, outstanding = 0;
    for (final id in ids) {
      for (final b in await h.ledger(id)) {
        if (b.month == m.toKey() && b.waived == 0) {
          expected += b.payable;
          collected += b.paid;
          outstanding += b.balance;
        }
      }
    }
    return (expected, collected, outstanding);
  }

  group('month summary', () {
    test(
      'expected, collected and outstanding are the sums of the ledger',
      () async {
        final a = await h.addStudent(name: 'A');
        final b = await h.addStudent(name: 'B', fee: 2000);
        final c = await h.addStudent(name: 'C', fee: 1000);
        await h.pay(a.id, 4500); // all of A's Jan..Mar
        await h.pay(b.id, 2500); // Jan 2000 + Feb 500
        await h.pay(c.id, 300); // part of January

        final s = await reports.monthSummary(mar);
        final (e, col, out) = await ledgerTotals([a.id, b.id, c.id], mar);
        expect((s.expected, s.collected, s.outstanding), (e, col, out));
        expect(s.expected, 1500 + 2000 + 1000);
        expect(s.collected, 1500); // only A has paid March
        expect(s.outstanding, 2000 + 1000);
      },
    );

    test('expected - collected always equals outstanding', () async {
      final random = Random(7);
      final ids = <String>[
        for (var i = 0; i < 6; i++)
          (await h.addStudent(name: 'S$i', fee: 800 + 150 * i)).id,
      ];
      for (var step = 0; step < 40; step++) {
        final id = ids[random.nextInt(ids.length)];
        switch (random.nextInt(4)) {
          case 0 || 1:
            await h.pay(id, 100 + random.nextInt(3000));
          case 2:
            final ledger = await h.ledger(id);
            final due = ledger[random.nextInt(ledger.length)];
            await h.fees.setDiscount(
              due.feeRecordId,
              random.nextInt(due.amountDue + 1),
            );
          case 3:
            final ledger = await h.ledger(id);
            final due = ledger[random.nextInt(ledger.length)];
            due.waived == 0
                ? await h.fees.waive(due.feeRecordId, reason: 'x')
                : await h.fees.unwaive(due.feeRecordId);
        }
        for (final m in [
          const YearMonth(2026, 1),
          const YearMonth(2026, 2),
          mar,
        ]) {
          final s = await reports.monthSummary(m);
          expect(
            s.expected - s.collected,
            s.outstanding,
            reason: 'step $step $m',
          );
          final (e, col, out) = await ledgerTotals(ids, m);
          expect((s.expected, s.collected, s.outstanding), (e, col, out));
        }
      }
    });

    test('waived dues are left out', () async {
      final a = await h.addStudent();
      final due = await h.dueFor(a.id, mar);
      await h.fees.waive(due.feeRecordId, reason: 'x');
      final s = await reports.monthSummary(mar);
      expect((s.expected, s.collected, s.outstanding), (0, 0, 0));
    });

    test('a discount lowers the expected amount', () async {
      final a = await h.addStudent();
      final due = await h.dueFor(a.id, mar);
      await h.fees.setDiscount(due.feeRecordId, 400);
      expect((await reports.monthSummary(mar)).expected, 1100);
    });

    test(
      'money paid later for a month still counts as collected for it',
      () async {
        final a = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
        await h.pay(a.id, 1500, on: const LocalDate(2026, 4, 20));
        final s = await reports.monthSummary(mar);
        expect(s.collected, 1500);
        expect(s.cashReceived, 0); // nothing arrived in March itself
      },
    );

    test(
      'collection percent rounds and is null with nothing expected',
      () async {
        expect((await reports.monthSummary(mar)).collectionPercent, isNull);
        final a = await h.addStudent(
          fee: 3000,
          joinedOn: const LocalDate(2026, 3, 1),
        );
        await h.pay(a.id, 1000);
        expect((await reports.monthSummary(mar)).collectionPercent, 33);
        await h.pay(a.id, 1000);
        expect((await reports.monthSummary(mar)).collectionPercent, 67);
      },
    );

    test('an empty month is all zeros', () async {
      final s = await reports.monthSummary(const YearMonth(2025, 1));
      expect(
        (s.expected, s.collected, s.outstanding, s.cashReceived),
        (0, 0, 0, 0),
      );
    });
  });

  group('cash received', () {
    test('counts payments by the date received, within the month', () async {
      final a = await h.addStudent();
      await h.pay(a.id, 100, on: const LocalDate(2026, 2, 28));
      await h.pay(a.id, 200, on: const LocalDate(2026, 3, 1));
      await h.pay(a.id, 300, on: const LocalDate(2026, 3, 31));
      await h.pay(a.id, 400, on: const LocalDate(2026, 4, 1));
      expect((await reports.monthSummary(mar)).cashReceived, 500);
    });

    test('includes advance payments and leaves out deleted ones', () async {
      final a = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      await h.pay(a.id, 5000); // 1500 due + 3500 advance
      final gone = (await h.pay(a.id, 700)).payment;
      await h.payments.delete(gone.id);
      expect((await reports.monthSummary(mar)).cashReceived, 5000);
    });
  });

  group('everyone who owes', () {
    test('the total equals the sum of the due list', () async {
      final a = await h.addStudent(name: 'A');
      await h.addStudent(name: 'B', fee: 2000);
      await h.pay(a.id, 1000);
      final owing = await reports.owing(h.today);
      final list = await h.fees.watchDueList().first;
      expect(
        owing.totalOutstanding,
        list.fold<int>(0, (s, e) => s + e.totalBalance),
      );
      expect(owing.studentsOwing, list.length);
    });

    test('overdue means a due date before today', () async {
      await h.addStudent(name: 'Late'); // Jan 10 and Feb 10 passed
      await h.addStudent(
        name: 'OnTime',
        joinedOn: const LocalDate(2026, 3, 1),
        dueDay: 20,
      );
      final owing = await reports.owing(h.today);
      expect(owing.studentsOwing, 2);
      expect(owing.overdueStudents, 1);
    });

    test('a due that falls today is not yet overdue', () async {
      await h.addStudent(joinedOn: const LocalDate(2026, 3, 1), dueDay: 15);
      expect((await reports.owing(h.today)).overdueStudents, 0);
      expect(
        (await reports.owing(const LocalDate(2026, 3, 16))).overdueStudents,
        1,
      );
    });

    test('nobody owing gives zeros', () async {
      final owing = await reports.owing(h.today);
      expect(
        (owing.totalOutstanding, owing.studentsOwing, owing.overdueStudents),
        (0, 0, 0),
      );
    });
  });

  group('upcoming dues', () {
    test(
      'lists open dues from today through six days ahead, soonest first',
      () async {
        await h.addStudent(
          name: 'Today',
          joinedOn: const LocalDate(2026, 3, 1),
          dueDay: 15,
        );
        await h.addStudent(
          name: 'Day6',
          joinedOn: const LocalDate(2026, 3, 1),
          dueDay: 21,
        );
        await h.addStudent(
          name: 'Day7',
          joinedOn: const LocalDate(2026, 3, 1),
          dueDay: 22,
        );
        await h.addStudent(
          name: 'Soon',
          joinedOn: const LocalDate(2026, 3, 1),
          dueDay: 17,
        );
        await h.addStudent(
          name: 'Past',
          joinedOn: const LocalDate(2026, 3, 1),
          dueDay: 14,
        );
        final upcoming = await reports.upcomingDues(h.today);
        expect(upcoming.map((u) => u.studentName), ['Today', 'Soon', 'Day6']);
        expect(upcoming.first.dueDate, const LocalDate(2026, 3, 15));
      },
    );

    test('paid and waived dues are not upcoming', () async {
      final paid = await h.addStudent(
        name: 'Paid',
        joinedOn: const LocalDate(2026, 3, 1),
        dueDay: 18,
      );
      final waived = await h.addStudent(
        name: 'Waived',
        joinedOn: const LocalDate(2026, 3, 1),
        dueDay: 18,
      );
      await h.addStudent(
        name: 'Owes',
        joinedOn: const LocalDate(2026, 3, 1),
        dueDay: 18,
      );
      await h.pay(paid.id, 1500);
      await h.fees.waive(
        (await h.dueFor(waived.id, mar)).feeRecordId,
        reason: 'x',
      );
      expect((await reports.upcomingDues(h.today)).map((u) => u.studentName), [
        'Owes',
      ]);
    });

    test('shows what is still owed on a part-paid due', () async {
      final a = await h.addStudent(
        joinedOn: const LocalDate(2026, 3, 1),
        dueDay: 18,
      );
      await h.pay(a.id, 500);
      expect((await reports.upcomingDues(h.today)).single.balance, 1000);
    });
  });

  group('per-batch breakdown', () {
    Future<Batch> batch(String name) => h.batches.create(
      BatchDraft(name: name, scheduleDays: const [1], defaultFee: 1500),
    );

    test(
      'splits the month by batch and the rows add up to the month total',
      () async {
        final math = await batch('Math');
        final physics = await batch('Physics');
        final a = await h.addStudent(name: 'A');
        final b = await h.addStudent(name: 'B', fee: 2000);
        final c = await h.addStudent(name: 'C', fee: 1000);
        await h.batches.addMembers(math.id, [
          a.id,
        ], const LocalDate(2026, 1, 1));
        await h.batches.addMembers(physics.id, [
          b.id,
        ], const LocalDate(2026, 1, 1));
        await h.pay(a.id, 4500);
        await h.pay(b.id, 2000);

        final rows = await reports.batchBreakdown(mar);
        expect(rows.map((r) => r.batch?.name), [
          'Math',
          'Physics',
          null,
        ]); // no batch last
        final byName = {for (final r in rows) r.batch?.name: r};
        expect(byName['Math']!.expected, 1500);
        expect(byName['Math']!.outstanding, 0);
        expect(byName['Physics']!.expected, 2000);
        expect(byName['Physics']!.collected, 0);
        expect(byName[null]!.expected, 1000); // C has no batch
        expect(byName[null]!.students, 1);
        expect(c.id, isNotEmpty);

        final month = await reports.monthSummary(mar);
        expect(rows.fold<int>(0, (s, r) => s + r.expected), month.expected);
        expect(rows.fold<int>(0, (s, r) => s + r.collected), month.collected);
        expect(
          rows.fold<int>(0, (s, r) => s + r.outstanding),
          month.outstanding,
        );
      },
    );

    test(
      'a student in two batches is counted once, in the one they joined first',
      () async {
        final math = await batch('Math');
        final physics = await batch('Physics');
        final a = await h.addStudent(name: 'A');
        await h.batches.addMembers(physics.id, [
          a.id,
        ], const LocalDate(2026, 1, 1));
        await h.batches.addMembers(math.id, [
          a.id,
        ], const LocalDate(2026, 2, 1));
        final rows = await reports.batchBreakdown(mar);
        expect(rows, hasLength(1));
        expect(rows.single.batch!.name, 'Physics');
        expect(rows.single.expected, 1500);
      },
    );

    test('members who left before the month, and archived batches, fall to no batch', () async {
      final math = await batch('Math');
      final old = await batch('Old');
      final a = await h.addStudent(name: 'A');
      final b = await h.addStudent(name: 'B');
      await h.batches.addMembers(math.id, [a.id], const LocalDate(2026, 1, 1));
      await h.batches.removeMember(math.id, a.id, const LocalDate(2026, 2, 20));
      await h.batches.addMembers(old.id, [b.id], const LocalDate(2026, 1, 1));
      await h.batches.archive(old.id);
      final rows = await reports.batchBreakdown(mar);
      expect(rows, hasLength(1));
      expect(rows.single.batch, isNull);
      expect(rows.single.students, 2);
    });

    test('includes the batch\'s attendance for the month', () async {
      final math = await batch('Math');
      final a = await h.addStudent(name: 'A');
      final b = await h.addStudent(name: 'B');
      await h.batches.addMembers(math.id, [
        a.id,
        b.id,
      ], const LocalDate(2026, 1, 1));
      final owner = ClassOwner.batch(math.id, math.name);
      await attendance.saveAttendance(
        owner: owner,
        date: const LocalDate(2026, 3, 2),
        marks: {a.id: AttendanceStatus.present, b.id: AttendanceStatus.absent},
      );
      await attendance.saveAttendance(
        owner: owner,
        date: const LocalDate(2026, 3, 9),
        marks: {a.id: AttendanceStatus.present, b.id: AttendanceStatus.late},
      );
      final row = (await reports.batchBreakdown(mar)).single;
      expect(row.heldClasses, 2);
      expect(row.attendance.percent, 75);
    });

    test('an empty month has no rows', () async {
      expect(await reports.batchBreakdown(const YearMonth(2025, 1)), isEmpty);
    });
  });

  group('income', () {
    test(
      'gives 12 months, oldest first, with zeros for quiet months',
      () async {
        final a = await h.addStudent();
        await h.pay(a.id, 1000, on: const LocalDate(2026, 3, 5));
        await h.pay(a.id, 500, on: const LocalDate(2026, 3, 20));
        await h.pay(a.id, 700, on: const LocalDate(2025, 11, 2));

        final income = await reports.income(mar);
        expect(income, hasLength(12));
        expect(income.first.month, const YearMonth(2025, 4));
        expect(income.last.month, mar);
        final byMonth = {for (final i in income) i.month.toKey(): i.amount};
        expect(byMonth['2026-03'], 1500);
        expect(byMonth['2025-11'], 700);
        expect(byMonth['2026-01'], 0);
        expect(income.fold<int>(0, (s, i) => s + i.amount), 2200);
      },
    );

    test('ignores deleted payments and payments outside the window', () async {
      final a = await h.addStudent();
      final gone = (await h.pay(
        a.id,
        900,
        on: const LocalDate(2026, 3, 5),
      )).payment;
      await h.payments.delete(gone.id);
      await h.pay(
        a.id,
        400,
        on: const LocalDate(2025, 3, 31),
      ); // 13 months back
      await h.pay(a.id, 300, on: const LocalDate(2026, 4, 1)); // next month
      final income = await reports.income(mar);
      expect(income.fold<int>(0, (s, i) => s + i.amount), 0);
    });

    test('works across a year boundary and for other lengths', () async {
      final income = await reports.income(const YearMonth(2026, 1), months: 3);
      expect(income.map((i) => i.month.toKey()), [
        '2025-11',
        '2025-12',
        '2026-01',
      ]);
    });

    test('equals the monthly cash received figure', () async {
      final a = await h.addStudent();
      await h.pay(a.id, 1234, on: const LocalDate(2026, 3, 9));
      final income = await reports.income(mar);
      expect(
        income.last.amount,
        (await reports.monthSummary(mar)).cashReceived,
      );
    });
  });

  group('live updates', () {
    test('the month summary changes after a payment', () async {
      final a = await h.addStudent();
      final seen = <int>[];
      final sub = reports
          .watchMonthSummary(mar)
          .listen((s) => seen.add(s.collected));
      await pumpEventQueue();
      await h.pay(a.id, 5000);
      await pumpEventQueue();
      await sub.cancel();
      expect(seen.first, 0);
      expect(seen.last, 1500);
    });

    test('owing and upcoming dues follow payments', () async {
      final a = await h.addStudent(
        joinedOn: const LocalDate(2026, 3, 1),
        dueDay: 18,
      );
      final owing = <int>[];
      final upcoming = <int>[];
      final s1 = reports
          .watchOwing(h.today)
          .listen((o) => owing.add(o.totalOutstanding));
      final s2 = reports
          .watchUpcomingDues(h.today)
          .listen((u) => upcoming.add(u.length));
      await pumpEventQueue();
      await h.pay(a.id, 1500);
      await pumpEventQueue();
      await s1.cancel();
      await s2.cancel();
      expect((owing.first, owing.last), (1500, 0));
      expect((upcoming.first, upcoming.last), (1, 0));
    });

    test('the breakdown and income streams update too', () async {
      final a = await h.addStudent(joinedOn: const LocalDate(2026, 3, 1));
      final collected = <int>[];
      final cash = <int>[];
      final s1 = reports
          .watchBatchBreakdown(mar)
          .listen((r) => collected.add(r.fold(0, (s, e) => s + e.collected)));
      final s2 = reports
          .watchIncome(mar)
          .listen((i) => cash.add(i.last.amount));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await h.pay(a.id, 1500);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await s1.cancel();
      await s2.cancel();
      expect(collected.last, 1500);
      expect(cash.last, 1500);
    });
  });
}
