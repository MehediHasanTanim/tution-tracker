import 'package:tution_tracker/core/dates/local_date.dart';

/// Whether to nag the tutor about backing up (spec 3.10).
class BackupStatus {
  const BackupStatus({required this.show, this.daysAgo});

  /// Nothing to remind about.
  static const hidden = BackupStatus(show: false);

  final bool show;

  /// Days since the last backup; null when there never was one.
  final int? daysAgo;
}

/// The banner appears when there is data worth protecting and the last backup
/// is [limitDays] or more days old (or there has never been one). An empty
/// app has nothing to lose, so it stays quiet.
BackupStatus backupStatus({
  required LocalDate today,
  required DateTime? lastBackup,
  required int limitDays,
  required bool hasData,
}) {
  if (!hasData) return BackupStatus.hidden;
  if (lastBackup == null) return const BackupStatus(show: true);
  final days = LocalDate.fromDateTime(lastBackup).daysUntil(today);
  return days >= limitDays
      ? BackupStatus(show: true, daysAgo: days)
      : BackupStatus(show: false, daysAgo: days);
}
