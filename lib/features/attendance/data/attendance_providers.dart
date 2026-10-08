import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/features/attendance/data/attendance_repository.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_stats.dart';
import 'package:tution_tracker/features/attendance/domain/expected_sessions.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/features/students/data/student_providers.dart';
import 'package:tution_tracker/features/students/domain/student_filter.dart';

final attendanceRepositoryProvider = FutureProvider<AttendanceRepository>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  return AttendanceRepository(db);
});

/// The day the Today screen is showing. Starts on today; the tutor can move
/// it to look at or fix another day (spec AT-5).
class SelectedDate extends Notifier<LocalDate> {
  @override
  LocalDate build() => todayFrom(ref.read(clockProvider));

  void set(LocalDate date) => state = date;

  void shift(int days) => state = state.addDays(days);

  void resetToToday() => state = todayFrom(ref.read(clockProvider));
}

final selectedDateProvider = NotifierProvider<SelectedDate, LocalDate>(
  SelectedDate.new,
);

final _batchRulesProvider = StreamProvider.autoDispose<List<ScheduleRule>>((
  ref,
) async* {
  final repo = await ref.watch(attendanceRepositoryProvider.future);
  yield* repo.watchBatchRules();
});

final _oneToOneRulesProvider = StreamProvider.autoDispose<List<ScheduleRule>>((
  ref,
) async* {
  final repo = await ref.watch(attendanceRepositoryProvider.future);
  yield* repo.watchOneToOneRules();
});

final _sessionsOnProvider = StreamProvider.autoDispose
    .family<List<SessionRecord>, LocalDate>((ref, date) async* {
      final repo = await ref.watch(attendanceRepositoryProvider.future);
      yield* repo.watchSessionsOn(date);
    });

/// The classes for [date], scheduled and recorded, updating live.
final expectedSessionsProvider = Provider.autoDispose
    .family<AsyncValue<List<ExpectedSession>>, LocalDate>((ref, date) {
      final batches = ref.watch(_batchRulesProvider);
      final solo = ref.watch(_oneToOneRulesProvider);
      final sessions = ref.watch(_sessionsOnProvider(date));
      final error = batches.error ?? solo.error ?? sessions.error;
      if (error != null) return AsyncError(error, StackTrace.empty);
      if (!batches.hasValue || !solo.hasValue || !sessions.hasValue) {
        return const AsyncLoading();
      }
      return AsyncData(
        expectedSessions(
          date: date,
          rules: [...batches.value!, ...solo.value!],
          records: sessions.value!,
        ),
      );
    });

/// Which class an attendance sheet is for.
typedef SheetArgs = ({ClassOwner owner, LocalDate date, ClockTime? time});

/// What the attendance sheet needs: the saved class (if any) and its roster.
class SheetData {
  const SheetData(this.session, this.roster, this.ownerName);

  final SessionRecord? session;
  final List<RosterEntry> roster;

  /// Null if the batch or student has been deleted.
  final String? ownerName;
}

final sheetDataProvider = FutureProvider.autoDispose
    .family<SheetData, SheetArgs>((ref, args) async {
      final repo = await ref.watch(attendanceRepositoryProvider.future);
      return SheetData(
        await repo.findSession(args.owner, args.date, args.time),
        await repo.roster(args.owner, args.date, args.time),
        await repo.ownerName(args.owner),
      );
    });

typedef StudentMonth = ({String studentId, YearMonth month});

final studentMonthProvider = StreamProvider.autoDispose
    .family<AttendanceCounts, StudentMonth>((ref, key) async* {
      final repo = await ref.watch(attendanceRepositoryProvider.future);
      yield* repo.watchStudentMonth(key.studentId, key.month);
    });

final studentCalendarProvider = StreamProvider.autoDispose
    .family<List<DayMark>, StudentMonth>((ref, key) async* {
      final repo = await ref.watch(attendanceRepositoryProvider.future);
      yield* repo.watchStudentCalendar(key.studentId, key.month);
    });

/// Students to pick from when adding a one-to-one extra class.
final studentChoicesProvider = StreamProvider.autoDispose
    .family<List<Student>, String>((ref, query) async* {
      final repo = await ref.watch(studentRepositoryProvider.future);
      yield* repo.watch(StudentFilter(query: query));
    });

/// The location of the attendance sheet for a class.
String attendanceLocation(ClassOwner owner, LocalDate date, ClockTime? time) {
  final query = {
    'kind': owner.kind.name,
    'id': owner.id,
    'date': date.toIso(),
    'time': ?time?.toKey(),
  };
  return Uri(path: '/attendance', queryParameters: query).toString();
}

/// Reads a sheet location back into [SheetArgs]; null if it is malformed.
SheetArgs? parseAttendanceLocation(Map<String, String> query) {
  try {
    final id = query['id'];
    final date = query['date'];
    final kind = OwnerKind.values.byName(query['kind'] ?? '');
    if (id == null || date == null) return null;
    final owner = kind == OwnerKind.batch
        ? ClassOwner.batch(id, '')
        : ClassOwner.student(id, '');
    final time = query['time'];
    return (
      owner: owner,
      date: LocalDate.parse(date),
      time: time == null ? null : ClockTime.parse(time),
    );
  } on Object {
    return null;
  }
}
