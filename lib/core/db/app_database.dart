import 'package:drift/drift.dart';
import 'package:tution_tracker/core/db/migrations.dart';

part 'app_database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump for every schema change and add a step to [appMigrationSteps]
  /// (design 6.4).
  static const currentSchemaVersion = 1;

  @override
  int get schemaVersion => currentSchemaVersion;

  /// Overridable so tests can exercise the upgrade path with dummy steps.
  List<MigrationStep> get migrationSteps => appMigrationSteps;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) => runMigrationSteps(
      migrationSteps,
      from: from,
      to: to,
      run: (step) => step.run(m, this),
    ),
    beforeOpen: (details) async {
      // Must run outside a transaction, so it lives here and not in onCreate.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
