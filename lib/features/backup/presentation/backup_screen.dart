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
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
import 'package:tution_tracker/core/ui/organic_widgets.dart';
import 'package:tution_tracker/features/backup/data/backup_providers.dart';
import 'package:tution_tracker/features/backup/data/backup_status_provider.dart';
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
    return showBlockSheet<bool>(
      context,
      builder: (context) {
        final o = Organic.of(context);
        return BlockStack(
          children: [
            BlockSubheading(l10n.rsPreviewTitle),
            BlockBanner(
              title: l10n.rsReplaceTitle,
              text: l10n.rsWarn,
              background: o.accentStrong,
              foreground: Colors.white,
            ),
            OrganicPanel(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in [
                    l10n.rsPreviewDate(date(m.createdAt)),
                    l10n.rsPreviewStudents(formatCount(m.students, numerals)),
                    l10n.rsPreviewPayments(formatCount(m.payments, numerals)),
                    if (preview.latestPaymentOn == null)
                      l10n.rsPreviewNoPayments
                    else
                      l10n.rsPreviewLatest(
                        formatDate(
                          LocalDate.parse(preview.latestPaymentOn!),
                          language: language,
                          numerals: numerals,
                        ),
                      ),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(line, style: const TextStyle(fontSize: 15)),
                    ),
                ],
              ),
            ),
            BlockButton(
              l10n.rsConfirm,
              kind: BlockButtonKind.danger,
              onPressed: () => Navigator.pop(context, true),
            ),
            BlockButton(
              l10n.actionCancel,
              kind: BlockButtonKind.ghost,
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        );
      },
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
      builder: (_) => const TypeToConfirmDialog(),
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

    final o = Organic.of(context);
    final status = ref.watch(backupStatusProvider);
    final warn = last == null || status.show;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bkTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          BlockStack(
            children: [
              BlockBanner(
                title: last == null ? l10n.bkNever : l10n.bkLast(when(last)),
                text: l10n.bkPrivacy,
                background: warn ? o.accentSoft : o.sageSoft,
                foreground: warn ? o.onAccentSoft : o.onSageSoft,
              ),
              BlockToggle(
                label: l10n.bkEncrypt,
                subtitle: l10n.bkEncryptHint,
                value: _protect,
                onChanged: (v) => setState(() => _protect = v),
              ),
              BlockButton(
                l10n.bkNow,
                icon: Icons.backup_rounded,
                onPressed: _backup,
              ),
              BlockText(l10n.bkSavedHint),
              BlockSubheading(l10n.bkRestoreSection),
              BlockItem(
                leading: const BlockIcon(Icons.description_rounded),
                title: l10n.bkRestore,
                subtitle: l10n.bkRestoreHint,
                chevron: true,
                onTap: _restore,
              ),
              BlockSubheading(l10n.bkReminderEvery),
              BlockChips<int>(
                options: [
                  for (final d in const [7, 14, 30, 60])
                    (d, l10n.bkReminderDays(formatCount(d, numerals))),
                ],
                isSelected: (d) => d == days,
                onTap: (d) =>
                    writeSetting(ref, SettingKeys.backupReminderDays, d),
              ),
              BlockSubheading(l10n.bkDangerZone),
              BlockText(l10n.rstHint),
              BlockButton(
                l10n.rstTitle,
                kind: BlockButtonKind.danger,
                onPressed: _deleteAll,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
