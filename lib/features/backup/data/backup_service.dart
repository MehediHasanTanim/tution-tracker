import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:tution_tracker/core/app_info.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/backup/data/backup_archive.dart';
import 'package:tution_tracker/features/backup/domain/backup_manifest.dart';

/// A finished backup file.
class BackupFile {
  const BackupFile(this.file, this.manifest);

  final File file;
  final BackupManifest manifest;
}

/// Makes `.tkbackup` files (design 10.2).
///
/// The database is copied with `VACUUM INTO`, which gives a consistent
/// snapshot without stopping the app. The heavy part (hashing, zipping and
/// optional encryption) runs in a background isolate.
class BackupService {
  BackupService(
    this._db,
    this._settings, {
    required this.appDir,
    required this.workDir,
    DateTime Function()? now,
    Future<BackupManifest> Function(BuildRequest request)? build,
  }) : _now = now ?? DateTime.now,
       _build = build ?? _buildInIsolate;

  final AppDatabase _db;
  final SettingsStore _settings;

  /// Where the database and the `photos` folder live.
  final Directory appDir;

  /// Scratch space for snapshots and finished backups.
  final Directory workDir;
  final DateTime Function() _now;
  final Future<BackupManifest> Function(BuildRequest request) _build;

  /// `backup_2026-10-06_1630.tkbackup`
  String fileNameFor(DateTime at) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'backup_${at.year}-${two(at.month)}-${two(at.day)}'
        '_${two(at.hour)}${two(at.minute)}.tkbackup';
  }

  /// Writes a backup into [workDir]. With a [password] the file is encrypted.
  Future<BackupFile> createBackup({String? password}) async {
    final now = _now();
    final scratch = Directory(
      p.join(workDir.path, 'backup_${now.microsecondsSinceEpoch}'),
    )..createSync(recursive: true);
    try {
      final snapshot = p.join(scratch.path, databaseEntry);
      await _db.customStatement(
        "VACUUM INTO '${snapshot.replaceAll("'", "''")}'",
      );

      final photos = <String, String>{};
      final rows = await _db
          .customSelect(
            'SELECT DISTINCT photo_path FROM students '
            'WHERE photo_path IS NOT NULL',
          )
          .get();
      for (final row in rows) {
        final relative = row.read<String>('photo_path');
        photos[relative] = p.joinAll([appDir.path, ...p.posix.split(relative)]);
      }

      final output = p.join(workDir.path, fileNameFor(now));
      final manifest = await _build(
        BuildRequest(
          snapshotPath: snapshot,
          photos: photos,
          outputPath: output,
          schemaVersion: AppDatabase.currentSchemaVersion,
          appVersion: appVersion,
          createdAt: now.toUtc(),
          password: password,
        ),
      );
      return BackupFile(File(output), manifest);
    } finally {
      unawaited(scratch.delete(recursive: true).catchError((_) => scratch));
    }
  }

  /// Notes that a backup was made, which stops the "back up" banner and
  /// reminder until the interval has passed again.
  Future<void> recordBackup() =>
      _settings.set(SettingKeys.lastBackupAt, _now());
}

/// See `_inspectInIsolate`: top-level so the isolate message stays small.
Future<BackupManifest> _buildInIsolate(BuildRequest request) =>
    Isolate.run(() => buildBackupFile(request));
