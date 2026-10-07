import 'dart:convert';

import 'package:tution_tracker/features/backup/domain/backup_exception.dart';

/// What a backup contains, stored as `manifest.json` (design 10.1).
class BackupManifest {
  const BackupManifest({
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAt,
    required this.students,
    required this.payments,
    required this.sessions,
    required this.dbSha256,
    this.photos = const {},
    this.encrypted = false,
  });

  /// Written in `format` so other files are not mistaken for a backup.
  static const formatName = 'tuition-khata-backup';

  /// Bumped only when the layout of the zip changes.
  static const formatVersion = 1;

  final int schemaVersion;
  final String appVersion;

  /// UTC.
  final DateTime createdAt;

  final int students;
  final int payments;
  final int sessions;
  final String dbSha256;

  /// Zip path (`photos/<name>.jpg`) to the SHA-256 of that file.
  final Map<String, String> photos;
  final bool encrypted;

  Map<String, Object?> toJson() => {
    'format': formatName,
    'format_version': formatVersion,
    'schema_version': schemaVersion,
    'app_version': appVersion,
    'created_at': createdAt.toUtc().toIso8601String(),
    'counts': {
      'students': students,
      'payments': payments,
      'sessions': sessions,
    },
    'db_sha256': dbSha256,
    'photos': photos,
    'encrypted': encrypted,
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Throws [BackupException] if [text] is not a usable manifest.
  factory BackupManifest.decode(String text) {
    try {
      final json = jsonDecode(text) as Map<String, dynamic>;
      if (json['format'] != formatName) {
        throw const BackupException(BackupProblem.notABackup, 'format');
      }
      final version = json['format_version'] as int;
      if (version > formatVersion) {
        throw const BackupException(BackupProblem.newerVersion, 'format');
      }
      final counts = json['counts'] as Map<String, dynamic>;
      return BackupManifest(
        schemaVersion: json['schema_version'] as int,
        appVersion: json['app_version'] as String,
        createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
        students: counts['students'] as int,
        payments: counts['payments'] as int,
        sessions: counts['sessions'] as int,
        dbSha256: json['db_sha256'] as String,
        photos: {
          for (final e in (json['photos'] as Map<String, dynamic>).entries)
            e.key: e.value as String,
        },
        encrypted: json['encrypted'] as bool? ?? false,
      );
    } on BackupException {
      rethrow;
    } on Object catch (e) {
      throw BackupException(BackupProblem.damaged, 'manifest: $e');
    }
  }
}
