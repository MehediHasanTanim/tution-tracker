import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/platform/url_launcher_service.dart';
import 'package:tution_tracker/features/fees/data/fee_repository.dart';
import 'package:tution_tracker/features/fees/domain/fee_status.dart';
import 'package:tution_tracker/features/fees/presentation/fees_providers.dart';
import 'package:tution_tracker/features/messaging/data/messaging_providers.dart';
import 'package:tution_tracker/features/messaging/data/reminder_log.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Steps through every overdue student: show the message, open SMS or
/// WhatsApp, mark the guardian as reminded, move on. What has been done is
/// saved, so leaving the app halfway and coming back carries on from the
/// next student.
class BulkReminderScreen extends ConsumerStatefulWidget {
  const BulkReminderScreen({super.key});

  @override
  ConsumerState<BulkReminderScreen> createState() => _BulkReminderScreenState();
}

class _BulkReminderScreenState extends ConsumerState<BulkReminderScreen>
    with WidgetsBindingObserver {
  /// Students the tutor passed over this session.
  final _skipped = <String>{};

  /// Set when a messaging app was opened; cleared when the tutor returns.
  String? _awaiting;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the messaging app: the tutor presumably sent it.
    if (state == AppLifecycleState.resumed && _awaiting != null) {
      final id = _awaiting!;
      _awaiting = null;
      _markDone(id);
    }
  }

  Future<void> _markDone(String studentId) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final today = todayFrom(ref.read(clockProvider));
    final log = await ref.read(reminderLogProvider.future);
    final previous = (await log.all())[studentId];
    await log.mark(studentId, today);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.remindMarked),
          action: SnackBarAction(
            label: l10n.remindUndo,
            onPressed: () => log.unmark(studentId, previous: previous),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = todayFrom(ref.watch(clockProvider));
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final dues = ref.watch(dueListProvider);
    final log = ref.watch(reminderLogEntriesProvider(0)).value ?? const {};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindBulkTitle)),
      body: dues.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          final overdue = [
            for (final e in list)
              if (overdueDays(e.oldestDueDate, today) > 0) e,
          ]..sort((a, b) => a.oldestDueDate.compareTo(b.oldestDueDate));
          if (overdue.isEmpty) {
            return Center(child: Text(l10n.remindNothing));
          }
          final pending = [
            for (final e in overdue)
              if (!isRecentlyReminded(log[e.student.id], today)) e,
          ];
          final done = overdue.length - pending.length;
          final header = Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.remindBulkProgress(
                    formatCount(done, numerals),
                    formatCount(overdue.length, numerals),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: done / overdue.length),
              ],
            ),
          );
          if (pending.isEmpty) {
            return Column(
              children: [
                header,
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 64),
                        const SizedBox(height: 12),
                        Text(l10n.remindDoneAll),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () async {
                            final l = await ref.read(
                              reminderLogProvider.future,
                            );
                            await l.clear();
                            setState(_skipped.clear);
                          },
                          child: Text(l10n.remindClear),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          final current = pending.firstWhere(
            (e) => !_skipped.contains(e.student.id),
            orElse: () => pending.first,
          );
          return Column(
            children: [
              header,
              Expanded(
                child: _StudentStep(
                  // A fresh message for each student.
                  key: ValueKey(current.student.id),
                  entry: current,
                  today: today,
                  lastReminded: log[current.student.id],
                  onOpened: () => _awaiting = current.student.id,
                  onMarkDone: () => _markDone(current.student.id),
                  onSkip: () => setState(() {
                    _skipped.add(current.student.id);
                    if (pending.every((e) => _skipped.contains(e.student.id))) {
                      _skipped
                        ..clear()
                        ..add(current.student.id);
                    }
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudentStep extends ConsumerStatefulWidget {
  const _StudentStep({
    required this.entry,
    required this.today,
    required this.lastReminded,
    required this.onOpened,
    required this.onMarkDone,
    required this.onSkip,
    super.key,
  });

  final DueListEntry entry;
  final LocalDate today;
  final LocalDate? lastReminded;
  final VoidCallback onOpened;
  final VoidCallback onMarkDone;
  final VoidCallback onSkip;

  @override
  ConsumerState<_StudentStep> createState() => _StudentStepState();
}

class _StudentStepState extends ConsumerState<_StudentStep> {
  final _text = TextEditingController();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _compose();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _compose() async {
    _text.text = await ref
        .read(feeReminderComposerProvider)
        .compose(factsFor(widget.entry));
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _open(MessageChannel channel) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final phone = contactPhone(widget.entry.student);
    if (phone == null) return;
    final ok = await openMessage(
      ref.read(urlLauncherProvider),
      channel: channel,
      phone: phone,
      text: _text.text,
    );
    if (ok) {
      widget.onOpened();
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.contactLaunchFailed)));
    }
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
    final student = widget.entry.student;
    final phone = contactPhone(student);
    final late = overdueDays(widget.entry.oldestDueDate, widget.today);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(student.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          [
            formatTaka(
              Taka(widget.entry.totalBalance),
              numerals: numerals,
              grouping: grouping,
            ),
            l10n.feesOverdueDays(formatCount(late, numerals)),
            if (widget.lastReminded != null)
              l10n.remindLast(
                formatDate(
                  widget.lastReminded!,
                  language: language,
                  numerals: numerals,
                ),
              ),
          ].join(' · '),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _text,
          enabled: _ready,
          minLines: 5,
          maxLines: 10,
          decoration: InputDecoration(
            helperText: l10n.remindEditHint,
            border: const OutlineInputBorder(),
          ),
        ),
        if (phone == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.remindNoPhone,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.sms_outlined),
                onPressed: _ready && phone != null
                    ? () => _open(MessageChannel.sms)
                    : null,
                label: Text(l10n.remindSms),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.chat_outlined),
                onPressed: _ready && phone != null
                    ? () => _open(MessageChannel.whatsapp)
                    : null,
                label: Text(l10n.remindWhatsApp),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(l10n.remindAwaiting, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.check),
          onPressed: widget.onMarkDone,
          label: Text(l10n.remindMarkDone),
        ),
        TextButton(onPressed: widget.onSkip, child: Text(l10n.remindSkip)),
      ],
    );
  }
}
