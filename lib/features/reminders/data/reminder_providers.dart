import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/platform/notification_service.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/attendance/data/attendance_providers.dart';
import 'package:tution_tracker/features/reminders/data/reminder_scheduler.dart';

final reminderSchedulerProvider = FutureProvider<ReminderScheduler>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  final settings = await ref.watch(settingsStoreProvider.future);
  final attendance = await ref.watch(attendanceRepositoryProvider.future);
  return ReminderScheduler(
    db,
    settings,
    attendance,
    ref.watch(notificationServiceProvider),
    now: ref.read(clockProvider),
  );
});

/// Replans reminders now. Failures are swallowed: a reminder problem must
/// never get in the way of using the app (the health indicator shows it).
final replanRemindersProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    try {
      await ref.read(databaseLockProvider).run(() async {
        final scheduler = await ref.read(reminderSchedulerProvider.future);
        await scheduler.replan();
      });
    } on Object {
      // Intentionally ignored; the next trigger tries again.
    }
  };
});

/// Reminder status for the Settings indicator. Re-reads whenever settings
/// change.
final reminderStatusProvider = StreamProvider.autoDispose<ReminderStatus>((
  ref,
) async* {
  final scheduler = await ref.watch(reminderSchedulerProvider.future);
  final settings = await ref.watch(settingsStoreProvider.future);
  yield await scheduler.status();
  await for (final _ in settings.watchAny()) {
    // Give a replan that the same change started a moment to finish.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    yield await scheduler.status();
  }
});
