import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/backup/data/database_swapper.dart';
import 'package:tution_tracker/features/backup/data/restore_service.dart';
import 'package:tution_tracker/features/backup/domain/backup_exception.dart';
import 'package:tution_tracker/features/backup/domain/backup_manifest.dart';

import '../../support/backup_fixture.dart';

Matcher _problem(BackupProblem problem) => throwsA(
  isA<BackupException>().having((e) => e.problem, 'problem', problem),
);

void main() {
  late Directory tmp;
  final phones = <Phone>[];

  Phone newPhone() {
    final dir = Directory(p.join(tmp.path, 'phone${phones.length}'))
      ..createSync();
    final phone = Phone(dir);
    phones.add(phone);
    return phone;
  }

  setUp(() => tmp = Directory.systemTemp.createTempSync('tk_backup_'));

  tearDown(() async {
    for (final phone in phones) {
      await phone.close();
    }
    phones.clear();
    tmp.deleteSync(recursive: true);
  });

  /// Rewrites one entry of a backup (keeping the manifest as it was).
  Future<File> tamper(
    File backup,
    String entry,
    List<int>? Function(List<int> old) change,
  ) async {
    final archive = ZipDecoder().decodeBytes(await backup.readAsBytes());
    final out = Archive();
    for (final f in archive) {
      final replacement = f.name == entry
          ? change(f.readBytes()!)
          : f.readBytes();
      if (replacement == null) continue;
      out.add(ArchiveFile.bytes(f.name, replacement));
    }
    final file = File(p.join(tmp.path, 'tampered_${entry.hashCode}.tkbackup'));
    await file.writeAsBytes(ZipEncoder().encode(out));
    return file;
  }

  group('export', () {
    test('writes a named .tkbackup with a manifest that matches', () async {
      final phone = newPhone();
      await phone.seed();
      final backup = await (await phone.backupService()).createBackup();

      expect(p.basename(backup.file.path), 'backup_2026-10-06_1630.tkbackup');
      final m = backup.manifest;
      expect(m.students, 3);
      expect(m.payments, 3);
      expect(m.sessions, 1);
      expect(m.schemaVersion, AppDatabase.currentSchemaVersion);
      expect(m.encrypted, isFalse);
      expect(m.photos.keys, ['photos/s0_1.jpg', 'photos/s1_1.jpg']);

      final zip = ZipDecoder().decodeBytes(await backup.file.readAsBytes());
      expect(zip.map((f) => f.name).toSet(), {
        'manifest.json',
        'data.db',
        'photos/s0_1.jpg',
        'photos/s1_1.jpg',
      });
      final db = zip.firstWhere((f) => f.name == 'data.db').readBytes()!;
      expect(sha256.convert(db).toString(), m.dbSha256);
    });

    test('a deleted photo file is skipped, not fatal', () async {
      final phone = newPhone();
      await phone.seed();
      phone.photo('photos/s1_1.jpg').deleteSync();
      final backup = await (await phone.backupService()).createBackup();
      expect(backup.manifest.photos.keys, ['photos/s0_1.jpg']);
    });

    test('a 500-student dataset exports with matching counts', () async {
      final phone = newPhone();
      await phone.seed(students: 500, withPhotos: 500);
      final clock = Stopwatch()..start();
      final backup = await (await phone.backupService()).createBackup();
      clock.stop();

      expect(backup.manifest.students, 500);
      expect(backup.manifest.payments, 500);
      expect(backup.manifest.photos, hasLength(500));
      expect(clock.elapsed, lessThan(const Duration(seconds: 20)));
    });

    test('recording a backup stores the time', () async {
      final phone = newPhone();
      await phone.seed();
      final service = await phone.backupService();
      expect(
        await (await phone.settings).get(SettingKeys.lastBackupAt),
        isNull,
      );
      await service.recordBackup();
      expect(
        await (await phone.settings).get(SettingKeys.lastBackupAt),
        phone.now,
      );
    });
  });

  group('validation', () {
    Future<File> good(Phone phone) async {
      await phone.seed();
      return (await (await phone.backupService()).createBackup()).file;
    }

    test('accepts a good backup and previews it', () async {
      final phone = newPhone();
      final file = await good(phone);
      final preview = await newPhone().restoreService().inspect(file);
      expect(preview.manifest.students, 3);
      expect(preview.manifest.payments, 3);
      expect(preview.latestPaymentOn, '2026-01-12');
      expect(preview.inspected.photoPaths, hasLength(2));
      await newPhone().restoreService().discard(preview);
    });

    test('rejects a file that is not a backup', () async {
      final junk = File(p.join(tmp.path, 'notes.txt'))
        ..writeAsStringSync('hello');
      await expectLater(
        newPhone().restoreService().inspect(junk),
        _problem(BackupProblem.notABackup),
      );
      // The scratch folder is cleaned up after a rejection.
      expect(newPhone().workDir.listSync(), isEmpty);
    });

    test('rejects a zip that is not ours', () async {
      final archive = Archive()..add(ArchiveFile.string('readme.txt', 'x'));
      final zip = File(p.join(tmp.path, 'other.zip'))
        ..writeAsBytesSync(ZipEncoder().encode(archive));
      await expectLater(
        newPhone().restoreService().inspect(zip),
        _problem(BackupProblem.notABackup),
      );
    });

    test('rejects a manifest with another format name', () async {
      final file = await good(newPhone());
      final bad = await tamper(
        file,
        'manifest.json',
        (old) =>
            String.fromCharCodes(old)
                .replaceAll('tuition-khata-backup', 'something-else')
                .codeUnits,
      );
      await expectLater(
        newPhone().restoreService().inspect(bad),
        _problem(BackupProblem.notABackup),
      );
    });

    test('rejects a truncated file', () async {
      final file = await good(newPhone());
      final bytes = await file.readAsBytes();
      final cut = File(p.join(tmp.path, 'cut.tkbackup'))
        ..writeAsBytesSync(bytes.sublist(0, bytes.length ~/ 2));
      await expectLater(
        newPhone().restoreService().inspect(cut),
        _problem(BackupProblem.damaged),
      );
    });

    test('rejects a database changed after the backup was made', () async {
      final file = await good(newPhone());
      final bad = await tamper(file, 'data.db', (old) {
        final copy = Uint8List.fromList(old);
        copy[copy.length - 10] ^= 0xff;
        return copy;
      });
      await expectLater(
        newPhone().restoreService().inspect(bad),
        _problem(BackupProblem.checksumMismatch),
      );
    });

    test('rejects a photo changed after the backup was made', () async {
      final file = await good(newPhone());
      final bad = await tamper(file, 'photos/s0_1.jpg', (_) => [1, 2, 3]);
      await expectLater(
        newPhone().restoreService().inspect(bad),
        _problem(BackupProblem.checksumMismatch),
      );
    });

    test('rejects a backup with a photo missing', () async {
      final file = await good(newPhone());
      final bad = await tamper(file, 'photos/s0_1.jpg', (_) => null);
      await expectLater(
        newPhone().restoreService().inspect(bad),
        _problem(BackupProblem.damaged),
      );
    });

    test('rejects a backup with no database', () async {
      final file = await good(newPhone());
      final bad = await tamper(file, 'data.db', (_) => null);
      await expectLater(
        newPhone().restoreService().inspect(bad),
        _problem(BackupProblem.damaged),
      );
    });

    test('rejects a photo name that tries to leave the folder', () async {
      final file = await good(newPhone());
      final bad = await tamper(
        file,
        'manifest.json',
        (old) =>
            String.fromCharCodes(old)
                .replaceAll('photos/s0_1.jpg', 'photos/../evil.jpg')
                .codeUnits,
      );
      await expectLater(
        newPhone().restoreService().inspect(bad),
        _problem(BackupProblem.damaged),
      );
    });

    test('rejects a backup from a newer app version', () async {
      final file = await good(newPhone());
      final bad = await tamper(
        file,
        'manifest.json',
        (old) =>
            String.fromCharCodes(old)
                .replaceAll('"schema_version": 1', '"schema_version": 99')
                .codeUnits,
      );
      await expectLater(
        newPhone().restoreService().inspect(bad),
        _problem(BackupProblem.newerVersion),
      );
    });

    test('rejects a newer file format', () async {
      final file = await good(newPhone());
      final bad = await tamper(
        file,
        'manifest.json',
        (old) =>
            String.fromCharCodes(old)
                .replaceAll('"format_version": 1', '"format_version": 7')
                .codeUnits,
      );
      await expectLater(
        newPhone().restoreService().inspect(bad),
        _problem(BackupProblem.newerVersion),
      );
    });

    test('rejects a database that fails its integrity check', () async {
      // A manifest whose checksum matches a damaged database: only SQLite's
      // own check can catch this.
      final phone = newPhone();
      await phone.seed();
      final good = (await (await phone.backupService()).createBackup()).file;
      final zip = ZipDecoder().decodeBytes(await good.readAsBytes());
      final db = Uint8List.fromList(
        zip.firstWhere((f) => f.name == 'data.db').readBytes()!,
      );
      // Smash a page in the middle of the file (past the header).
      for (var i = 4096; i < 4600 && i < db.length; i++) {
        db[i] = 0xAB;
      }
      final manifest = BackupManifest.decode(
        String.fromCharCodes(
          zip.firstWhere((f) => f.name == 'manifest.json').readBytes()!,
        ),
      );
      final forged = BackupManifest(
        schemaVersion: manifest.schemaVersion,
        appVersion: manifest.appVersion,
        createdAt: manifest.createdAt,
        students: manifest.students,
        payments: manifest.payments,
        sessions: manifest.sessions,
        dbSha256: sha256.convert(db).toString(),
      );
      final out = Archive()
        ..add(ArchiveFile.string('manifest.json', forged.encode()))
        ..add(ArchiveFile.bytes('data.db', db));
      final file = File(p.join(tmp.path, 'smashed.tkbackup'))
        ..writeAsBytesSync(ZipEncoder().encode(out));

      await expectLater(
        newPhone().restoreService().inspect(file),
        throwsA(isA<BackupException>()),
      );
    });
  });

  group('password protection', () {
    test('an encrypted backup is not a zip and needs its password', () async {
      final phone = newPhone();
      await phone.seed();
      final backup = await (await phone.backupService()).createBackup(
        password: 'correct horse',
      );
      final bytes = await backup.file.readAsBytes();
      expect(bytes.sublist(0, 2), isNot([0x50, 0x4b])); // not "PK"
      expect(backup.manifest.encrypted, isTrue);
      // Nothing readable inside: no student names, no JSON.
      expect(String.fromCharCodes(bytes), isNot(contains('Student 0')));

      final restorer = newPhone().restoreService();
      await expectLater(
        restorer.inspect(backup.file),
        _problem(BackupProblem.passwordRequired),
      );
      await expectLater(
        restorer.inspect(backup.file, password: 'wrong'),
        _problem(BackupProblem.wrongPassword),
      );
      final preview = await restorer.inspect(
        backup.file,
        password: 'correct horse',
      );
      expect(preview.manifest.students, 3);
      expect(preview.manifest.encrypted, isTrue);
    });

    test('a damaged encrypted file fails cleanly', () async {
      final phone = newPhone();
      await phone.seed();
      final backup = await (await phone.backupService()).createBackup(
        password: 'pw',
      );
      final bytes = await backup.file.readAsBytes();
      bytes[bytes.length ~/ 2] ^= 0xff;
      final bad = File(p.join(tmp.path, 'bad.tkbackup'))
        ..writeAsBytesSync(bytes);
      await expectLater(
        newPhone().restoreService().inspect(bad, password: 'pw'),
        _problem(BackupProblem.wrongPassword),
      );
    });

    test('an encrypted backup restores with the right password', () async {
      final a = newPhone();
      await a.seed();
      final file = (await (await a.backupService()).createBackup(
        password: 'pw',
      )).file;
      final before = await a.dump();

      final b = newPhone();
      await b.db;
      final service = b.restoreService();
      final preview = await service.inspect(file, password: 'pw');
      await service.apply(preview);
      expect(await b.dump(), before);
    });
  });

  group('round trip on a fresh install', () {
    test('reproduces identical data and photos', () async {
      final a = newPhone();
      await a.seed();
      final file = (await (await a.backupService()).createBackup()).file;
      final tablesA = await a.dump();
      final photosA = a.photoBytes();

      // A fresh install: an empty database and no photos folder.
      final b = newPhone();
      await b.db;
      expect((await b.dump())['students'], isEmpty);
      expect(b.photoBytes(), isEmpty);

      final service = b.restoreService();
      final preview = await service.inspect(file);
      await service.apply(preview);
      await service.discard(preview);

      expect(await b.dump(), tablesA);
      expect(b.photoBytes(), photosA);
    });

    test('replaces existing data rather than merging', () async {
      final a = newPhone();
      await a.seed(students: 3);
      final file = (await (await a.backupService()).createBackup()).file;
      final tablesA = await a.dump();

      final b = newPhone();
      await b.seed(students: 7, withPhotos: 4);
      final service = b.restoreService();
      final preview = await service.inspect(file);
      await service.apply(preview);

      expect(await b.dump(), tablesA);
      // Photos of the replaced data are gone too.
      expect(b.photoBytes().keys.toSet(), a.photoBytes().keys.toSet());
    });

    test('the restored database is live and writable', () async {
      final a = newPhone();
      await a.seed();
      final file = (await (await a.backupService()).createBackup()).file;
      final b = newPhone();
      await b.db;
      final service = b.restoreService();
      await service.apply(await service.inspect(file));

      final db = await b.db;
      await db.customStatement(
        'INSERT INTO students (id, name, joined_on, monthly_fee, created_at, updated_at) '
        "VALUES ('new', 'New', '2026-02-01', 1000, 1, 1)",
      );
      expect((await b.dump())['students'], hasLength(4));
    });

    test('runs the after-restore hook with the new database', () async {
      final a = newPhone();
      await a.seed();
      final file = (await (await a.backupService()).createBackup()).file;
      final b = newPhone();
      await b.db;
      var seen = -1;
      final service = b.restoreService(
        afterRestore: (db) async {
          seen =
              (await db
                      .customSelect('SELECT COUNT(*) c FROM students')
                      .getSingle())
                  .read<int>('c');
        },
      );
      await service.apply(await service.inspect(file));
      expect(seen, 3);
    });

    test('a failing after-restore hook does not undo the restore', () async {
      final a = newPhone();
      await a.seed();
      final file = (await (await a.backupService()).createBackup()).file;
      final b = newPhone();
      await b.db;
      final service = b.restoreService(
        afterRestore: (_) => throw StateError('x'),
      );
      await service.apply(await service.inspect(file));
      expect((await b.dump())['students'], hasLength(3));
    });
  });

  group('rollback (mandatory)', () {
    /// A phone with its own data, and a backup of different data to restore.
    Future<({Phone phone, File backup})> setup() async {
      final source = newPhone();
      await source.seed(students: 5, withPhotos: 3);
      final backup = (await (await source.backupService()).createBackup()).file;
      final phone = newPhone();
      await phone.seed(students: 2, withPhotos: 1);
      return (phone: phone, backup: backup);
    }

    for (final stage in RestoreStage.values) {
      test('a failure at $stage puts everything back', () async {
        final s = await setup();
        final tablesBefore = await s.phone.dump();
        final photosBefore = s.phone.photoBytes();

        final service = s.phone.restoreService(
          beforeStage: (at) {
            if (at == stage) throw StateError('forced failure at $at');
          },
        );
        final preview = await service.inspect(s.backup);
        await expectLater(
          service.apply(preview),
          _problem(BackupProblem.restoreFailedRolledBack),
        );

        // Same data, same photos, and the database still works.
        expect(await s.phone.dump(), tablesBefore);
        expect(s.phone.photoBytes(), photosBefore);
        final db = await s.phone.db;
        await db.customSelect('SELECT 1').get();
        expect(
          Directory(p.join(s.phone.appDir.path, 'photos.pre_restore'))
              .existsSync(),
          isFalse,
        );
      });
    }

    test(
      'a database that will not open after the swap is rolled back',
      () async {
        final s = await setup();
        final tablesBefore = await s.phone.dump();
        final photosBefore = s.phone.photoBytes();

        final flaky = _FlakySwapper(s.phone.swapper, failReopenTimes: 1);
        final service = s.phone.restoreService(swapper: flaky);
        final preview = await service.inspect(s.backup);
        await expectLater(
          service.apply(preview),
          _problem(BackupProblem.restoreFailedRolledBack),
        );
        expect(await s.phone.dump(), tablesBefore);
        expect(s.phone.photoBytes(), photosBefore);
      },
    );

    test(
      'a restore that passes inspection but fails the final check',
      () async {
        final s = await setup();
        final tablesBefore = await s.phone.dump();

        // The check after the swap compares counts with the manifest; make the
        // manifest lie about the number of students.
        final service = s.phone.restoreService();
        final preview = await service.inspect(s.backup);
        final lying = RestorePreview(
          manifest: BackupManifest(
            schemaVersion: preview.manifest.schemaVersion,
            appVersion: preview.manifest.appVersion,
            createdAt: preview.manifest.createdAt,
            students: preview.manifest.students + 1,
            payments: preview.manifest.payments,
            sessions: preview.manifest.sessions,
            dbSha256: preview.manifest.dbSha256,
          ),
          latestPaymentOn: preview.latestPaymentOn,
          inspected: preview.inspected,
          workDir: preview.workDir,
        );
        await expectLater(
          service.apply(lying),
          _problem(BackupProblem.restoreFailedRolledBack),
        );
        expect(await s.phone.dump(), tablesBefore);
      },
    );

    test(
      'when the rollback also fails, the safety copy is still there',
      () async {
        final s = await setup();
        final flaky = _FlakySwapper(s.phone.swapper, failReopenTimes: 99);
        final service = s.phone.restoreService(swapper: flaky);
        final preview = await service.inspect(s.backup);
        await expectLater(
          service.apply(preview),
          _problem(BackupProblem.restoreFailedNoRollback),
        );
        final safety = s.phone.appDir.listSync().whereType<File>().where(
          (f) => p.basename(f.path).startsWith('pre_restore_'),
        );
        expect(safety, hasLength(1));
        // And the safety copy really holds the old data.
        final copy = FileDatabaseSwapper(File(safety.single.path));
        final db = await copy.open();
        final n = await db
            .customSelect('SELECT COUNT(*) c FROM students')
            .getSingle();
        expect(n.read<int>('c'), 2);
        await copy.close();
      },
    );

    test('a rejected file changes nothing at all', () async {
      final s = await setup();
      final tablesBefore = await s.phone.dump();
      final photosBefore = s.phone.photoBytes();
      final junk = File(p.join(tmp.path, 'junk'))..writeAsStringSync('nope');
      await expectLater(
        s.phone.restoreService().inspect(junk),
        _problem(BackupProblem.notABackup),
      );
      expect(await s.phone.dump(), tablesBefore);
      expect(s.phone.photoBytes(), photosBefore);
    });

    test('after a good restore only the newest safety copy is kept', () async {
      final s = await setup();
      for (var i = 0; i < 2; i++) {
        s.phone.now = s.phone.now.add(const Duration(minutes: 1));
        final service = s.phone.restoreService();
        await service.apply(await service.inspect(s.backup));
      }
      final safety = s.phone.appDir.listSync().whereType<File>().where(
        (f) => p.basename(f.path).startsWith('pre_restore_'),
      );
      expect(safety, hasLength(1));
    });
  });

  group('receipt numbers after a restore', () {
    test('continue after the highest receipt, never backwards', () async {
      final a = newPhone();
      await a.seed();
      final adb = await a.db;
      // The backup's counter is behind its own payments.
      await SettingsStore(adb).set(SettingKeys.nextReceiptNo, 2);
      final file = (await (await a.backupService()).createBackup()).file;

      final b = newPhone();
      await b.db;
      final service = b.restoreService();
      await service.apply(await service.inspect(file));
      expect(await (await b.settings).get(SettingKeys.nextReceiptNo), 4);
    });

    test('a counter already ahead is left alone', () async {
      final a = newPhone();
      await a.seed();
      await SettingsStore(await a.db).set(SettingKeys.nextReceiptNo, 50);
      final file = (await (await a.backupService()).createBackup()).file;
      final b = newPhone();
      await b.db;
      final service = b.restoreService();
      await service.apply(await service.inspect(file));
      expect(await (await b.settings).get(SettingKeys.nextReceiptNo), 50);
    });
  });
}

/// Delegates to a real swapper but fails to reopen a set number of times,
/// like a database that cannot be opened or migrated.
class _FlakySwapper implements DatabaseSwapper {
  _FlakySwapper(this._inner, {required this.failReopenTimes});

  final DatabaseSwapper _inner;
  int failReopenTimes;

  @override
  File get databaseFile => _inner.databaseFile;

  @override
  Future<AppDatabase> current() => _inner.current();

  @override
  Future<void> close() => _inner.close();

  @override
  Future<AppDatabase> reopen() async {
    if (failReopenTimes > 0) {
      failReopenTimes--;
      throw StateError('cannot open');
    }
    return _inner.reopen();
  }
}
