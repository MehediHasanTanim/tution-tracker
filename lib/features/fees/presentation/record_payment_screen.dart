import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/digits.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/ui/input_formatters.dart';
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/fees/domain/allocation.dart';
import 'package:tution_tracker/features/fees/domain/payment_method.dart';
import 'package:tution_tracker/features/fees/presentation/fees_providers.dart';
import 'package:tution_tracker/features/students/data/student_form_providers.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Record a payment for [studentId], or edit the payment [paymentId].
/// Exactly one of the two is given.
class RecordPaymentScreen extends ConsumerWidget {
  const RecordPaymentScreen({this.studentId, this.paymentId, super.key})
    : assert(
        (studentId == null) != (paymentId == null),
        'give a student or a payment',
      );

  final String? studentId;
  final String? paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    Widget loading() => Scaffold(
      appBar: AppBar(),
      body: const Center(child: CircularProgressIndicator()),
    );

    // Editing: find the payment (and so the student) first.
    Payment? existing;
    var sid = studentId;
    if (paymentId != null) {
      final payment = ref.watch(paymentProvider(paymentId!));
      if (!payment.hasValue) return loading();
      existing = payment.value;
      if (existing == null) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(child: Text(l10n.studentsNoMatch)),
        );
      }
      sid = existing.studentId;
    }

    final student = ref.watch(studentStreamProvider(sid!));
    final dues = ref.watch(
      payableDuesProvider((studentId: sid, paymentId: paymentId)),
    );
    final credit = ref.watch(studentCreditProvider(sid));
    if (!student.hasValue || !dues.hasValue || !credit.hasValue) {
      return loading();
    }
    final s = student.value;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.studentsNoMatch)),
      );
    }
    return _PaymentForm(
      student: s,
      dues: dues.value!,
      credit: credit.value!,
      existing: existing,
    );
  }
}

class _PaymentForm extends ConsumerStatefulWidget {
  const _PaymentForm({
    required this.student,
    required this.dues,
    required this.credit,
    required this.existing,
  });

  final Student student;
  final List<PayableDue> dues;
  final int credit;
  final Payment? existing;

  @override
  ConsumerState<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<_PaymentForm> {
  late final TextEditingController _amount;
  late final TextEditingController _reference;
  late final TextEditingController _note;
  late PaymentMethod _method;
  LocalDate? _date;
  final Set<YearMonth> _months = {};
  String? _amountError;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  int get _outstanding => widget.dues.fold(0, (sum, d) => sum + d.due.balance);

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    // New payment: the whole balance is prefilled, so a full payment is one
    // tap on Save (spec flow B).
    _amount = TextEditingController(
      text: p != null
          ? p.amount.toString()
          : (_outstanding > 0 ? _outstanding.toString() : ''),
    );
    _reference = TextEditingController(text: p?.reference ?? '');
    _note = TextEditingController(text: p?.note ?? '');
    _method = p == null
        ? PaymentMethod.cash
        : PaymentMethod.values.byName(p.method);
    if (p != null) _date = LocalDate.parse(p.receivedOn);
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _note.dispose();
    super.dispose();
  }

  int? get _enteredAmount {
    final text = toWesternDigits(_amount.text.trim());
    final value = int.tryParse(text);
    return value != null && value > 0 ? value : null;
  }

  AllocationTarget get _target =>
      _months.isEmpty ? const OldestFirst() : SpecificMonths(_months.toList());

