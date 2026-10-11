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
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/features/fees/domain/fee_status.dart';
import 'package:tution_tracker/features/fees/presentation/fee_actions.dart';
import 'package:tution_tracker/features/fees/presentation/fee_status_style.dart';
import 'package:tution_tracker/features/fees/presentation/fees_providers.dart';
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
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: EdgeInsets.zero,
            color: Organic.of(context).accentSoft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(OrganicRadius.panel),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.feesOutstanding,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Organic.of(context).onAccentSoft,
                    ),
                  ),
                  Text(
                    money(outstanding),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Organic.of(context).onAccentSoft,
                    ),
                  ),
                  if (credit > 0)
                    Text(
                      '${l10n.tabFeesCredit}: ${money(credit)}',
                      style: TextStyle(color: Organic.of(context).onAccentSoft),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () =>
                              context.push('/fees/pay/${student.id}'),
                          icon: const Icon(Icons.payments_rounded),
                          label: Text(l10n.actionRecordPayment),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.push('/students/${student.id}/adjust'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(64, 52),
                        ),
                        icon: const Icon(Icons.tune_rounded),
                        label: Text(l10n.actionAdjust),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _SectionTitle(l10n.ledgerTitle),
          if (ledger.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
              onTap: () => dueActions(context, ref, b, money),
            ),
          _SectionTitle(l10n.paymentsTitle),
          if (payments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.noPayments),
            ),
          for (final p in payments)
            Card(
              child: ListTile(
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
                onTap: () => paymentActions(context, ref, p),
              ),
            ),
        ],
      ),
    );
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
    padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
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
    final status = statusOf(
      waived: due.waived == 1,
      balance: due.balance,
      paid: due.paid,
      dueDate: LocalDate.parse(due.dueDate),
      today: today,
    );
    final (label, background, foreground) = feeStatusStyle(
      status,
      l10n,
      Organic.of(context),
    );
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('$amounts\n$running'),
        isThreeLine: true,
        trailing: Chip(
          label: Text(label, style: TextStyle(color: foreground)),
          backgroundColor: background,
          visualDensity: VisualDensity.compact,
        ),
        onTap: onTap,
      ),
    );
  }
}
