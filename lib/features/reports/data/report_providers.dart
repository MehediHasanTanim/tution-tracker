import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/features/attendance/data/attendance_providers.dart';
import 'package:tution_tracker/features/reports/data/report_repository.dart';

final reportRepositoryProvider = FutureProvider<ReportRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final attendance = await ref.watch(attendanceRepositoryProvider.future);
  return ReportRepository(db, attendance);
});

final monthSummaryProvider = StreamProvider.autoDispose
    .family<MonthSummary, YearMonth>((ref, month) async* {
      final repo = await ref.watch(reportRepositoryProvider.future);
      yield* repo.watchMonthSummary(month);
    });

final owingProvider = StreamProvider.autoDispose
    .family<OwingSummary, LocalDate>((ref, today) async* {
      final repo = await ref.watch(reportRepositoryProvider.future);
      yield* repo.watchOwing(today);
    });

final upcomingDuesProvider = StreamProvider.autoDispose
    .family<List<UpcomingDue>, LocalDate>((ref, today) async* {
      final repo = await ref.watch(reportRepositoryProvider.future);
      yield* repo.watchUpcomingDues(today);
    });

final batchBreakdownProvider = StreamProvider.autoDispose
    .family<List<BatchBreakdown>, YearMonth>((ref, month) async* {
      final repo = await ref.watch(reportRepositoryProvider.future);
      yield* repo.watchBatchBreakdown(month);
    });

final incomeProvider = StreamProvider.autoDispose
    .family<List<MonthIncome>, YearMonth>((ref, last) async* {
      final repo = await ref.watch(reportRepositoryProvider.future);
      yield* repo.watchIncome(last);
    });
