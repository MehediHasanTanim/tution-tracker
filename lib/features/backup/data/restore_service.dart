import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/backup/data/backup_archive.dart';
import 'package:tution_tracker/features/backup/data/database_swapper.dart';
import 'package:tution_tracker/features/backup/domain/backup_exception.dart';
import 'package:tution_tracker/features/backup/domain/backup_manifest.dart';
import 'package:tution_tracker/features/students/data/photo_store.dart';

/// What the tutor is shown before agreeing to replace their data.
class RestorePreview {
  const RestorePreview({
    required this.manifest,
    required this.latestPaymentOn,
    required this.inspected,
    required this.workDir,
  });

  final BackupManifest manifest;
  final String? latestPaymentOn;
  final InspectedBackup inspected;

  /// Where the backup was unpacked; removed by [RestoreService.discard].
  final Directory workDir;
}

/// The steps of a restore, in order. Tests inject a failure at one of them to
/// prove the rollback works.
enum RestoreStage { safetyCopy, closeDatabase, replaceFiles, reopen, verify }

/// Restores a backup over the live data (design 10.3).
///
/// Restore is the most dangerous thing the app does, so the order is strict:
/// make a safety copy of everything first; swap; check the result; and if
/// anything at all goes wrong, put the safety copy back.
class RestoreService {
  RestoreService({
    required this.swapper,
    required this.appDir,
    required this.workRoot,
    int? schemaVersion,
    DateTime Function()? now,
    this.beforeStage,
    this.afterRestore,
    Future<InspectedBackup> Function(InspectRequest request)? inspector,
  }) : schemaVersion = schemaVersion ?? AppDatabase.currentSchemaVersion,
       _now = now ?? DateTime.now,
       _inspect = inspector ?? ((r) => Isolate.run(() => inspectBackupFile(r)));

  final DatabaseSwapper swapper;

  /// Holds the database file and the `photos` folder.
  final Directory appDir;

  /// Scratch space for unpacked backups.
  final Directory workRoot;
  final int schemaVersion;
  final DateTime Function() _now;

  /// Called before each stage; a test throws from here to simulate failure.
  final FutureOr<void> Function(RestoreStage stage)? beforeStage;

  /// Runs once the new data is in place and verified, e.g. to re-plan
  /// reminders. A failure here does not undo the restore.
  final FutureOr<void> Function(AppDatabase db)? afterRestore;
  final Future<InspectedBackup> Function(InspectRequest request) _inspect;

  Directory get _photos => Directory(p.join(appDir.path, PhotoStore.folder));

  /// Unpacks and validates [backup]. Throws [BackupException].
  Future<RestorePreview> inspect(File backup, {String? password}) async {
    final work = Directory(
      p.join(workRoot.path, 'restore_${_now().microsecondsSinceEpoch}'),
    )..createSync(recursive: true);
    try {
      final inspected = await _inspect(
        InspectRequest(
          backupPath: backup.path,
          workDir: work.path,
          currentSchemaVersion: schemaVersion,
          password: password,
        ),
      );
      return RestorePreview(
        manifest: inspected.manifest,
        latestPaymentOn: inspected.latestPaymentOn,
        inspected: inspected,
        workDir: work,
      );
    } on Object {
      await _delete(work);
      rethrow;
    }
  }

  /// Throws the unpacked backup away.
  Future<void> discard(RestorePreview preview) => _delete(preview.workDir);

  /// Replaces the live data with [preview]. On any failure the previous data
  /// is put back and [BackupException] says whether that worked.
  Future<void> apply(RestorePreview preview) async {
    final stamp = _now().millisecondsSinceEpoch;
    final safetyDb = File(p.join(appDir.path, 'pre_restore_$stamp.db'));
    final safetyPhotos = Directory(p.join(appDir.path, 'photos.pre_restore'));

    // What has been changed so far, so a rollback undoes exactly that.
    var closed = false;
    var photosMoved = false;
    var photosCreated = false;
    try {
      // 1. Safety copy of the current database, made while it is open.
      await _stage(RestoreStage.safetyCopy);
      final live = await swapper.current();
      if (safetyDb.existsSync()) await safetyDb.delete();
      await live.customStatement(
        "VACUUM INTO '${safetyDb.path.replaceAll("'", "''")}'",
      );

      // 2. Close it, then move the photos aside and put the new files in.
      await _stage(RestoreStage.closeDatabase);
      await swapper.close();
      closed = true;

      await _stage(RestoreStage.replaceFiles);
      await _delete(safetyPhotos);
      if (_photos.existsSync()) {
        await _photos.rename(safetyPhotos.path);
        photosMoved = true;
      } else {
        photosCreated = true;
      }
      await _placeDatabase(File(preview.inspected.databasePath));
      await _placePhotos(preview.inspected.photoPaths);

      // 3. Open the new database (which migrates an older one) and check it.
      await _stage(RestoreStage.reopen);
      final db = await swapper.reopen();
      await _stage(RestoreStage.verify);
      await _verify(db, preview.manifest);
      await _keepReceiptNumbersGoingUp(db);
      await _delete(safetyPhotos);
      await _removeOldSafetyCopies(keep: safetyDb);
      try {
        await afterRestore?.call(db);
      } on Object {
        // The data is restored; dues and reminders catch up on next start.
      }
    } on Object catch (e) {
      await _rollback(
        safetyDb: safetyDb,
        safetyPhotos: safetyPhotos,
        databaseClosed: closed,
        undoPhotos: photosMoved || photosCreated,
        photosMoved: photosMoved,
        cause: e,
      );
    }
  }

