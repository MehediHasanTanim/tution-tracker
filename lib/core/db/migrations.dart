import 'package:drift/drift.dart';
import 'package:tution_tracker/core/db/app_database.dart';

typedef MigrationAction = Future<void> Function(Migrator m, AppDatabase db);

/// One forward-only schema step that brings the database to [toVersion].
class MigrationStep {
  const MigrationStep(this.toVersion, this.run);

  final int toVersion;
  final MigrationAction run;
}

/// Production steps, ordered by version. Add one entry per `schemaVersion`
/// bump (design section 6.4), then:
///   1. `dart run drift_dev schema dump lib/core/db/app_database.dart drift_schemas`
///   2. `dart run drift_dev schema generate drift_schemas test/generated_migrations`
///   3. add an upgrade test from the previous version's fixture.
const List<MigrationStep> appMigrationSteps = [];

/// Runs every step in `(from, to]` in order. Throws [StateError] if a version
/// in that range has no step, so a missing migration fails loudly instead of
/// leaving a half-upgraded database.
Future<void> runMigrationSteps(
  List<MigrationStep> steps, {
  required int from,
  required int to,
  required Future<void> Function(MigrationStep step) run,
}) async {
  final byVersion = {for (final s in steps) s.toVersion: s};
  for (var version = from + 1; version <= to; version++) {
    final step = byVersion[version];
    if (step == null) {
      throw StateError('No migration step to schema version $version');
    }
    await run(step);
  }
}
