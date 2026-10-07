import 'dart:io';

import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';

/// Lets a restore replace the database file underneath the running app.
///
/// While the file is closed nothing may open it. [close] releases it;
/// [reopen] opens the file again (running any schema migration) and makes
/// that connection the app's database.
abstract interface class DatabaseSwapper {
  /// The database file inside the app's private folder.
  File get databaseFile;

  /// The open database, for taking a safety copy before anything changes.
  Future<AppDatabase> current();

  /// Closes the database and blocks reopening until [reopen].
  Future<void> close();

  /// Opens the file again. Throws if it cannot be opened or migrated.
  Future<AppDatabase> reopen();
}

/// A swapper that owns its database directly. Used by tests and by anything
/// that is not wired through Riverpod.
class FileDatabaseSwapper implements DatabaseSwapper {
  FileDatabaseSwapper(this.databaseFile);

  @override
  final File databaseFile;

  AppDatabase? _db;

  /// Opens the database the first time.
  Future<AppDatabase> open() async =>
      _db ??= await openDatabaseFile(databaseFile);

  @override
  Future<AppDatabase> current() => open();

  @override
  Future<void> close() async {
    final db = _db;
    _db = null;
    await db?.close();
  }

  @override
  Future<AppDatabase> reopen() async =>
      _db = await openDatabaseFile(databaseFile);
}
