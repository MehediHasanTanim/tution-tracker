import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';

/// Holds the database closed while a restore swaps the file underneath it.
///
/// Anything that asks for the database in that time waits, so nothing can open
/// a half-replaced file. Background work (due generation, reminder planning)
/// runs through [run], so a restore can wait for it to finish before closing:
/// closing a database in the middle of a transaction can leave the close
/// hanging.
class DatabaseLock {
  Completer<void>? _locked;

  /// Set while a restore waits for running work: new work holds back, but
  /// the database can still be opened, since running work may need it.
  Completer<void>? _holdingRuns;
  Completer<void>? _drained;
  int _running = 0;

  bool get isLocked => _locked != null;

  Future<void> get whenUnlocked => _locked?.future ?? Future.value();

  /// Runs [work] once the database is available. A restore will not start
  /// closing the database until every such task has finished.
  Future<T> run<T>(Future<T> Function() work) async {
    await _holdingRuns?.future;
    await whenUnlocked;
    _running++;
    try {
      return await work();
    } finally {
      _running--;
      if (_running == 0) {
        _drained?.complete();
        _drained = null;
      }
    }
  }

  /// Blocks new work, then waits for the work already running.
  Future<void> lockAndDrain() async {
    _holdingRuns ??= Completer<void>();
    while (_running > 0) {
      _drained ??= Completer<void>();
      await _drained!.future;
    }
    // Only now keep the database itself from opening: work that was running
    // may have needed it to get this far.
    _locked ??= Completer<void>();
  }

  void unlock() {
    _locked?.complete();
    _locked = null;
    _holdingRuns?.complete();
    _holdingRuns = null;
  }
}

final databaseLockProvider = Provider<DatabaseLock>((ref) => DatabaseLock());

/// How the database is opened. Tests replace it to use a file in a temp
/// folder.
final databaseOpenerProvider = Provider<Future<AppDatabase> Function()>(
  (ref) =>
      () async => openAppDatabase(),
);

/// Where the database file is, so a restore can replace it.
final databaseFileProvider = FutureProvider<File>(
  (ref) => defaultDatabaseFile(),
);

/// Opened lazily on first read (design section 13: lazy DB init).
final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  await ref.read(databaseLockProvider).whenUnlocked;
  final db = await ref.read(databaseOpenerProvider)();
  ref.onDispose(() => unawaited(closeDatabase(db)));
  return db;
});
