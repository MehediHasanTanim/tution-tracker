import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/features/fees/domain/due_generation.dart';
import 'package:tution_tracker/features/fees/domain/proration_rule.dart';

YearMonth ym(int y, int m) => YearMonth(y, m);

List<FeeRecordDraft> gen({
  LocalDate joinedOn = const LocalDate(2026, 1, 1),
  int dueDay = 10,
  int fee = 1500,
  YearMonth? upTo,
  ProrationRule rule = ProrationRule.fullMonth,
  List<FeeChangeEntry> changes = const [],
  List<PauseEntry> pauses = const [],
  List<BatchFeeAdjustment> adjustments = const [],
  Set<YearMonth> existing = const {},
}) => generateDues(
  studentId: 's1',
  joinedOn: joinedOn,
  feeDueDay: dueDay,
  baseFee: fee,
  upTo: upTo ?? ym(2026, 3),
  rule: rule,
  changes: changes,
  pauses: pauses,
  batchAdjustments: adjustments,
  existing: existing,
);

List<int> amounts(List<FeeRecordDraft> d) => [for (final x in d) x.amountDue];
List<YearMonth> months(List<FeeRecordDraft> d) => [for (final x in d) x.month];

void main() {
  group('basic generation', () {
    test('one due per month from the joining month through upTo', () {
      final d = gen();
      expect(months(d), [ym(2026, 1), ym(2026, 2), ym(2026, 3)]);
      expect(amounts(d), [1500, 1500, 1500]);
      expect(d.every((x) => x.studentId == 's1'), isTrue);
    });

    test('nothing before the joining month or after upTo', () {
      expect(
        gen(joinedOn: const LocalDate(2026, 4, 1), upTo: ym(2026, 3)),
        isEmpty,
      );
      expect(
        months(gen(joinedOn: const LocalDate(2026, 3, 5), upTo: ym(2026, 3))),
        [ym(2026, 3)],
      );
    });

    test('crosses a year boundary', () {
      final d = gen(joinedOn: const LocalDate(2025, 11, 1), upTo: ym(2026, 2));
      expect(months(d), [ym(2025, 11), ym(2025, 12), ym(2026, 1), ym(2026, 2)]);
    });

    test('a zero-fee student gets no dues', () {
      expect(gen(fee: 0), isEmpty);
    });
  });

  group('idempotence', () {
    test('existing months are skipped; a second run yields nothing', () {
      final first = gen();
      final created = {for (final d in first) d.month};
      expect(gen(existing: created), isEmpty);
    });

    test('only the missing months are created', () {
      final d = gen(existing: {ym(2026, 2)});
      expect(months(d), [ym(2026, 1), ym(2026, 3)]);
    });
  });

  group('proration of the joining month', () {
    // January has 31 days, February 2026 has 28.
    test('fullMonth charges the whole fee whatever the day', () {
      for (final day in [1, 15, 31]) {
        final d = gen(
          joinedOn: LocalDate(2026, 1, day),
          upTo: ym(2026, 1),
          rule: ProrationRule.fullMonth,
        );
        expect(amounts(d), [1500], reason: 'day $day');
      }
    });

    test('byDays: joining on the 1st is the whole month', () {
      final d = gen(
        joinedOn: const LocalDate(2026, 1, 1),
        upTo: ym(2026, 1),
        rule: ProrationRule.byDays,
      );
      expect(amounts(d), [1500]);
    });

    test('byDays: the 15th keeps 17 of 31 days (joining day counts)', () {
      // 1500 * 17 / 31 = 822.58 -> 823
      final d = gen(
        joinedOn: const LocalDate(2026, 1, 15),
        upTo: ym(2026, 1),
        rule: ProrationRule.byDays,
      );
      expect(amounts(d), [823]);
    });

    test('byDays: the 31st keeps 1 of 31 days', () {
      // 1500 / 31 = 48.39 -> 48
      final d = gen(
        joinedOn: const LocalDate(2026, 1, 31),
        upTo: ym(2026, 1),
        rule: ProrationRule.byDays,
      );
      expect(amounts(d), [48]);
    });

    test('byDays uses the real month length', () {
      // Feb 2026: 28 days, joining on the 15th keeps 14: 1500 * 14 / 28 = 750.
      final d = gen(
        joinedOn: const LocalDate(2026, 2, 15),
        upTo: ym(2026, 2),
        rule: ProrationRule.byDays,
      );
      expect(amounts(d), [750]);
      // Leap February 2028: 29 days, the 15th keeps 15: 1500 * 15 / 29 = 775.86.
      final leap = gen(
        joinedOn: const LocalDate(2028, 2, 15),
        upTo: ym(2028, 2),
        rule: ProrationRule.byDays,
      );
      expect(amounts(leap), [776]);
    });

    test('byDays rounds halves up', () {
      // fee 1001, 28-day month, joining the 15th: 1001 * 14 / 28 = 500.5 -> 501
      final d = gen(
        joinedOn: const LocalDate(2026, 2, 15),
        fee: 1001,
        upTo: ym(2026, 2),
        rule: ProrationRule.byDays,
      );
      expect(amounts(d), [501]);
    });

    test('byDays only touches the joining month', () {
      final d = gen(
        joinedOn: const LocalDate(2026, 1, 15),
        upTo: ym(2026, 3),
        rule: ProrationRule.byDays,
      );
      expect(amounts(d), [823, 1500, 1500]);
    });

    test('nextMonth charges nothing for the joining month', () {
      for (final day in [1, 15, 31]) {
        final d = gen(
          joinedOn: LocalDate(2026, 1, day),
          upTo: ym(2026, 3),
          rule: ProrationRule.nextMonth,
        );
        expect(months(d), [ym(2026, 2), ym(2026, 3)], reason: 'day $day');
        expect(amounts(d), [1500, 1500]);
      }
    });

    test('nextMonth with only the joining month so far gives nothing', () {
      expect(
        gen(
          joinedOn: const LocalDate(2026, 3, 10),
          upTo: ym(2026, 3),
          rule: ProrationRule.nextMonth,
        ),
        isEmpty,
      );
    });
  });

  group('fee changes', () {
    test('a change mid-year affects only months from its effective month', () {
      final d = gen(
        joinedOn: const LocalDate(2026, 1, 1),
        upTo: ym(2026, 6),
        changes: [
          FeeChangeEntry(ym(2026, 1), 1500),
          FeeChangeEntry(ym(2026, 4), 2000),
        ],
      );
      expect(amounts(d), [1500, 1500, 1500, 2000, 2000, 2000]);
    });

    test(
      'the latest change not after the month wins, whatever the list order',
      () {
        final changes = [
          FeeChangeEntry(ym(2026, 5), 3000),
          FeeChangeEntry(ym(2026, 1), 1500),
          FeeChangeEntry(ym(2026, 3), 2000),
        ];
        expect(feeFor(ym(2026, 2), changes, 999), 1500);
        expect(feeFor(ym(2026, 3), changes, 999), 2000);
        expect(feeFor(ym(2026, 4), changes, 999), 2000);
        expect(feeFor(ym(2026, 12), changes, 999), 3000);
      },
    );

    test('with no changes the base fee is used', () {
      expect(feeFor(ym(2026, 2), const [], 1234), 1234);
      expect(
        feeFor(ym(2025, 12), [FeeChangeEntry(ym(2026, 1), 1500)], 1234),
        1234,
      );
    });

    test('a change effective in the past leaves existing dues untouched', () {
      // Jan and Feb dues already exist at 1500; the fee is raised from Feb.
      final d = gen(
        upTo: ym(2026, 4),
        existing: {ym(2026, 1), ym(2026, 2)},
        changes: [
          FeeChangeEntry(ym(2026, 1), 1500),
          FeeChangeEntry(ym(2026, 2), 2000),
        ],
      );
      expect(months(d), [ym(2026, 3), ym(2026, 4)]);
      expect(amounts(d), [2000, 2000]);
    });

    test('a past change still applies to months that had no due yet', () {
      final d = gen(
        upTo: ym(2026, 3),
        existing: {ym(2026, 1)},
        changes: [
          FeeChangeEntry(ym(2026, 1), 1500),
          FeeChangeEntry(ym(2026, 2), 1800),
        ],
      );
      expect(amounts(d), [1800, 1800]);
    });

    test('a fee decrease works the same way', () {
      final d = gen(
        upTo: ym(2026, 3),
        changes: [
          FeeChangeEntry(ym(2026, 1), 1500),
          FeeChangeEntry(ym(2026, 3), 1000),
        ],
      );
      expect(amounts(d), [1500, 1500, 1000]);
    });

    test('proration uses the fee in force for the joining month', () {
      final d = gen(
        joinedOn: const LocalDate(2026, 2, 15),
        upTo: ym(2026, 2),
        rule: ProrationRule.byDays,
        changes: [FeeChangeEntry(ym(2026, 2), 2000)],
      );
      expect(amounts(d), [1000]); // 2000 * 14 / 28
    });
  });

  group('pause and resume', () {
    test('no dues during a closed pause, dues resume after it', () {
      final d = gen(
        upTo: ym(2026, 6),
        pauses: [PauseEntry(ym(2026, 3), ym(2026, 4))],
      );
      expect(months(d), [ym(2026, 1), ym(2026, 2), ym(2026, 5), ym(2026, 6)]);
    });

    test('an open-ended pause stops all later dues', () {
      final d = gen(upTo: ym(2026, 6), pauses: [PauseEntry(ym(2026, 3))]);
      expect(months(d), [ym(2026, 1), ym(2026, 2)]);
    });

    test('a pause includes both end months', () {
      final p = PauseEntry(ym(2026, 3), ym(2026, 3));
      expect(p.covers(ym(2026, 2)), isFalse);
      expect(p.covers(ym(2026, 3)), isTrue);
      expect(p.covers(ym(2026, 4)), isFalse);
    });

    test('several pauses combine', () {
      final d = gen(
        upTo: ym(2026, 6),
        pauses: [
          PauseEntry(ym(2026, 2), ym(2026, 2)),
          PauseEntry(ym(2026, 5), ym(2026, 5)),
        ],
      );
      expect(months(d), [ym(2026, 1), ym(2026, 3), ym(2026, 4), ym(2026, 6)]);
    });

    test('resume: ending the pause makes the missing months appear', () {
      final paused = gen(upTo: ym(2026, 4), pauses: [PauseEntry(ym(2026, 3))]);
      expect(months(paused), [ym(2026, 1), ym(2026, 2)]);
      final resumed = gen(
        upTo: ym(2026, 4),
        existing: {ym(2026, 1), ym(2026, 2)},
        pauses: [PauseEntry(ym(2026, 3), ym(2026, 3))],
      );
      expect(months(resumed), [ym(2026, 4)]);
    });
  });

  group('due dates', () {
    test('due day 31 is clamped in February (28 and 29) and 30-day months', () {
      final d = gen(
        joinedOn: const LocalDate(2026, 1, 1),
        dueDay: 31,
        upTo: ym(2026, 4),
      );
      expect(
        [for (final x in d) x.dueDate],
        [
          const LocalDate(2026, 1, 31),
          const LocalDate(2026, 2, 28),
          const LocalDate(2026, 3, 31),
          const LocalDate(2026, 4, 30),
        ],
      );
      expect(dueDateFor(ym(2028, 2), 31), const LocalDate(2028, 2, 29));
      expect(dueDateFor(ym(2026, 2), 29), const LocalDate(2026, 2, 28));
    });

    test('a normal due day is used as is', () {
      expect(dueDateFor(ym(2026, 6), 10), const LocalDate(2026, 6, 10));
    });

    test('joining after the due day does not make the first due overdue', () {
      final d = gen(
        joinedOn: const LocalDate(2026, 1, 20),
        dueDay: 10,
        upTo: ym(2026, 2),
      );
      expect(d.first.dueDate, const LocalDate(2026, 1, 20)); // not Jan 10
      expect(d.last.dueDate, const LocalDate(2026, 2, 10));
    });

    test('joining before the due day keeps the due day', () {
      final d = gen(
        joinedOn: const LocalDate(2026, 1, 5),
        dueDay: 10,
        upTo: ym(2026, 1),
      );
      expect(d.single.dueDate, const LocalDate(2026, 1, 10));
    });
  });

  group('batch fee overrides', () {
    test('an override lowers the due by default minus override', () {
      // Batch default 1500, this student pays 1000: due drops by 500.
      final d = gen(
        upTo: ym(2026, 2),
        adjustments: [BatchFeeAdjustment(reduction: 500, from: ym(2026, 1))],
      );
      expect(amounts(d), [1000, 1000]);
    });

    test('only months the membership covers are adjusted', () {
      final d = gen(
        upTo: ym(2026, 4),
        adjustments: [
          BatchFeeAdjustment(
            reduction: 500,
            from: ym(2026, 2),
            to: ym(2026, 3),
          ),
        ],
      );
      expect(amounts(d), [1500, 1000, 1000, 1500]);
    });

    test('several overrides add up and the due never goes below zero', () {
      final d = gen(
        fee: 1000,
        upTo: ym(2026, 1),
        adjustments: [
          BatchFeeAdjustment(reduction: 700, from: ym(2026, 1)),
          BatchFeeAdjustment(reduction: 700, from: ym(2026, 1)),
        ],
      );
      expect(
        d,
        isEmpty,
      ); // 1000 - 1400 clamps to 0, and a zero due is not created
    });

    test('an override above the batch default raises the due', () {
      final d = gen(
        upTo: ym(2026, 1),
        adjustments: [BatchFeeAdjustment(reduction: -300, from: ym(2026, 1))],
      );
      expect(amounts(d), [1800]);
    });

    test('is prorated together with the fee in the joining month', () {
      final d = gen(
        joinedOn: const LocalDate(2026, 2, 15),
        upTo: ym(2026, 2),
        rule: ProrationRule.byDays,
        adjustments: [BatchFeeAdjustment(reduction: 500, from: ym(2026, 2))],
      );
      expect(amounts(d), [500]); // (1500 - 500) * 14 / 28
    });
  });

  test('prorate on its own', () {
    const join = LocalDate(2026, 1, 15);
    expect(prorate(1500, join, ProrationRule.fullMonth), 1500);
    expect(prorate(1500, join, ProrationRule.nextMonth), isNull);
    expect(prorate(1500, join, ProrationRule.byDays), 823);
    expect(prorate(0, join, ProrationRule.byDays), 0);
  });
}
