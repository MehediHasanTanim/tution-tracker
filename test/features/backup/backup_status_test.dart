import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/features/backup/domain/backup_status.dart';

void main() {
  const today = LocalDate(2026, 3, 15);

  BackupStatus status(DateTime? last, {int limit = 14, bool hasData = true}) =>
      backupStatus(
        today: today,
        lastBackup: last,
        limitDays: limit,
        hasData: hasData,
      );

  test('an empty app has nothing to protect', () {
    expect(status(null, hasData: false).show, isFalse);
  });

  test('never backed up, with data: show', () {
    final s = status(null);
    expect(s.show, isTrue);
    expect(s.daysAgo, isNull);
  });

  test('fresh backups stay quiet until the limit', () {
    expect(status(DateTime(2026, 3, 15, 9)).show, isFalse);
    expect(status(DateTime(2026, 3, 2)).show, isFalse); // 13 days
    expect(status(DateTime(2026, 3, 2)).daysAgo, 13);
  });

  test('on the limit day and after, show', () {
    expect(status(DateTime(2026, 3, 1)).show, isTrue); // 14 days
    expect(status(DateTime(2026, 3, 1)).daysAgo, 14);
    expect(status(DateTime(2025, 12, 1)).show, isTrue);
  });

  test('follows the setting', () {
    expect(status(DateTime(2026, 3, 8), limit: 7).show, isTrue);
    expect(status(DateTime(2026, 3, 8), limit: 30).show, isFalse);
  });

  test('time of day does not matter, only the date', () {
    expect(status(DateTime(2026, 3, 1, 23, 59)).show, isTrue);
  });
}
