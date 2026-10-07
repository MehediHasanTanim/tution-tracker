import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/backup/data/backup_service.dart';
import 'package:tution_tracker/features/backup/data/database_swapper.dart';
import 'package:tution_tracker/features/backup/data/restore_service.dart';

/// A pretend phone: an app folder with a real SQLite file and photos, the
/// way the app lays them out on a device.
class Phone {
  Phone(this.root, {DateTime? now})
    : now = now ?? DateTime(2026, 10, 6, 16, 30),
      appDir = Directory(p.join(root.path, 'app'))..createSync(recursive: true),
      workDir = Directory(p.join(root.path, 'work'))
        ..createSync(recursive: true) {
    swapper = FileDatabaseSwapper(File(p.join(appDir.path, 'data.sqlite')));
  }

  final Directory root;
  final Directory appDir;
  final Directory workDir;
  DateTime now;
  late final FileDatabaseSwapper swapper;

  Future<AppDatabase> get db => swapper.open();

  Future<SettingsStore> get settings async => SettingsStore(await db);

  Future<BackupService> backupService() async => BackupService(
    await db,
    await settings,
    appDir: appDir,
    workDir: workDir,
    now: () => now,
  );

  RestoreService restoreService({
    FutureOr<void> Function(RestoreStage stage)? beforeStage,
    DatabaseSwapper? swapper,
    FutureOr<void> Function(AppDatabase db)? afterRestore,
  }) => RestoreService(
    swapper: swapper ?? this.swapper,
    appDir: appDir,
    workRoot: workDir,
    now: () => now,
    beforeStage: beforeStage,
    afterRestore: afterRestore,
  );

  File photo(String relative) =>
      File(p.joinAll([appDir.path, ...p.posix.split(relative)]));

  Future<void> close() => swapper.close();

  /// Seeds [students] students (the first [withPhotos] with a photo), each
  /// with two payments, plus a batch, a session with attendance, settings and
  /// a custom message template.
  Future<void> seed({int students = 3, int withPhotos = 2}) async {
    final db = await this.db;
    final settings = SettingsStore(db);
    await db.batch((b) {
      for (var i = 0; i < students; i++) {
        final photo = i < withPhotos ? 'photos/s${i}_1.jpg' : null;
        b.insert(
          db.students,
          StudentsCompanion.insert(
            id: 's$i',
            name: 'Student $i',
            joinedOn: '2026-01-01',
            monthlyFee: 1500,
            createdAt: 1,
            updatedAt: 1,
            photoPath: Value(photo),
            guardianPhone: const Value('01712345678'),
          ),
        );
      }
      b.insert(
        db.batches,
        BatchesCompanion.insert(
          id: 'b1',
          name: 'Math 9',
          scheduleDays: '[1,3]',
          createdAt: 1,
          updatedAt: 1,
        ),
      );
      for (var i = 0; i < students; i++) {
        b.insert(
          db.feeRecords,
          FeeRecordsCompanion.insert(
            id: 'f$i',
            studentId: 's$i',
            month: '2026-01',
            amountDue: 1500,
            dueDate: '2026-01-10',
            createdAt: 1,
          ),
        );
        b.insert(
          db.payments,
          PaymentsCompanion.insert(
            id: 'p$i',
            studentId: 's$i',
            amount: 1000,
            receivedOn: '2026-01-${(10 + i % 15).toString().padLeft(2, '0')}',
            receiptNo: i + 1,
            createdAt: 1,
          ),
        );
        b.insert(
          db.paymentAllocations,
          PaymentAllocationsCompanion.insert(
            id: 'a$i',
            paymentId: 'p$i',
            feeRecordId: Value('f$i'),
            studentId: 's$i',
            amount: 1000,
          ),
        );
      }
      b.insert(
        db.classSessions,
        ClassSessionsCompanion.insert(
          id: 'cs1',
          batchId: const Value('b1'),
          date: '2026-01-05',
        ),
      );
      b.insert(
        db.attendance,
        AttendanceCompanion.insert(
          id: 'at1',
          sessionId: 'cs1',
          studentId: 's0',
          status: 'present',
        ),
      );
      b.insert(
        db.messageTemplates,
        MessageTemplatesCompanion.insert(
          id: 'fee_reminder:bn',
          kind: 'fee_reminder',
          language: 'bn',
          body: 'কাস্টম {student}',
        ),
      );
    });
    await settings.set(SettingKeys.tutorName, 'আজিজ স্যার');
    await settings.set(SettingKeys.nextReceiptNo, students + 1);
    for (var i = 0; i < withPhotos && i < students; i++) {
      final f = photo('photos/s${i}_1.jpg');
      f.parent.createSync(recursive: true);
      f.writeAsBytesSync(List.generate(2000, (j) => (i * 31 + j) % 256));
    }
  }

  /// Every table's rows, for comparing two databases.
  Future<Map<String, List<Map<String, Object?>>>> dump() async {
    final db = await this.db;
    final out = <String, List<Map<String, Object?>>>{};
    for (final table in db.allTables) {
      final name = table.actualTableName;
      final rows = await db
          .customSelect('SELECT * FROM $name ORDER BY 1, 2')
          .get();
      out[name] = [for (final r in rows) Map<String, Object?>.from(r.data)];
    }
    return out;
  }

  /// Photo files under `photos/` as name to bytes.
  Map<String, List<int>> photoBytes() {
    final dir = Directory(p.join(appDir.path, 'photos'));
    if (!dir.existsSync()) return {};
    return {
      for (final f in dir.listSync().whereType<File>())
        p.basename(f.path): f.readAsBytesSync(),
    };
  }
}
