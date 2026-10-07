import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/migration_snapshot.dart';

const databaseFileName = 'tution_tracker.sqlite';

/// Opens the on-device database in a background isolate so queries never
/// block the UI thread. WAL gives crash safety and concurrent reads.
///
/// If the file needs a schema upgrade, a snapshot is taken first. It is
/// deleted once the upgraded database opens, and restored if that fails.
Future<AppDatabase> openAppDatabase({File? file}) async {
  final dbFile =
      file ??
      File(
        p.join(
          (await getApplicationDocumentsDirectory()).path,
          databaseFileName,
        ),
      );
  return openDatabaseFile(dbFile);
}

/// [openAppDatabase] for an explicit file; split out so it is testable.
Future<AppDatabase> openDatabaseFile(
  File dbFile, {
  AppDatabase Function(QueryExecutor executor)? create,
  int targetVersion = AppDatabase.currentSchemaVersion,
}) async {
  final snapshot = await MigrationSnapshot.takeIfNeeded(
    dbFile,
    targetVersion: targetVersion,
  );
  final executor = NativeDatabase.createInBackground(
    dbFile,
    setup: (rawDb) {
      rawDb.execute('PRAGMA journal_mode = WAL');
      rawDb.execute('PRAGMA synchronous = NORMAL');
    },
  );
  final db = (create ?? AppDatabase.new)(executor);
  try {
    // Forces the connection open, which runs any pending migration.
    await db.customSelect('SELECT 1').get();
  } catch (_) {
    await db.close();
    await snapshot?.restore();
    rethrow;
  }
  await snapshot?.discard();
  return db;
}

/// In-memory database for tests.
AppDatabase openInMemoryDatabase() => AppDatabase(NativeDatabase.memory());

/// Re-exported so callers need not import drift just for this.
typedef DatabaseConnection = QueryExecutor;
