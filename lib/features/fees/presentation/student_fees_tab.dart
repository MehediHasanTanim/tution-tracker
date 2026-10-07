import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
import 'package:tution_tracker/features/fees/domain/fee_status.dart';
import 'package:tution_tracker/features/fees/presentation/fees_providers.dart';
import 'package:tution_tracker/features/fees/presentation/fields_dialog.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// A student's fee ledger, payment history and fee adjustments, for the
/// Fees tab of their profile (spec FE-5, FE-6, FE-7, FE-8, FE-11, FE-12).
class StudentFeesTab extends ConsumerWidget {
  const StudentFeesTab({required this.student, super.key});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;
    final today = todayFrom(ref.watch(clockProvider));
    final ledger =
        ref.watch(studentLedgerProvider(student.id)).value ?? const [];
    final payments =
        ref.watch(studentPaymentsProvider(student.id)).value ?? const [];
    final credit = ref.watch(studentCreditProvider(student.id)).value ?? 0;
    final paused = ref.watch(feesPausedProvider(student.id)).value ?? false;

    String money(int a) =>
        formatTaka(Taka(a), numerals: numerals, grouping: grouping);
    String monthText(YearMonth m) =>
        formatMonth(m, language: language, numerals: numerals);

    final outstanding = ledger
        .where((b) => b.waived == 0)
        .fold<int>(0, (sum, b) => sum + b.balance);

    // Running total of what is owed, oldest first.
    var running = 0;
    final runningAfter = <String, int>{};
    for (final b in ledger) {
      if (b.waived == 0) running += b.balance;
      runningAfter[b.feeRecordId] = running;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.feesOutstanding,
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      money(outstanding),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (credit > 0)
                      Text('${l10n.tabFeesCredit}: ${money(credit)}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                context.push('/fees/pay/${student.id}'),
                            icon: const Icon(Icons.payments),
                            label: Text(l10n.actionRecordPayment),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          tooltip: l10n.actionAdjust,
                          onSelected: (v) => _adjust(context, ref, v, paused),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'fee',
                              child: Text(l10n.adjChangeFee),
                            ),
                            PopupMenuItem(
                              value: 'pause',
                              child: Text(
                                paused ? l10n.adjResume : l10n.adjPause,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'onetime',
                              child: Text(l10n.adjOneTime),
                            ),
                          ],
                          child: OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.tune),
                            label: Text(l10n.actionAdjust),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          _SectionTitle(l10n.ledgerTitle),
          if (ledger.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.noDues),
            ),
          for (final b in ledger)
            _LedgerRow(
              due: b,
              today: today,
              title: b.kind == 'one_time' && b.label != null
                  ? '${b.label} · ${monthText(YearMonth.parse(b.month))}'
                  : monthText(YearMonth.parse(b.month)),
              amounts: l10n.ledgerAmounts(
                money(b.payable),
                money(b.paid),
                money(b.waived == 1 ? 0 : b.balance),
              ),
              running: l10n.ledgerRunning(money(runningAfter[b.feeRecordId]!)),
              onTap: () => _dueActions(context, ref, b, money),
            ),
          _SectionTitle(l10n.paymentsTitle),
          if (payments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.noPayments),
            ),
          for (final p in payments)
            ListTile(
              title: Text(
                '${l10n.payReceiptNo(formatCount(p.receiptNo, numerals))} · ${formatDate(LocalDate.parse(p.receivedOn), language: language, numerals: numerals)}',
              ),
              subtitle: Text(_methodText(l10n, p.method)),
              trailing: Text(
                money(p.amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _paymentActions(context, ref, p),
            ),
        ],
      ),
    );
  }

  // ---- adjustments ------------------------------------------------------

  Future<void> _adjust(
    BuildContext context,
    WidgetRef ref,
    String action,
    bool paused,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final language = ref.read(appLanguageProvider);
    final numerals =
        ref.read(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final now = YearMonth.from(todayFrom(ref.read(clockProvider)));
    String monthText(YearMonth m) =>
        formatMonth(m, language: language, numerals: numerals);

    // A year back to a year ahead, never before the joining month.
    final joined = YearMonth.from(LocalDate.parse(student.joinedOn));
    final months = [
      for (var m = now.addMonths(-12); m <= now.addMonths(12); m = m.next())
        if (m >= joined) m,
    ];

    try {
      switch (action) {
        case 'fee':
          final r = await showDialog<FieldsResult>(
            context: context,
            builder: (_) => FieldsDialog(
              title: l10n.adjChangeFee,
              months: months,
              monthLabel: l10n.adjEffectiveMonth,
              initialMonth: months.contains(now) ? now : months.last,
              monthText: monthText,
              fields: [
                DialogField(
                  key: 'amount',
                  label: l10n.adjNewFee,
                  numeric: true,
                  initial: student.monthlyFee.toString(),
                ),
              ],
            ),
          );
          if (r == null) return;
          final repo = await ref.read(feeRepositoryProvider.future);
          await repo.changeFee(student.id, r.month!, r.intValue('amount'));
          messenger.showSnackBar(SnackBar(content: Text(l10n.adjFeeChanged)));
        case 'pause':
          final r = await showDialog<FieldsResult>(
            context: context,
            builder: (_) => FieldsDialog(
              title: paused ? l10n.adjResume : l10n.adjPause,
              months: months,
              monthLabel: paused ? l10n.adjResumeFrom : l10n.adjPauseFrom,
              initialMonth: months.contains(now) ? now : months.last,
              monthText: monthText,
              fields: const [],
            ),
          );
          if (r == null) return;
          final repo = await ref.read(feeRepositoryProvider.future);
          if (paused) {
            await repo.resumeFees(student.id, r.month!);
            messenger.showSnackBar(SnackBar(content: Text(l10n.adjResumed)));
          } else {
            await repo.pauseFees(student.id, r.month!);
            messenger.showSnackBar(SnackBar(content: Text(l10n.adjPaused)));
          }
        case 'onetime':
          final r = await showDialog<FieldsResult>(
            context: context,
            builder: (_) => FieldsDialog(
              title: l10n.adjOneTime,
              fields: [
                DialogField(
                  key: 'label',
                  label: l10n.adjOneTimeLabel,
                  requiredMessage: l10n.adjReasonRequired,
                ),
                DialogField(
                  key: 'amount',
                  label: l10n.adjOneTimeAmount,
                  numeric: true,
                ),
              ],
            ),
          );
          if (r == null) return;
          final repo = await ref.read(feeRepositoryProvider.future);
          await repo.addOneTimeFee(
            student.id,
            label: r.values['label']!,
            amount: r.intValue('amount'),
          );
          messenger.showSnackBar(SnackBar(content: Text(l10n.adjOneTimeAdded)));
      }
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }

  Future<void> _dueActions(
    BuildContext context,
    WidgetRef ref,
    FeeBalance due,
    String Function(int) money,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (due.waived == 1)
              ListTile(
                leading: const Icon(Icons.undo),
                title: Text(l10n.adjUnwaive),
                onTap: () => Navigator.pop(context, 'unwaive'),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.money_off),
                title: Text(l10n.adjWaive),
                onTap: () => Navigator.pop(context, 'waive'),
              ),
              ListTile(
                leading: const Icon(Icons.percent),
                title: Text(l10n.adjDiscount),
                onTap: () => Navigator.pop(context, 'discount'),
              ),
            ],
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;

    try {
      switch (choice) {
        case 'unwaive':
          final repo = await ref.read(feeRepositoryProvider.future);
          await repo.unwaive(due.feeRecordId);
        case 'waive':
          final r = await showDialog<FieldsResult>(
            context: context,
            builder: (_) => FieldsDialog(
              title: l10n.adjWaive,
              fields: [
                DialogField(
                  key: 'reason',
                  label: l10n.adjReason,
                  requiredMessage: l10n.adjReasonRequired,
                ),
              ],
            ),
          );
          if (r == null) return;
          final repo = await ref.read(feeRepositoryProvider.future);
          await repo.waive(due.feeRecordId, reason: r.values['reason']!);
        case 'discount':
          final r = await showDialog<FieldsResult>(
            context: context,
            builder: (_) => FieldsDialog(
              title: l10n.adjDiscount,
              fields: [
                DialogField(
                  key: 'amount',
                  label: l10n.adjDiscountAmount,
                  numeric: true,
                  initial: due.discount > 0 ? due.discount.toString() : '',
                  max: due.amountDue,
                  helper: money(due.amountDue),
                ),
                DialogField(
                  key: 'reason',
                  label: l10n.adjReason,
                  required: false,
                ),
              ],
            ),
          );
          if (r == null) return;
          final repo = await ref.read(feeRepositoryProvider.future);
          await repo.setDiscount(
            due.feeRecordId,
            r.intValue('amount'),
            reason: r.values['reason'],
          );
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.adjDone)));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }

  Future<void> _paymentActions(
    BuildContext context,
    WidgetRef ref,
    Payment payment,
  ) async {
    final l10n = AppLocalizations.of(context);
    final numerals =
        ref.read(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final messenger = ScaffoldMessenger.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(l10n.receiptAction),
              onTap: () => Navigator.pop(context, 'receipt'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.actionEdit),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.payDelete),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;

    if (choice == 'receipt') {
      await context.push('/fees/receipt/${payment.id}');
      return;
    }

    if (choice == 'edit') {
      await context.push('/fees/payments/${payment.id}/edit');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.payDeleteTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.payDeleteBody(formatCount(payment.receiptNo, numerals))),
            if (payment.receiptSharedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                l10n.payReceiptSharedWarning,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.payDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final repo = await ref.read(paymentRepositoryProvider.future);
    await repo.delete(payment.id);
    messenger.showSnackBar(SnackBar(content: Text(l10n.payDeleted)));
  }
}

