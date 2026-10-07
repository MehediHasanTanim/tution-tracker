import 'dart:io';

import 'package:sqlite3/sqlite3.dart' as sqlite;

/// File-level safety copy taken before a schema migration (design 6.4).
///
/// Kept until the next successful launch: [discard] on success, [restore] if
/// opening or migrating fails.
class MigrationSnapshot {
  MigrationSnapshot._(this.file, this.original, this.fromVersion);

  /// The copy, e.g. `app.sqlite.pre-migration-v1.bak`.
  final File file;

  /// The live database file this snapshot protects.
  final File original;

  final int fromVersion;

  /// Copies [dbFile] aside when its stored schema version is older than
  /// [targetVersion]. Returns null for a missing or brand-new database, or one
  /// already at (or beyond) the target.
  static Future<MigrationSnapshot?> takeIfNeeded(
    File dbFile, {
    required int targetVersion,
  }) async {
    if (!dbFile.existsSync()) return null;

    final version = _readSchemaVersion(dbFile);
    if (version == 0 || version >= targetVersion) return null;

    final snapshot = File('${dbFile.path}.pre-migration-v$version.bak');
    await dbFile.copy(snapshot.path);
    return MigrationSnapshot._(snapshot, dbFile, version);
  }

  /// Drops the snapshot after a successful launch.
  Future<void> discard() async {
    if (file.existsSync()) await file.delete();
  }

  /// Puts the pre-migration database back, replacing the live file and any
  /// leftover WAL/SHM files from the failed attempt.
  Future<void> restore() async {
    for (final suffix in ['-wal', '-shm']) {
      final extra = File('${original.path}$suffix');
      if (extra.existsSync()) await extra.delete();
    }
    await file.copy(original.path);
  }

  /// Reads `PRAGMA user_version` (which Drift keeps equal to `schemaVersion`).
  /// The WAL is checkpointed first so the main file alone holds all data and
  /// a plain file copy is a complete snapshot.
  static int _readSchemaVersion(File dbFile) {
    final db = sqlite.sqlite3.open(dbFile.path);
    try {
      db.execute('PRAGMA wal_checkpoint(TRUNCATE)');
      return db.select('PRAGMA user_version').first.values.first! as int;
    } finally {
      db.close();
    }
  }
}
