import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump for every schema change and add a step to [migration] (design 6.4).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      // Must run outside a transaction, so it lives here and not in onCreate.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
