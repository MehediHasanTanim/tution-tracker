/// Why a backup could not be read or restored. Each has its own message for
/// the tutor, so none of these is a bare "something went wrong".
enum BackupProblem {
  /// Not a Tuition Khata backup at all.
  notABackup,

  /// A backup, but damaged: the zip is broken or a file is missing.
  damaged,

  /// Made by a newer app version than this one.
  newerVersion,

  /// A file inside no longer matches the checksum recorded when it was made.
  checksumMismatch,

  /// The database inside failed SQLite's own integrity check.
  integrityFailed,

  /// Password-protected and none was given.
  passwordRequired,

  /// Password-protected and the password (or the file) is wrong.
  wrongPassword,

  /// The restore failed part-way and the previous data was put back.
  restoreFailedRolledBack,

  /// The restore failed and the previous data could not be put back. The
  /// safety copy is still on the phone.
  restoreFailedNoRollback,
}

class BackupException implements Exception {
  const BackupException(this.problem, [this.detail]);

  final BackupProblem problem;

  /// For logs only. Never shown to the tutor.
  final String? detail;

  @override
  String toString() => 'BackupException(${problem.name}, $detail)';
}
