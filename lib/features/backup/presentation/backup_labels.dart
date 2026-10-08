import 'package:tution_tracker/features/backup/domain/backup_exception.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// What to tell the tutor for each way a backup or restore can fail.
String backupProblemText(AppLocalizations l10n, BackupProblem problem) =>
    switch (problem) {
      BackupProblem.notABackup => l10n.bkErrNotABackup,
      BackupProblem.damaged => l10n.bkErrDamaged,
      BackupProblem.newerVersion => l10n.bkErrNewer,
      BackupProblem.checksumMismatch => l10n.bkErrChecksum,
      BackupProblem.integrityFailed => l10n.bkErrIntegrity,
      BackupProblem.passwordRequired => l10n.bkErrPasswordRequired,
      BackupProblem.wrongPassword => l10n.bkErrWrongPassword,
      BackupProblem.restoreFailedRolledBack => l10n.bkErrRolledBack,
      BackupProblem.restoreFailedNoRollback => l10n.bkErrNoRollback,
    };
