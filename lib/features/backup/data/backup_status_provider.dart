import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/backup/domain/backup_status.dart';

/// Whether any student exists, live.
final _hasDataProvider = StreamProvider.autoDispose<bool>((ref) async* {
  final db = await ref.watch(databaseProvider.future);
  yield* db
      .customSelect(
        'SELECT EXISTS(SELECT 1 FROM students) AS e',
        readsFrom: {db.students},
      )
      .watchSingle()
      .map((r) => r.read<int>('e') == 1);
});

/// Drives the "back up" banner on Home.
final backupStatusProvider = Provider.autoDispose<BackupStatus>((ref) {
  final hasData = ref.watch(_hasDataProvider).value ?? false;
  final last =
      ref.watch(settingValueProvider(SettingKeys.lastBackupAt)).value
          as DateTime?;
  final days =
      (ref.watch(settingValueProvider(SettingKeys.backupReminderDays)).value
          as int?) ??
      SettingKeys.backupReminderDays.defaultValue;
  return backupStatus(
    today: todayFrom(ref.watch(clockProvider)),
    lastBackup: last,
    limitDays: days,
    hasData: hasData,
  );
});