  List<AllocationLine>? get _preview {
    final amount = _enteredAmount;
    if (amount == null) return null;
    return allocate(
      paymentAmount: amount,
      openDues: [for (final d in widget.dues) d.due],
      target: _target,
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final amount = _enteredAmount;
    if (amount == null) {
      setState(() => _amountError = l10n.payAmountRequired);
      return;
    }
    setState(() {
      _amountError = null;
      _saving = true;
    });
    final today = todayFrom(ref.read(clockProvider));
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final repo = await ref.read(paymentRepositoryProvider.future);
      final RecordedPayment result;
      if (_editing) {
        result = await repo.edit(
          widget.existing!.id,
          PaymentEdit(
            amount: amount,
            receivedOn: _date ?? today,
            method: _method,
            reference: _reference.text,
            note: _note.text,
            target: _target,
          ),
        );
      } else {
        result = await repo.record(
          PaymentInput(
            studentId: widget.student.id,
            amount: amount,
            receivedOn: _date ?? today,
            method: _method,
            reference: _reference.text,
            note: _note.text,
            target: _target,
          ),
        );
      }
      if (!mounted) return;
      await _showResult(result);
      messenger.showSnackBar(SnackBar(content: Text(l10n.paySaved)));
      if (router.canPop()) router.pop();
    } on PaymentException {
      if (mounted) setState(() => _amountError = l10n.payAmountRequired);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showResult(RecordedPayment result) {
    final l10n = AppLocalizations.of(context);
    // Read everything the dialog needs now: its builder can run again while
    // this screen is closing, when `ref` and `context` are no longer valid.
    final receiptNo = formatCount(
      result.payment.receiptNo,
      ref.read(numeralStyleProvider).value ?? NumeralStyle.bangla,
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, size: 40),
        title: Text(l10n.paySaved),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.payReceiptNo(receiptNo),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _BreakdownList(lines: result.lines, dues: widget.dues),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.payDone),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;
    final today = todayFrom(ref.watch(clockProvider));
    final date = _date ?? today;

    String money(int a) =>
        formatTaka(Taka(a), numerals: numerals, grouping: grouping);

    // One chip per month that has something open.
    final monthBalances = <YearMonth, int>{};
    for (final d in widget.dues) {
      monthBalances[d.due.month] =
          (monthBalances[d.due.month] ?? 0) + d.due.balance;
    }
    final preview = _preview;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? l10n.payEditTitle : l10n.actionRecordPayment),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(l10n.actionSave),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.student.name, style: theme.textTheme.titleLarge),
            Text(l10n.payOutstanding(money(_outstanding))),
            if (widget.credit > 0) Text(l10n.payCredit(money(widget.credit))),
            if (_editing && widget.existing!.receiptSharedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      l10n.payReceiptSharedWarning,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              autofocus: !_editing,
              keyboardType: TextInputType.number,
              inputFormatters: [
                const DigitsOnlyFormatter(),
                LengthLimitingTextInputFormatter(8),
              ],
              style: theme.textTheme.headlineSmall,
              decoration: InputDecoration(
                labelText: '${l10n.payAmount} *',
                errorText: _amountError,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() => _amountError = null),
            ),
            if (monthBalances.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l10n.payMonths, style: theme.textTheme.titleSmall),
              Text(l10n.payMonthsHint, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final entry in monthBalances.entries)
                    FilterChip(
                      label: Text(
                        '${formatMonth(entry.key, language: language, numerals: numerals)} · ${money(entry.value)}',
                      ),
                      selected: _months.contains(entry.key),
                      onSelected: (on) => setState(
                        () => on
                            ? _months.add(entry.key)
                            : _months.remove(entry.key),
                      ),
                    ),
                ],
              ),
            ],
            if (preview != null) ...[
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.payBreakdown,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _BreakdownList(lines: preview, dues: widget.dues),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(l10n.payMethod, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final m in PaymentMethod.values)
                  ChoiceChip(
                    label: Text(_methodLabel(l10n, m)),
                    selected: _method == m,
                    onSelected: (_) => setState(() => _method = m),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reference,
              decoration: InputDecoration(
                labelText: l10n.payReference,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.payDate),
              subtitle: Text(
                formatDate(date, language: language, numerals: numerals),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(date.year, date.month, date.day),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(
                    today.year,
                    today.month,
                    today.day,
                  ).add(const Duration(days: 1)),
                );
                if (picked != null) {
                  setState(() => _date = LocalDate.fromDateTime(picked));
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.fieldNotes,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

String _methodLabel(AppLocalizations l10n, PaymentMethod m) => switch (m) {
  PaymentMethod.cash => l10n.methodCash,
  PaymentMethod.bkash => l10n.methodBkash,
  PaymentMethod.nagad => l10n.methodNagad,
  PaymentMethod.rocket => l10n.methodRocket,
  PaymentMethod.bank => l10n.methodBank,
  PaymentMethod.other => l10n.methodOther,
};

/// "March 2026 ... ৳ 1,500" lines, then advance credit. Drawn from the same
/// [allocate] output that gets saved, so what is shown is what happens.
class _BreakdownList extends ConsumerWidget {
  const _BreakdownList({required this.lines, required this.dues});

  final List<AllocationLine> lines;
  final List<PayableDue> dues;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;

    String label(AllocationLine line) {
      if (line.isCredit) return l10n.payCreditLine;
      for (final d in dues) {
        if (d.due.id == line.feeRecordId) {
          return d.kind == 'one_time' && d.label != null
              ? '${d.label} (${formatMonth(d.due.month, language: language, numerals: numerals)})'
              : formatMonth(
                  d.due.month,
                  language: language,
                  numerals: numerals,
                );
        }
      }
      return '';
    }

    return Column(
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(child: Text(label(line))),
                Text(
                  formatTaka(
                    Taka(line.amount),
                    numerals: numerals,
                    grouping: grouping,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
