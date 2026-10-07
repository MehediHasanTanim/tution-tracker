import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/platform/url_launcher_service.dart';
import 'package:tution_tracker/features/fees/data/fee_repository.dart';
import 'package:tution_tracker/features/messaging/data/messaging_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Sends one guardian a fee reminder: shows the message, lets the tutor edit
/// it, then opens SMS or WhatsApp with it filled in.
Future<void> showReminderSheet(BuildContext context, DueListEntry entry) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ReminderSheet(entry: entry),
  );
}

class _ReminderSheet extends ConsumerStatefulWidget {
  const _ReminderSheet({required this.entry});

  final DueListEntry entry;

  @override
  ConsumerState<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<_ReminderSheet> {
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

  Future<void> _send(MessageChannel channel) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final phone = contactPhone(widget.entry.student);
    if (phone == null) return;
    final launcher = ref.read(urlLauncherProvider);
    final today = todayFrom(ref.read(clockProvider));
    final log = await ref.read(reminderLogProvider.future);
    final ok = await openMessage(
      launcher,
      channel: channel,
      phone: phone,
      text: _text.text,
    );
    if (ok) {
      await log.mark(widget.entry.student.id, today);
      navigator.pop();
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.contactLaunchFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final phone = contactPhone(widget.entry.student);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.remindGuardian, style: theme.textTheme.titleLarge),
            Text(widget.entry.student.name, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              enabled: _ready,
              minLines: 4,
              maxLines: 8,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.sms_outlined),
                    onPressed: _ready && phone != null
                        ? () => _send(MessageChannel.sms)
                        : null,
                    label: Text(l10n.remindSms),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.chat_outlined),
                    onPressed: _ready && phone != null
                        ? () => _send(MessageChannel.whatsapp)
                        : null,
                    label: Text(l10n.remindWhatsApp),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                final router = GoRouter.of(context);
                Navigator.pop(context);
                router.push('/settings/templates');
              },
              child: Text(l10n.remindEditTemplate),
            ),
          ],
        ),
      ),
    );
  }
}
