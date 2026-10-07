import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/backup/data/backup_service.dart';
import 'package:tution_tracker/features/backup/data/database_swapper.dart';
import 'package:tution_tracker/features/backup/data/restore_service.dart';
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
import 'package:tution_tracker/features/reminders/data/reminder_providers.dart';

/// Swaps the app's database through Riverpod, so every provider and open
/// screen picks up the restored data.
class ProviderDatabaseSwapper implements DatabaseSwapper {
  ProviderDatabaseSwapper(this._ref, this.databaseFile);

  final Ref _ref;

  @override
  final File databaseFile;

  AppDatabase? _db;

  @override
  Future<AppDatabase> current() async {
    final db = await _ref.read(databaseProvider.future);
    _db = db;
    return db;
  }

  @override
  Future<void> close() async {
    final db = _db;
    _db = null;
    // Lock first so that nothing rebuilt by the invalidation can reopen the
    // file and no new background work starts; wait for what is running; then
    // drop the provider and close the connection.
    await _ref.read(databaseLockProvider).lockAndDrain();
    _ref.invalidate(databaseProvider);
    // Let the queries that were watching the old database cancel first.
    await Future<void>.delayed(Duration.zero);
    if (db != null) {
      // A close that never answers must not freeze the app for good. The
      // safety copy was already taken, so carrying on is safe.
      await closeDatabase(db)
          .timeout(const Duration(seconds: 8), onTimeout: () {});
    }
  }

  @override
  Future<AppDatabase> reopen() async {
    // Unlocking lets the rebuild that [close] queued (or a fresh one, if
    // nothing was watching) open the new file: exactly once.
    _ref.read(databaseLockProvider).unlock();
    final db = await _ref.read(databaseProvider.future);
    _db = db;
    return db;
  }
}

/// A folder for work files (finished backups, unpacked restores).
final backupWorkDirProvider = FutureProvider<Directory>((ref) async {
  final base = await getTemporaryDirectory();
  return Directory('${base.path}/backup')..createSync(recursive: true);
});

final appDirectoryProvider = FutureProvider<Directory>(
  (ref) => getApplicationDocumentsDirectory(),
);

final backupServiceProvider = FutureProvider<BackupService>((ref) async {
  return BackupService(
    await ref.watch(databaseProvider.future),
    await ref.watch(settingsStoreProvider.future),
    appDir: await ref.watch(appDirectoryProvider.future),
    workDir: await ref.watch(backupWorkDirProvider.future),
  );
});

/// Deliberately reads, never watches, the database: a restore replaces the
/// database mid-flight, and this service must outlive that.
final restoreServiceProvider = FutureProvider<RestoreService>((ref) async {
  return RestoreService(
    swapper: ProviderDatabaseSwapper(
      ref,
      await ref.read(databaseFileProvider.future),
    ),
    appDir: await ref.read(appDirectoryProvider.future),
    workRoot: await ref.read(backupWorkDirProvider.future),
    afterRestore: (db) async {
      // Dues for months since the backup, and reminders for the new data.
      final dues = await ref.read(dueServiceProvider.future);
      await dues.generateForAll();
      await ref.read(replanRemindersProvider)();
    },
  );
});
