import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/features/batches/data/batch_providers.dart';
import 'package:tution_tracker/features/batches/data/batch_repository.dart';
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
import 'package:tution_tracker/features/fees/data/fee_repository.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/fees/domain/fee_status.dart';

enum DueMode { all, overdue, dueThisWeek }

enum DueSort { overdueDays, amount }

class DueFilter {
  const DueFilter({
    this.mode = DueMode.all,
    this.sort = DueSort.overdueDays,
    this.batchId,
  });

  final DueMode mode;
  final DueSort sort;
  final String? batchId;
}

class DueFilterNotifier extends Notifier<DueFilter> {
  @override
  DueFilter build() => const DueFilter();

  void setMode(DueMode mode) =>
      state = DueFilter(mode: mode, sort: state.sort, batchId: state.batchId);

  void setSort(DueSort sort) =>
      state = DueFilter(mode: state.mode, sort: sort, batchId: state.batchId);

  void setBatch(String? batchId) =>
      state = DueFilter(mode: state.mode, sort: state.sort, batchId: batchId);
}

final dueFilterProvider = NotifierProvider<DueFilterNotifier, DueFilter>(
  DueFilterNotifier.new,
);

/// Everyone who owes something, unfiltered.
final dueListProvider = StreamProvider.autoDispose<List<DueListEntry>>((
  ref,
) async* {
  final repo = await ref.watch(feeRepositoryProvider.future);
  yield* repo.watchDueList();
});

/// [dueListProvider] after the filter and sort.
final visibleDueListProvider =
    Provider.autoDispose<AsyncValue<List<DueListEntry>>>((ref) {
      final filter = ref.watch(dueFilterProvider);
      final today = todayFrom(ref.read(clockProvider));
      final all = ref.watch(dueListProvider);

      Set<String>? inBatch;
      if (filter.batchId != null) {
        final members = ref.watch(batchMembersProvider(filter.batchId!)).value;
        inBatch = {
          for (final m in members ?? <BatchMemberView>[]) m.student.id,
        };
      }

      return all.whenData((list) {
        final shown = [
          for (final e in list)
            if ((inBatch == null || inBatch.contains(e.student.id)) &&
                switch (filter.mode) {
                  DueMode.all => true,
                  DueMode.overdue => overdueDays(e.oldestDueDate, today) > 0,
                  DueMode.dueThisWeek => e.dues.any((d) {
                    final due = _parse(d.dueDate);
                    return due >= today && due <= today.addDays(6);
                  }),
                })
              e,
        ];
        shown.sort((a, b) {
          final byAmount = b.totalBalance.compareTo(a.totalBalance);
          if (filter.sort == DueSort.amount) return byAmount;
          final byDays = overdueDays(
            b.oldestDueDate,
            today,
          ).compareTo(overdueDays(a.oldestDueDate, today));
          return byDays != 0 ? byDays : byAmount;
        });
        return shown;
      });
    });

final studentLedgerProvider = StreamProvider.autoDispose
    .family<List<FeeBalance>, String>((ref, studentId) async* {
      final repo = await ref.watch(feeRepositoryProvider.future);
      yield* repo.watchLedger(studentId);
    });

final studentPaymentsProvider = StreamProvider.autoDispose
    .family<List<Payment>, String>((ref, studentId) async* {
      final repo = await ref.watch(paymentRepositoryProvider.future);
      yield* repo.watchForStudent(studentId);
    });

final studentCreditProvider = StreamProvider.autoDispose.family<int, String>((
  ref,
  studentId,
) async* {
  final repo = await ref.watch(paymentRepositoryProvider.future);
  yield* repo.watchCreditBalance(studentId);
});

/// Whether the student's fees are paused (an open-ended pause exists).
final feesPausedProvider = StreamProvider.autoDispose.family<bool, String>((
  ref,
  studentId,
) async* {
  final repo = await ref.watch(feeRepositoryProvider.future);
  yield* repo
      .watchPauses(studentId)
      .map((l) => l.any((p) => p.toMonth == null));
});

LocalDate _parse(String iso) => LocalDate.parse(iso);

/// Dues a payment for [studentId] could go to; for an edit, as they stand
/// without that payment.
final payableDuesProvider = FutureProvider.autoDispose
    .family<List<PayableDue>, ({String studentId, String? paymentId})>((
      ref,
      key,
    ) async {
      final repo = await ref.watch(paymentRepositoryProvider.future);
      return repo.payableDues(key.studentId, excludingPaymentId: key.paymentId);
    });

final paymentProvider = FutureProvider.autoDispose.family<Payment?, String>((
  ref,
  id,
) async {
  final repo = await ref.watch(paymentRepositoryProvider.future);
  return repo.getById(id);
});
