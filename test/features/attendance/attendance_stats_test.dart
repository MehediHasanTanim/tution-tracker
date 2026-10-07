import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_stats.dart';

const P = AttendanceStatus.present;
const A = AttendanceStatus.absent;
const L = AttendanceStatus.late;
const E = AttendanceStatus.excused;

void main() {
  group('percentage rule: (present + late) / (marked - excused)', () {
    test('all present is 100%', () {
      expect(AttendanceCounts.from([P, P, P, P]).percent, 100);
    });

    test('all absent is 0%', () {
      expect(AttendanceCounts.from([A, A, A]).percent, 0);
    });

    test('late counts as attended', () {
      final c = AttendanceCounts.from([P, L, A, A]);
      expect(c.attended, 2);
      expect(c.percent, 50);
    });

    test('excused absences count on neither side', () {
      // 3 present, 1 absent, 2 excused: 3 / (6 - 2) = 75%
      final c = AttendanceCounts.from([P, P, P, A, E, E]);
      expect(c.total, 6);
      expect(c.counted, 4);
      expect(c.percent, 75);
      expect(c.rate, 0.75);
    });

    test('an excused absence never lowers the percentage', () {
      final without = AttendanceCounts.from([P, P, A]);
      final withExcused = AttendanceCounts.from([P, P, A, E, E, E]);
      expect(withExcused.percent, without.percent);
    });

    test('percent rounds halves up', () {
      expect(
        AttendanceCounts.from([P, A, A, A, A, A, A, A]).percent,
        13,
      ); // 12.5
      expect(AttendanceCounts.from([P, P, A]).percent, 67); // 66.67
      expect(AttendanceCounts.from([P, A, A]).percent, 33); // 33.33
    });

    test('nothing counted gives null, not zero or an error', () {
      expect(AttendanceCounts.none.percent, isNull);
      expect(AttendanceCounts.none.rate, isNull);
      expect(AttendanceCounts.from([E, E]).percent, isNull); // only excused
    });
  });

  group('counting', () {
    test('tallies each status', () {
      final c = AttendanceCounts.from([P, P, A, L, E, P]);
      expect((c.present, c.absent, c.late, c.excused), (3, 1, 1, 1));
      expect(c.total, 6);
    });

    test('counts add up across students or classes', () {
      final sum =
          AttendanceCounts.from([P, A]) + AttendanceCounts.from([L, E, P]);
      expect(
        sum,
        const AttendanceCounts(present: 2, absent: 1, late: 1, excused: 1),
      );
      expect(sum.percent, 75); // 3 of 4 counted
    });

    test('equality and hashing follow the numbers', () {
      expect(AttendanceCounts.from([P, A]), AttendanceCounts.from([A, P]));
      expect({
        AttendanceCounts.from([P]),
        AttendanceCounts.from([P]),
      }, hasLength(1));
    });
  });

  group('day status on a calendar', () {
    test('absent wins over late, present and excused', () {
      expect(dayStatusFor(marks: [P, A, L, E], offDays: []), DayStatus.absent);
    });

    test('late wins over present', () {
      expect(dayStatusFor(marks: [P, L], offDays: []), DayStatus.late);
    });

    test('present wins over excused', () {
      expect(dayStatusFor(marks: [E, P], offDays: []), DayStatus.present);
    });

    test('a single mark shows as itself', () {
      expect(dayStatusFor(marks: [E], offDays: []), DayStatus.excused);
      expect(dayStatusFor(marks: [P], offDays: []), DayStatus.present);
    });

    test('cancelled and holiday only show when nothing was marked', () {
      expect(
        dayStatusFor(marks: [], offDays: [SessionKind.cancelled]),
        DayStatus.cancelled,
      );
      expect(
        dayStatusFor(marks: [], offDays: [SessionKind.holiday]),
        DayStatus.holiday,
      );
      expect(
        dayStatusFor(
          marks: [],
          offDays: [SessionKind.cancelled, SessionKind.holiday],
        ),
        DayStatus.holiday,
      );
      expect(
        dayStatusFor(marks: [P], offDays: [SessionKind.holiday]),
        DayStatus.present,
      );
    });

    test('no marks and no off days means no mark', () {
      expect(dayStatusFor(marks: [], offDays: []), isNull);
    });
  });
}
