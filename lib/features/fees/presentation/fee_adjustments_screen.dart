import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
import 'package:tution_tracker/features/fees/domain/payment_method.dart';
import 'package:tution_tracker/features/fees/presentation/fee_actions.dart';
import 'package:tution_tracker/features/fees/presentation/fees_providers.dart';
import 'package:tution_tracker/features/fees/presentation/payment_labels.dart';
import 'package:tution_tracker/features/students/data/student_form_providers.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Everything that changes what a student owes, in one place (design:
/// `fadj`): change the fee, pause billing, add a one-time fee, waive or
/// discount this month, and correct or delete payments.
class FeeAdjustmentsScreen extends ConsumerWidget {
  const FeeAdjustmentsScreen({required this.studentId, super.key});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final o = Organic.of(context);
    final student = ref.watch(studentStreamProvider(studentId)).value;
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;
    final today = todayFrom(ref.watch(clockProvider));
    final month = YearMonth.from(today);
    final ledger =
        ref.watch(studentLedgerProvider(studentId)).value ?? const [];
    final payments =
        ref.watch(studentPaymentsProvider(studentId)).value ?? const [];
    final paused = ref.watch(feesPausedProvider(studentId)).value ?? false;

    String money(int a) =>
        formatTaka(Taka(a), numerals: numerals, grouping: grouping);
    final monthText = formatMonth(
      month,
      language: language,
      numerals: numerals,
    );

    if (student == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // This month's regular due, the one the waive item acts on.
    final thisMonth = ledger
        .where((d) => d.month == month.toKey() && d.kind != 'one_time')
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.actionAdjust)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          BlockStack(
            children: [
              BlockText(
                [
                  student.name,
                  l10n.fadjThisMonth(money(thisMonth?.payable ?? 0)),
                  if (paused) l10n.fadjPaused,
                ].join(' · '),
              ),
              BlockItem(
                leading: const BlockIcon(Icons.payments_rounded),
                title: l10n.adjChangeFee,
                subtitle: l10n.studentFeePerMonth(money(student.monthlyFee)),
                chevron: true,
                onTap: () =>
                    adjustStudentFees(context, ref, student, 'fee', paused),
              ),
              BlockItem(
                leading: BlockIcon(
                  paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                ),
                title: paused ? l10n.adjResume : l10n.adjPause,
                subtitle: paused ? l10n.fadjResumeSub : l10n.fadjPauseSub,
                chevron: true,
                onTap: () =>
                    adjustStudentFees(context, ref, student, 'pause', paused),
              ),
              BlockItem(
                leading: const BlockIcon(Icons.add_rounded),
                title: l10n.adjOneTime,
                subtitle: l10n.fadjOneTimeSub,
                chevron: true,
                onTap: () =>
                    adjustStudentFees(context, ref, student, 'onetime', paused),
              ),
              BlockItem(
                leading: const BlockIcon(Icons.percent_rounded),
                title: l10n.fadjWaiveMonth(monthText),
                subtitle: thisMonth == null
                    ? l10n.noDues
                    : thisMonth.waived == 1
                    ? l10n.statusWaived
                    : thisMonth.discount > 0
                    ? '${l10n.adjDiscount} ${money(thisMonth.discount)}'
                    : l10n.fadjWaiveSub,
                chevron: thisMonth != null,
                onTap: thisMonth == null
                    ? null
                    : () => dueActions(context, ref, thisMonth, money),
              ),
              BlockSubheading(l10n.paymentsTitle),
              if (payments.isEmpty)
                BlockText(l10n.noPayments)
              else ...[
                BlockText(l10n.fadjPaymentsHint),
                for (final p in payments)
                  BlockItem(
                    title: formatDate(
                      LocalDate.parse(p.receivedOn),
                      language: language,
                      numerals: numerals,
                    ),
                    subtitle:
                        '${paymentMethodLabel(l10n, PaymentMethod.values.asNameMap()[p.method] ?? PaymentMethod.other)} · '
                        '${l10n.payReceiptNo(formatCount(p.receiptNo, numerals))}',
                    tag: money(p.amount),
                    tagBackground: o.sageSoft,
                    tagForeground: o.onSageSoft,
                    chevron: true,
                    onTap: () => paymentActions(context, ref, p),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
