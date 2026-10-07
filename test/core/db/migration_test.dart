import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/db/migration_snapshot.dart';
import 'package:tution_tracker/core/db/migrations.dart';

import '../../generated_migrations/schema.dart';
import '../../support/db_fixtures.dart';

/// A stand-in for a future schema version, built on the real schema.
class _DummyV2Database extends AppDatabase {
  _DummyV2Database(super.executor, this.steps);

  final List<MigrationStep> steps;

  @override
  int get schemaVersion => 2;

  @override
  List<MigrationStep> get migrationSteps => steps;
}

void main() {
  late Directory dir;
  late File dbFile;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('tk_migration_');
    dbFile = File(p.join(dir.path, 'app.sqlite'));
  });

  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> createV1WithStudent() async {
    final db = await openDatabaseFile(dbFile);
    await insertStudent(db, 's1', name: 'Karim');
    await db.close();
  }

  group('runMigrationSteps', () {
    test('runs steps in version order within (from, to]', () async {
      final ran = <int>[];
      MigrationStep step(int v) =>
          MigrationStep(v, (m, db) async => ran.add(v));
      await runMigrationSteps(
        [step(3), step(2), step(4)],
        from: 1,
        to: 3,
        run: (s) async => ran.add(s.toVersion),
      );
      expect(ran, [2, 3]);
    });

    test('fails loudly when a step is missing', () async {
      await expectLater(
        runMigrationSteps(
          [MigrationStep(3, (m, db) async {})],
          from: 1,
          to: 3,
          run: (s) async {},
        ),
        throwsStateError,
      );
    });

    test('does nothing when already at the target version', () async {
      await runMigrationSteps(
        const [],
        from: 2,
        to: 2,
        run: (s) async => fail('should not run'),
      );
    });
  });

  group('schema verification', () {
    test('the current schema matches the committed v1 export', () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final connection = await verifier.startAt(1);
      final db = AppDatabase(connection);
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, AppDatabase.currentSchemaVersion);
    });
  });

  group('snapshot before migration', () {
    test('is not taken for a brand-new database', () async {
      final snapshot = await MigrationSnapshot.takeIfNeeded(
        dbFile,
        targetVersion: 2,
      );
      expect(snapshot, isNull);
      expect(dir.listSync(), isEmpty);
    });

    test('is not taken when the database is already current', () async {
      await createV1WithStudent();
      final snapshot = await MigrationSnapshot.takeIfNeeded(
        dbFile,
        targetVersion: 1,
      );
      expect(snapshot, isNull);
    });

    test(
      'v1 to v2 upgrade snapshots first, migrates, keeps data, then discards',
      () async {
        await createV1WithStudent();

        var snapshotExistedDuringMigration = false;
        final steps = [
          MigrationStep(2, (m, db) async {
            snapshotExistedDuringMigration = File(
              '${dbFile.path}.pre-migration-v1.bak',
            ).existsSync();
            await db.customStatement(
              'ALTER TABLE students ADD COLUMN nickname TEXT',
            );
          }),
        ];

        final db = await openDatabaseFile(
          dbFile,
          targetVersion: 2,
          create: (e) => _DummyV2Database(e, steps),
        );
        addTearDown(db.close);

        expect(snapshotExistedDuringMigration, isTrue);

        final version = await db
            .customSelect('PRAGMA user_version')
            .getSingle();
        expect(version.data.values.single, 2);

        final row = await db
            .customSelect('SELECT name, nickname FROM students')
            .getSingle();
        expect(row.read<String>('name'), 'Karim');
        expect(row.read<String?>('nickname'), isNull);

        // Successful launch: the snapshot is removed.
        expect(
          File('${dbFile.path}.pre-migration-v1.bak').existsSync(),
          isFalse,
        );
      },
    );

    test('a failing migration restores the original database', () async {
      await createV1WithStudent();

      final steps = [
        MigrationStep(2, (m, db) async {
          await db.customStatement(
            'ALTER TABLE students ADD COLUMN nickname TEXT',
          );
          throw StateError('boom');
        }),
      ];

      await expectLater(
        openDatabaseFile(
          dbFile,
          targetVersion: 2,
          create: (e) => _DummyV2Database(e, steps),
        ),
        // Drift wraps errors thrown inside a migration, so match on the message.
        throwsA(
          isA<Object>().having(
            (e) => e.toString(),
            'message',
            contains('boom'),
          ),
        ),
      );

      // Reopen as plain v1: data intact, no half-applied column.
      final db = await openDatabaseFile(dbFile);
      addTearDown(db.close);
      final row = await db.customSelect('SELECT * FROM students').getSingle();
      expect(row.read<String>('name'), 'Karim');
      expect(row.data.containsKey('nickname'), isFalse);
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 1);
    });
  });

  test('an in-memory database works as the test harness', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await insertStudent(db, 's1');
    expect(await db.select(db.students).get(), hasLength(1));
    expect(db.migrationSteps, isEmpty);
  });
}
