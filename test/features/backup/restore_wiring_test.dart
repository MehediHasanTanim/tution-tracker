import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/features/attendance/data/attendance_providers.dart';
import 'package:tution_tracker/features/backup/data/backup_providers.dart';

import '../../support/backup_fixture.dart';

/// The real Riverpod wiring: a restore must swap the database under live
/// providers without any of them touching a half-replaced file.
void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('tk_wiring_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  ProviderContainer containerFor(Directory phoneDir) {
    final app = Directory(p.join(phoneDir.path, 'app'))
      ..createSync(recursive: true);
    final work = Directory(p.join(phoneDir.path, 'work'))
      ..createSync(recursive: true);
    final file = File(p.join(app.path, 'data.sqlite'));
    final container = ProviderContainer(
      overrides: [
        databaseOpenerProvider.overrideWithValue(() => openDatabaseFile(file)),
        databaseFileProvider.overrideWith((ref) async => file),
        appDirectoryProvider.overrideWith((ref) async => app),
        backupWorkDirProvider.overrideWith((ref) async => work),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('restores under live providers and they see the new data', () async {
    // A backup made on one phone.
    final source = Phone(Directory(p.join(tmp.path, 'source'))..createSync());
    await source.seed(students: 4, withPhotos: 2);
    final backup = (await (await source.backupService()).createBackup()).file;
    final expected = await source.dump();
    await source.close();

    // Another phone, in use: its own data, with a screen watching students.
    final container = containerFor(
      Directory(p.join(tmp.path, 'target'))..createSync(),
    );
    final db = await container.read(databaseProvider.future);
    await db.customStatement(
      'INSERT INTO students (id, name, joined_on, monthly_fee, created_at, updated_at) '
      "VALUES ('old', 'Old', '2026-01-01', 1, 1, 1)",
    );
    final seen = <int>[];
    container.listen(
      studentChoicesProvider(''),
      (_, next) => next.whenData((l) => seen.add(l.length)),
      fireImmediately: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(seen.last, 1);

    final restore = await container.read(restoreServiceProvider.future);
    final preview = await restore.inspect(backup);
    await restore.apply(preview);
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // The watching provider moved to the restored data.
    expect(seen.last, 4);
    // And the database every provider now uses holds exactly the backup.
    final fresh = await container.read(databaseProvider.future);
    expect(identical(fresh, db), isFalse);
    final students = await fresh
        .customSelect('SELECT id FROM students ORDER BY id')
        .get();
    expect(students.map((r) => r.read<String>('id')), [
      for (final r in expected['students']!) r['id'],
    ]);
  });

  test('a rolled-back restore leaves live providers on the old data', () async {
    final source = Phone(Directory(p.join(tmp.path, 'source'))..createSync());
    await source.seed(students: 4);
    final backup = (await (await source.backupService()).createBackup()).file;
    await source.close();

    final container = containerFor(
      Directory(p.join(tmp.path, 'target'))..createSync(),
    );
    final db = await container.read(databaseProvider.future);
    await db.customStatement(
      'INSERT INTO students (id, name, joined_on, monthly_fee, created_at, updated_at) '
      "VALUES ('old', 'Old', '2026-01-01', 1, 1, 1)",
    );

    // A backup whose manifest will not match after the swap cannot be built
    // through the public API, so force the failure by closing the work dir.
    final restore = await container.read(restoreServiceProvider.future);
    final preview = await restore.inspect(backup);
    // Remove the unpacked database: the swap step cannot find it.
    File(preview.inspected.databasePath).deleteSync();
    await expectLater(restore.apply(preview), throwsA(isA<Exception>()));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final again = await container.read(databaseProvider.future);
    final rows = await again.customSelect('SELECT id FROM students').get();
    expect(rows.map((r) => r.read<String>('id')), ['old']);
  });
}
