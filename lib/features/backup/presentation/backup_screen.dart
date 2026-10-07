import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/platform/file_picker_service.dart';
import 'package:tution_tracker/core/platform/share_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/backup/data/backup_providers.dart';
import 'package:tution_tracker/features/backup/data/restore_service.dart';
import 'package:tution_tracker/features/backup/domain/backup_exception.dart';
import 'package:tution_tracker/features/backup/presentation/backup_dialogs.dart';
import 'package:tution_tracker/features/backup/presentation/backup_labels.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Back up, restore, and delete everything (spec 3.10, design 10).
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _protect = false;

  Future<void> _backup() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    String? password;
    if (_protect) {
      password = await askPassword(
        context,
        title: l10n.bkEncrypt,
        confirm: true,
      );
      if (password == null || !mounted) return;
    }
    try {
      final service = await ref.read(backupServiceProvider.future);
      if (!mounted) return;
      final backup = await runWithProgress(
        context,
        l10n.bkWorking,
        () => service.createBackup(password: password),
      );
      final shared = await ref
          .read(shareServiceProvider)
          .shareFile(
            backup.file.path,
            mimeType: 'application/octet-stream',
            subject: backup.file.uri.pathSegments.last,
          );
      if (shared) {
        await service.recordBackup();
        messenger.showSnackBar(SnackBar(content: Text(l10n.bkSavedHint)));
      }
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.bkFailed)));
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final file = await ref.read(filePickerProvider).pickFile();
    if (file == null || !mounted) return;
    final service = await ref.read(restoreServiceProvider.future);
    if (!mounted) return;

    RestorePreview? preview;
    String? password;
    String? error;
    while (preview == null) {
      try {
        preview = await runWithProgress(
          context,
          l10n.rsChecking,
          () => service.inspect(file, password: password),
        );
      } on BackupException catch (e) {
        if (!mounted) return;
        final needsPassword =
            e.problem == BackupProblem.passwordRequired ||
            e.problem == BackupProblem.wrongPassword;
        if (!needsPassword) {
          await showMessage(
            context,
            l10n.bkRestore,
            backupProblemText(l10n, e.problem),
          );
          return;
        }
        error = e.problem == BackupProblem.wrongPassword
            ? l10n.bkErrWrongPassword
            : null;
        password = await askPassword(
          context,
          title: l10n.rsEnterPassword,
          error: error,
        );
        if (password == null || !mounted) return;
      }
    }
    if (!mounted) return;

    final confirmed = await _confirmPreview(preview);
    if (confirmed != true || !mounted) {
      await service.discard(preview);
      return;
    }
    try {
      await runWithProgress(context, l10n.rsWorking, () async {
        await service.apply(preview!);
      });
      if (!mounted) return;
      await showMessage(context, l10n.bkRestore, l10n.rsDone);
    } on BackupException catch (e) {
      if (!mounted) return;
      await showMessage(
        context,
        l10n.bkRestore,
        backupProblemText(l10n, e.problem),
      );
    } finally {
      await service.discard(preview);
    }
  }

  Future<bool?> _confirmPreview(RestorePreview preview) {
    final l10n = AppLocalizations.of(context);
    final language = ref.read(appLanguageProvider);
    final numerals =
        ref.read(numeralStyleProvider).value ?? NumeralStyle.bangla;
    String date(DateTime d) => formatDate(
      LocalDate.fromDateTime(d.toLocal()),
      language: language,
      numerals: numerals,
    );
    final m = preview.manifest;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rsPreviewTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.rsPreviewDate(date(m.createdAt))),
            Text(l10n.rsPreviewStudents(formatCount(m.students, numerals))),
            Text(l10n.rsPreviewPayments(formatCount(m.payments, numerals))),
            Text(
              preview.latestPaymentOn == null
                  ? l10n.rsPreviewNoPayments
                  : l10n.rsPreviewLatest(
                      formatDate(
                        LocalDate.parse(preview.latestPaymentOn!),
                        language: language,
                        numerals: numerals,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.rsWarn,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.rsConfirm),
          ),
        ],
      ),
    );
  }

  /// Two confirmations, the second by typing a word, then the reset.
  Future<void> _deleteAll() async {
    final l10n = AppLocalizations.of(context);
    final first = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rstFirstTitle),
        content: Text(l10n.rstFirstBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.rstContinue),
          ),
        ],
      ),
    );
    if (first != true || !mounted) return;
    final second = await showDialog<bool>(
      context: context,
      builder: (_) => const _TypeToConfirmDialog(),
    );
    if (second != true || !mounted) return;
    final service = await ref.read(restoreServiceProvider.future);
    if (!mounted) return;
    try {
      await runWithProgress(context, l10n.rstWorking, service.resetToEmpty);
      if (!mounted) return;
      await showMessage(context, l10n.rstTitle, l10n.rstDone);
    } on BackupException catch (e) {
      if (!mounted) return;
      await showMessage(
        context,
        l10n.rstTitle,
        backupProblemText(l10n, e.problem),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final last = ref.watchSetting(SettingKeys.lastBackupAt);
    final days = ref.watchSetting(SettingKeys.backupReminderDays);

    String when(DateTime t) {
      final local = t.toLocal();
      final time =
          '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
      return '${formatDate(LocalDate.fromDateTime(local), language: language, numerals: numerals)}, ${applyNumerals(time, numerals)}';
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bkTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.bkPrivacy, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
          Text(
            last == null ? l10n.bkNever : l10n.bkLast(when(last)),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.bkEncrypt),
            subtitle: Text(l10n.bkEncryptHint),
            value: _protect,
            onChanged: (v) => setState(() => _protect = v),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.backup_outlined),
            onPressed: _backup,
            label: Text(l10n.bkNow),
          ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.restore),
            title: Text(l10n.bkRestore),
            subtitle: Text(l10n.bkRestoreHint),
            onTap: _restore,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(l10n.bkReminderEvery),
            trailing: Text(
              l10n.bkReminderDays(formatCount(days, numerals)),
              style: theme.textTheme.titleSmall,
            ),
            onTap: () async {
              final picked = await showDialog<int>(
                context: context,
                builder: (context) => SimpleDialog(
                  children: [
                    for (final d in const [7, 14, 30, 60])
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, d),
                        child: Text(
                          l10n.bkReminderDays(formatCount(d, numerals)),
                        ),
                      ),
                  ],
                ),
              );
              if (picked != null) {
                await writeSetting(ref, SettingKeys.backupReminderDays, picked);
              }
            },
          ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text(
              l10n.rstTitle,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: Text(l10n.rstHint),
            onTap: _deleteAll,
          ),
        ],
      ),
    );
  }
}

/// The second confirmation: the delete button stays off until the word is
/// typed, so it cannot be hit by accident.
class _TypeToConfirmDialog extends StatefulWidget {
  const _TypeToConfirmDialog();

  @override
  State<_TypeToConfirmDialog> createState() => _TypeToConfirmDialogState();
}

class _TypeToConfirmDialogState extends State<_TypeToConfirmDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final word = l10n.rstWord;
    return AlertDialog(
      title: Text(l10n.rstSecondTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.rstSecondBody(word)),
          TextField(controller: _controller, autofocus: true),
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
          ),
          onPressed: _controller.text.trim() == word
              ? () => Navigator.pop(context, true)
              : null,
          child: Text(l10n.rstDelete),
        ),
      ],
    );
  }
}
