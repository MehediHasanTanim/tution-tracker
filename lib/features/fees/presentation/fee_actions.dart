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
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
import 'package:tution_tracker/features/fees/presentation/fields_dialog.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

// Fee adjustments, shared by a student's Fees tab and the Fee adjustments
// page (spec FE-6, FE-7, FE-8, FE-11, FE-12).

/// Change fee, pause or resume, or add a one-time fee: [action] is `fee`,
/// `pause` or `onetime`.

Future<void> adjustStudentFees(
  BuildContext context,
  WidgetRef ref,
  Student student,
  String action,
  bool paused,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final language = ref.read(appLanguageProvider);
  final numerals = ref.read(numeralStyleProvider).value ?? NumeralStyle.bangla;
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

Future<void> dueActions(
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
              leading: const Icon(Icons.undo_rounded),
              title: Text(l10n.adjUnwaive),
              onTap: () => Navigator.pop(context, 'unwaive'),
            )
          else ...[
            ListTile(
              leading: const Icon(Icons.money_off_rounded),
              title: Text(l10n.adjWaive),
              onTap: () => Navigator.pop(context, 'waive'),
            ),
            ListTile(
              leading: const Icon(Icons.percent_rounded),
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

Future<void> paymentActions(
  BuildContext context,
  WidgetRef ref,
  Payment payment,
) async {
  final l10n = AppLocalizations.of(context);
  final numerals = ref.read(numeralStyleProvider).value ?? NumeralStyle.bangla;
  final messenger = ScaffoldMessenger.of(context);
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: Text(l10n.receiptAction),
            onTap: () => Navigator.pop(context, 'receipt'),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.actionEdit),
            onTap: () => Navigator.pop(context, 'edit'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded),
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
