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
Future<AppDatabase> openAppDatabase({File? file}) async =>
    openDatabaseFile(file ?? await defaultDatabaseFile());

/// Where the database lives on the device: the app's private documents
/// folder, next to the `photos` folder.
Future<File> defaultDatabaseFile() async => File(
  p.join((await getApplicationDocumentsDirectory()).path, databaseFileName),
);

/// [openAppDatabase] for an explicit file; split out so it is testable.
Future<AppDatabase> openDatabaseFile(
  File dbFile, {
  AppDatabase Function(QueryExecutor executor)? create,
  int targetVersion = AppDatabase.currentSchemaVersion,
}) async {
  // A restore closes the database and opens the same file again, which
  // Drift would otherwise warn about as a second instance.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
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

final _closing = Expando<Future<void>>('closing database');

/// Closes [db] once, however many callers ask and whenever they do.
///
/// A restore closes the database itself while Riverpod also closes it as the
/// provider is dropped. Drift's `close` is not safe to run twice at once, and
/// can trip over live queries that are still being cancelled, so the close is
/// shared and retried briefly.
Future<void> closeDatabase(AppDatabase db) => _closing[db] ??= _close(db);

Future<void> _close(AppDatabase db) async {
  for (var attempt = 0; ; attempt++) {
    try {
      await db.close();
      return;
    } on ConcurrentModificationError {
      if (attempt >= 4) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }
}

/// In-memory database for tests.
AppDatabase openInMemoryDatabase() => AppDatabase(NativeDatabase.memory());

/// Re-exported so callers need not import drift just for this.
typedef DatabaseConnection = QueryExecutor;
