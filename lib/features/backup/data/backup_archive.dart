import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:tution_tracker/features/backup/domain/backup_crypto.dart';
import 'package:tution_tracker/features/backup/domain/backup_exception.dart';
import 'package:tution_tracker/features/backup/domain/backup_manifest.dart';

// Everything here uses plain data and top-level functions so it can run in a
// background isolate (design 10.2 step 4): zipping, hashing and key
// derivation would otherwise freeze the screen on a big backup.

const manifestEntry = 'manifest.json';
const databaseEntry = 'data.db';
const photosPrefix = 'photos/';

/// Photo entry names are plain file names: no folders, no tricks.
final _photoName = RegExp(r'^photos/[A-Za-z0-9._-]+$');

class BuildRequest {
  const BuildRequest({
    required this.snapshotPath,
    required this.photos,
    required this.outputPath,
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAt,
    this.password,
  });

  /// A finished SQLite copy (from `VACUUM INTO`).
  final String snapshotPath;

  /// Zip entry name (`photos/x.jpg`) to the file on disk. Missing files are
  /// skipped: a student can point at a photo that was deleted.
  final Map<String, String> photos;

  final String outputPath;
  final int schemaVersion;
  final String appVersion;
  final DateTime createdAt;
  final String? password;
}

/// Writes the backup file for [request] and returns its manifest.
Future<BackupManifest> buildBackupFile(BuildRequest request) async {
  final db = File(request.snapshotPath);
  final dbBytes = await db.readAsBytes();
  final counts = _count(request.snapshotPath);

  final archive = Archive();
  final photoHashes = <String, String>{};
  for (final entry in request.photos.entries) {
    final file = File(entry.value);
    if (!file.existsSync()) continue;
    final bytes = await file.readAsBytes();
    photoHashes[entry.key] = sha256.convert(bytes).toString();
    // JPEG does not compress further; storing is much faster.
    archive.add(ArchiveFile.noCompress(entry.key, bytes.length, bytes));
  }

  final manifest = BackupManifest(
    schemaVersion: request.schemaVersion,
    appVersion: request.appVersion,
    createdAt: request.createdAt,
    students: counts.students,
    payments: counts.payments,
    sessions: counts.sessions,
    dbSha256: sha256.convert(dbBytes).toString(),
    photos: photoHashes,
    encrypted: request.password != null,
  );
  archive
    ..add(ArchiveFile.string(manifestEntry, manifest.encode()))
    ..add(ArchiveFile.bytes(databaseEntry, dbBytes));

  var zip = Uint8List.fromList(ZipEncoder().encode(archive));
  final password = request.password;
  if (password != null) zip = await BackupCrypto.encrypt(zip, password);

  // Written beside the target and renamed, so a half-written file is never
  // mistaken for a finished backup.
  final temp = File('${request.outputPath}.part');
  await temp.writeAsBytes(zip, flush: true);
  await temp.rename(request.outputPath);
  return manifest;
}

({int students, int payments, int sessions}) _count(String dbPath) {
  final db = sqlite.sqlite3.open(dbPath, mode: sqlite.OpenMode.readOnly);
  try {
    int one(String table, [String where = '']) =>
        db.select('SELECT COUNT(*) FROM $table $where').first.values.first!
            as int;
    return (
      students: one('students'),
      payments: one('payments', 'WHERE deleted_at IS NULL'),
      sessions: one('class_sessions'),
    );
  } finally {
    db.close();
  }
}

class InspectRequest {
  const InspectRequest({
    required this.backupPath,
    required this.workDir,
    required this.currentSchemaVersion,
    this.password,
  });

  final String backupPath;

  /// An empty folder to unpack into.
  final String workDir;

  /// The newest schema this app can open.
  final int currentSchemaVersion;
  final String? password;
}

/// A backup that has been unpacked and checked, ready to restore.
class InspectedBackup {
  const InspectedBackup({
    required this.manifest,
    required this.databasePath,
    required this.photoPaths,
    required this.latestPaymentOn,
  });

  final BackupManifest manifest;

  /// The unpacked database inside the work folder.
  final String databasePath;

  /// Zip entry name (`photos/x.jpg`) to the unpacked file.
  final Map<String, String> photoPaths;

  /// The newest `received_on` among live payments, or null if none.
  final String? latestPaymentOn;
}