  Future<void> _stage(RestoreStage stage) async => beforeStage?.call(stage);

  Future<void> _placeDatabase(File restored) async {
    final target = swapper.databaseFile;
    for (final suffix in ['-wal', '-shm', '-journal']) {
      final extra = File('${target.path}$suffix');
      if (extra.existsSync()) await extra.delete();
    }
    // Copied beside the target and renamed, so the live path never holds a
    // half-written file.
    final staged = File('${target.path}.restoring');
    await restored.copy(staged.path);
    await staged.rename(target.path);
  }

  Future<void> _placePhotos(Map<String, String> photos) async {
    for (final entry in photos.entries) {
      final dest = File(p.joinAll([appDir.path, ...p.posix.split(entry.key)]));
      await dest.parent.create(recursive: true);
      await File(entry.value).copy(dest.path);
    }
  }

  /// The restored database must open, pass SQLite's check, and hold what the
  /// manifest says it should.
  Future<void> _verify(AppDatabase db, BackupManifest manifest) async {
    final check = await db.customSelect('PRAGMA integrity_check').get();
    if (check.length != 1 || check.first.data.values.first != 'ok') {
      throw const BackupException(BackupProblem.integrityFailed, 'after swap');
    }
    Future<int> count(String sql) async =>
        (await db.customSelect(sql).getSingle()).data.values.first! as int;
    final students = await count('SELECT COUNT(*) FROM students');
    final payments = await count(
      'SELECT COUNT(*) FROM payments WHERE deleted_at IS NULL',
    );
    if (students != manifest.students || payments != manifest.payments) {
      throw const BackupException(BackupProblem.damaged, 'counts after swap');
    }
  }

  /// Receipt numbers never go backwards, even if the backup's counter was
  /// behind its highest receipt (design 10.5).
  Future<void> _keepReceiptNumbersGoingUp(AppDatabase db) async {
    final row = await db
        .customSelect('SELECT COALESCE(MAX(receipt_no), 0) AS m FROM payments')
        .getSingle();
    await SettingsStore(db).ensureNextReceiptAtLeast(row.read<int>('m') + 1);
  }

  /// Undoes what [apply] had done, then throws [BackupException]: with
  /// `restoreFailedRolledBack` when the old data is back (or was never
  /// touched), `restoreFailedNoRollback` when it could not be put back.
  Future<void> _rollback({
    required File safetyDb,
    required Directory safetyPhotos,
    required bool databaseClosed,
    required bool undoPhotos,
    required bool photosMoved,
    required Object cause,
  }) async {
    try {
      if (databaseClosed) {
        // Release whatever is open; a failed reopen leaves nothing to close.
        try {
          await swapper.close();
        } on Object {
          // Already closed.
        }
        await _placeDatabase(safetyDb);
      }
      if (undoPhotos) {
        await _delete(_photos);
        if (photosMoved) await safetyPhotos.rename(_photos.path);
      }
      if (databaseClosed) await swapper.reopen();
    } on Object catch (e) {
      throw BackupException(
        BackupProblem.restoreFailedNoRollback,
        'restore: $cause; rollback: $e',
      );
    }
    throw BackupException(
      BackupProblem.restoreFailedRolledBack,
      cause is BackupException ? cause.problem.name : '$cause',
    );
  }

  /// Keeps only the newest safety copy, so they do not pile up.
  Future<void> _removeOldSafetyCopies({required File keep}) async {
    for (final f in appDir.listSync()) {
      if (f is File &&
          p.basename(f.path).startsWith('pre_restore_') &&
          f.path != keep.path) {
        await f.delete();
      }
    }
  }

  Future<void> _delete(Directory dir) async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  }
}