String _methodText(AppLocalizations l10n, String method) => switch (method) {
  'cash' => l10n.methodCash,
  'bkash' => l10n.methodBkash,
  'nagad' => l10n.methodNagad,
  'rocket' => l10n.methodRocket,
  'bank' => l10n.methodBank,
  _ => l10n.methodOther,
};

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.due,
    required this.today,
    required this.title,
    required this.amounts,
    required this.running,
    required this.onTap,
  });

  final FeeBalance due;
  final LocalDate today;
  final String title;
  final String amounts;
  final String running;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final status = statusOf(
      waived: due.waived == 1,
      balance: due.balance,
      paid: due.paid,
      dueDate: LocalDate.parse(due.dueDate),
      today: today,
    );
    final (label, color) = switch (status) {
      FeeStatus.paid => (l10n.statusPaid, scheme.primaryContainer),
      FeeStatus.partial => (l10n.statusPartial, scheme.tertiaryContainer),
      FeeStatus.due => (l10n.statusDue, scheme.surfaceContainerHighest),
      FeeStatus.overdue => (l10n.statusOverdue, scheme.errorContainer),
      FeeStatus.waived => (l10n.statusWaived, scheme.secondaryContainer),
    };
    return ListTile(
      title: Text(title),
      subtitle: Text('$amounts\n$running'),
      isThreeLine: true,
      trailing: Chip(
        label: Text(label),
        backgroundColor: color,
        visualDensity: VisualDensity.compact,
      ),
      onTap: onTap,
    );
  }
}
