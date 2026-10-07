import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/features/attendance/domain/expected_sessions.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';

// 2026-03-02 is a Monday; 2026-03-07 a Saturday; 2026-03-08 a Sunday.
const monday = LocalDate(2026, 3, 2);
const tuesday = LocalDate(2026, 3, 3);
const saturday = LocalDate(2026, 3, 7);
const sunday = LocalDate(2026, 3, 8);

const math = ClassOwner.batch('b1', 'Math 9');
const physics = ClassOwner.batch('b2', 'Physics 9');
const rahim = ClassOwner.student('s1', 'Rahim');

ScheduleRule rule(
  ClassOwner owner,
  List<int> days, {
  ClockTime? time,
  bool active = true,
}) => ScheduleRule(owner: owner, days: days, startTime: time, active: active);

SessionRecord record(
  ClassOwner owner,
  LocalDate date, {
  ClockTime? time,
  SessionStatus status = SessionStatus.held,
  int count = 0,
  int attended = 0,
  String id = 'x',
}) => SessionRecord(
  id: id,
  owner: owner,
  date: date,
  startTime: time,
  status: status,
  attendanceCount: count,
  attendedCount: attended,
);

List<String> names(List<ExpectedSession> l) => [
  for (final e in l) e.owner.name,
];

void main() {
  group('weekday mapping', () {
    final rules = [
      rule(math, [1, 3, 5]),
    ]; // Mon, Wed, Fri

    test('a scheduled weekday has the class', () {
      expect(names(expectedSessions(date: monday, rules: rules, records: [])), [
        'Math 9',
      ]);
      expect(
        names(
          expectedSessions(
            date: const LocalDate(2026, 3, 4),
            rules: rules,
            records: [],
          ),
        ),
        ['Math 9'],
      ); // Wednesday
      expect(
        names(
          expectedSessions(
            date: const LocalDate(2026, 3, 6),
            rules: rules,
            records: [],
          ),
        ),
        ['Math 9'],
      ); // Friday
    });

    test('other weekdays have none', () {
      for (final d in [tuesday, saturday, sunday]) {
        expect(expectedSessions(date: d, rules: rules, records: []), isEmpty);
      }
    });

    test('Saturday is ISO 6 and Sunday is 7', () {
      final weekend = [
        rule(math, [6, 7]),
      ];
      expect(
        expectedSessions(date: saturday, rules: weekend, records: []),
        hasLength(1),
      );
      expect(
        expectedSessions(date: sunday, rules: weekend, records: []),
        hasLength(1),
      );
      expect(
        expectedSessions(date: monday, rules: weekend, records: []),
        isEmpty,
      );
    });
  });

  group('several classes in a day', () {
    test('batches and one-to-one classes together, ordered by start time', () {
      final rules = [
        rule(math, [1], time: const ClockTime(17, 0)),
        rule(rahim, [1], time: const ClockTime(9, 30)),
        rule(physics, [1], time: const ClockTime(15, 0)),
      ];
      final result = expectedSessions(date: monday, rules: rules, records: []);
      expect(names(result), ['Rahim', 'Physics 9', 'Math 9']);
      expect(result.every((e) => e.state == ClassState.notTaken), isTrue);
    });

    test('the same batch twice in a day at different times', () {
      final rules = [
        rule(math, [1], time: const ClockTime(9, 0)),
        rule(math, [1], time: const ClockTime(17, 0)),
      ];
      final result = expectedSessions(date: monday, rules: rules, records: []);
      expect(result.map((e) => e.startTime), [
        const ClockTime(9, 0),
        const ClockTime(17, 0),
      ]);
    });

    test('classes without a time come last, then by name', () {
      final rules = [
        rule(physics, [1]),
        rule(math, [1]),
        rule(rahim, [1], time: const ClockTime(8, 0)),
      ];
      expect(names(expectedSessions(date: monday, rules: rules, records: [])), [
        'Rahim',
        'Math 9',
        'Physics 9',
      ]);
    });

    test('carries the duration of the schedule', () {
      final result = expectedSessions(
        date: monday,
        rules: [
          const ScheduleRule(
            owner: math,
            days: [1],
            startTime: ClockTime(17, 0),
            durationMin: 90,
          ),
        ],
        records: [],
      );
      expect(result.single.durationMin, 90);
    });
  });

  group('archived batches and students', () {
    test('are not expected', () {
      final rules = [
        rule(math, [1], active: false),
        rule(physics, [1]),
      ];
      expect(names(expectedSessions(date: monday, rules: rules, records: [])), [
        'Physics 9',
      ]);
    });

    test('but a class already recorded for them is still shown', () {
      final result = expectedSessions(
        date: monday,
        rules: [
          rule(math, [1], active: false),
        ],
        records: [record(math, monday, count: 5, attended: 4)],
      );
      expect(result, hasLength(1));
      expect(result.single.state, ClassState.taken);
      expect(result.single.isExtra, isTrue);
    });
  });

  group('state from saved rows', () {
    final rules = [
      rule(math, [1], time: const ClockTime(17, 0)),
    ];

    ExpectedSession only(List<SessionRecord> records) =>
        expectedSessions(date: monday, rules: rules, records: records).single;

    test('no row means not taken', () {
      final e = only([]);
      expect(e.state, ClassState.notTaken);
      expect(e.record, isNull);
      expect(e.isExtra, isFalse);
    });

    test('a held class with attendance is taken', () {
      final e = only([
        record(
          math,
          monday,
          time: const ClockTime(17, 0),
          count: 12,
          attended: 10,
        ),
      ]);
      expect(e.state, ClassState.taken);
      expect(e.record!.attendedCount, 10);
      expect(e.isExtra, isFalse);
    });

    test('a held class with no attendance yet is not taken', () {
      expect(
        only([record(math, monday, time: const ClockTime(17, 0))]).state,
        ClassState.notTaken,
      );
    });

    test('cancelled and holiday', () {
      expect(
        only([
          record(
            math,
            monday,
            time: const ClockTime(17, 0),
            status: SessionStatus.cancelled,
          ),
        ]).state,
        ClassState.cancelled,
      );
      expect(
        only([
          record(
            math,
            monday,
            time: const ClockTime(17, 0),
            status: SessionStatus.holiday,
          ),
        ]).state,
        ClassState.holiday,
      );
    });

    test(
      'a row at a different time is an extra class, not the scheduled one',
      () {
        final result = expectedSessions(
          date: monday,
          rules: rules,
          records: [
            record(
              math,
              monday,
              time: const ClockTime(19, 0),
              count: 3,
              attended: 3,
            ),
          ],
        );
        expect(result, hasLength(2));
        expect(
          result.first.state,
          ClassState.notTaken,
        ); // 17:00 still not taken
        expect(result.last.isExtra, isTrue);
        expect(result.last.state, ClassState.taken);
      },
    );

    test('rows for other dates are ignored', () {
      final e = only([
        record(math, tuesday, time: const ClockTime(17, 0), count: 9),
      ]);
      expect(e.state, ClassState.notTaken);
    });

    test('a row for another owner does not match', () {
      final result = expectedSessions(
        date: monday,
        rules: rules,
        records: [
          record(physics, monday, time: const ClockTime(17, 0), count: 4),
        ],
      );
      expect(result, hasLength(2));
    });
  });

  group('extra classes', () {
    test('a recorded class on an unscheduled day appears as extra', () {
      final result = expectedSessions(
        date: tuesday,
        rules: [
          rule(math, [1]),
        ],
        records: [record(math, tuesday, count: 7, attended: 6)],
      );
      expect(result.single.isExtra, isTrue);
      expect(result.single.state, ClassState.taken);
    });

    test('a one-to-one extra class', () {
      final result = expectedSessions(
        date: sunday,
        rules: const [],
        records: [record(rahim, sunday)],
      );
      expect(result.single.owner, rahim);
      expect(result.single.isExtra, isTrue);
      expect(result.single.state, ClassState.notTaken);
    });
  });

  test('owners compare by kind and id, not by name', () {
    expect(const ClassOwner.batch('1', 'A'), const ClassOwner.batch('1', 'B'));
    expect(
      const ClassOwner.batch('1', 'A'),
      isNot(const ClassOwner.student('1', 'A')),
    );
  });

  test('a day with nothing scheduled or recorded is empty', () {
    expect(
      expectedSessions(date: monday, rules: const [], records: const []),
      isEmpty,
    );
  });
}
