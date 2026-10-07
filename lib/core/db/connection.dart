import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tution_tracker/core/db/app_database.dart';

const databaseFileName = 'tution_tracker.sqlite';

/// Opens the on-device database in a background isolate so queries never
/// block the UI thread. WAL gives crash safety and concurrent reads.
Future<AppDatabase> openAppDatabase({File? file}) async {
  final dbFile =
      file ??
      File(
        p.join(
          (await getApplicationDocumentsDirectory()).path,
          databaseFileName,
        ),
      );
  final executor = NativeDatabase.createInBackground(
    dbFile,
    setup: (rawDb) {
      rawDb.execute('PRAGMA journal_mode = WAL');
      rawDb.execute('PRAGMA synchronous = NORMAL');
    },
  );
  return AppDatabase(executor);
}

/// In-memory database for tests.
AppDatabase openInMemoryDatabase() => AppDatabase(NativeDatabase.memory());

/// Re-exported so callers need not import drift just for this.
typedef DatabaseConnection = QueryExecutor;