/// Unpacks and validates a backup (design 10.3 steps 2 to 4). Throws
/// [BackupException] describing exactly what is wrong.
Future<InspectedBackup> inspectBackupFile(InspectRequest request) async {
  Uint8List bytes;
  try {
    bytes = await File(request.backupPath).readAsBytes();
  } on Object catch (e) {
    throw BackupException(BackupProblem.damaged, 'read: $e');
  }
  if (BackupCrypto.isEncrypted(bytes)) {
    final password = request.password;
    if (password == null) {
      throw const BackupException(BackupProblem.passwordRequired);
    }
    bytes = await BackupCrypto.decrypt(bytes, password);
  } else if (bytes.length < 4 || bytes[0] != 0x50 || bytes[1] != 0x4b) {
    throw const BackupException(BackupProblem.notABackup, 'not a zip');
  }

  Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } on Object catch (e) {
    throw BackupException(BackupProblem.damaged, 'zip: $e');
  }

  ArchiveFile? find(String name) {
    for (final f in archive) {
      if (f.isFile && f.name == name) return f;
    }
    return null;
  }

  final manifestFile = find(manifestEntry);
  if (manifestFile == null) {
    // Ours but cut short, or someone else's zip? Our files name the manifest
    // in plain text in the zip's headers.
    final ours = _contains(bytes, manifestEntry.codeUnits);
    throw BackupException(
      ours ? BackupProblem.damaged : BackupProblem.notABackup,
      'no manifest',
    );
  }
  final BackupManifest manifest;
  try {
    manifest = BackupManifest.decode(
      String.fromCharCodes(manifestFile.readBytes() ?? Uint8List(0)),
    );
  } on BackupException {
    rethrow;
  }
  if (manifest.schemaVersion > request.currentSchemaVersion) {
    throw BackupException(
      BackupProblem.newerVersion,
      'schema ${manifest.schemaVersion}',
    );
  }

  final dbFile = find(databaseEntry);
  final dbBytes = dbFile?.readBytes();
  if (dbBytes == null) {
    throw const BackupException(BackupProblem.damaged, 'no database');
  }
  if (sha256.convert(dbBytes).toString() != manifest.dbSha256) {
    throw const BackupException(BackupProblem.checksumMismatch, 'database');
  }

  final work = Directory(request.workDir)..createSync(recursive: true);
  final dbPath = '${work.path}/$databaseEntry';
  await File(dbPath).writeAsBytes(dbBytes, flush: true);

  final photoPaths = <String, String>{};
  for (final entry in manifest.photos.entries) {
    if (!_photoName.hasMatch(entry.key)) {
      throw BackupException(BackupProblem.damaged, 'bad name ${entry.key}');
    }
    final file = find(entry.key);
    final data = file?.readBytes();
    if (data == null) {
      throw BackupException(BackupProblem.damaged, 'missing ${entry.key}');
    }
    if (sha256.convert(data).toString() != entry.value) {
      throw BackupException(BackupProblem.checksumMismatch, entry.key);
    }
    final out = File('${work.path}/${entry.key}');
    await out.parent.create(recursive: true);
    await out.writeAsBytes(data, flush: true);
    photoPaths[entry.key] = out.path;
  }

  final latest = _verifyDatabase(dbPath, manifest);
  return InspectedBackup(
    manifest: manifest,
    databasePath: dbPath,
    photoPaths: photoPaths,
    latestPaymentOn: latest,
  );
}

/// SQLite's own integrity check, plus agreement with the manifest. Returns
/// the latest payment date.
String? _verifyDatabase(String path, BackupManifest manifest) {
  sqlite.Database db;
  try {
    db = sqlite.sqlite3.open(path, mode: sqlite.OpenMode.readOnly);
  } on Object catch (e) {
    throw BackupException(BackupProblem.damaged, 'open: $e');
  }
  try {
    final check = db.select('PRAGMA integrity_check');
    if (check.length != 1 || check.first.values.first != 'ok') {
      throw const BackupException(BackupProblem.integrityFailed);
    }
    final version = db.select('PRAGMA user_version').first.values.first as int;
    if (version != manifest.schemaVersion) {
      throw BackupException(
        BackupProblem.damaged,
        'schema $version vs ${manifest.schemaVersion}',
      );
    }
    final counts = _count(path);
    if (counts.students != manifest.students ||
        counts.payments != manifest.payments ||
        counts.sessions != manifest.sessions) {
      throw const BackupException(BackupProblem.damaged, 'counts');
    }
    final row = db.select(
      'SELECT MAX(received_on) FROM payments WHERE deleted_at IS NULL',
    );
    return row.first.values.first as String?;
  } on sqlite.SqliteException catch (e) {
    throw BackupException(BackupProblem.integrityFailed, '$e');
  } finally {
    db.close();
  }
}

bool _contains(Uint8List haystack, List<int> needle) {
  outer:
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}
