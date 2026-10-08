import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/platform/notification_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/attendance/data/attendance_repository.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:tution_tracker/features/reminders/data/reminder_scheduler.dart';

import '../../support/fake_notifications.dart';
import '../../support/fee_harness.dart';

void main() {
  late FeeHarness h; // clock: Sunday 2026-03-15 10:00
  late FakeNotifications notifications;
  late ReminderScheduler scheduler;

  setUp(() async {
    h = FeeHarness();
    notifications = FakeNotifications();
    scheduler = ReminderScheduler(
      h.db,
      h.settings,
      AttendanceRepository(h.db),
      notifications,
      now: () => h.now,
    );
    await h.settings.set(SettingKeys.remindersEnabled, true);
    await h.settings.set(SettingKeys.language, AppLanguage.bn);
  });

  tearDown(() => h.close());

  Future<void> seed() async {
    final batch = await h.batches.create(
      const BatchDraft(
        name: 'Math 9',
        scheduleDays: [7, 3],
        startTime: ClockTime(17, 0),
      ),
    );
    final s = await h.addStudent(name: 'Rahim', dueDay: 20);
    await h.batches.addMembers(batch.id, [s.id], const LocalDate(2026, 1, 1));
  }

  test('does nothing while reminders are off', () async {
    await seed();
    await h.settings.set(SettingKeys.remindersEnabled, false);
    await scheduler.replan();
    expect(notifications.scheduled, isEmpty);
    expect(notifications.cancelAllCalls, 1);
  });

  test('does nothing without the notification permission', () async {
    await seed();
    notifications.permitted = false;
    await scheduler.replan();
    expect(notifications.scheduled, isEmpty);
  });

  test('schedules the seeded classes, fees and summary', () async {
    await seed();
    await scheduler.replan();

    final byChannel = <NotificationChannel, List<ScheduledNotification>>{};
    for (final n in notifications.scheduled) {
      byChannel.putIfAbsent(n.channel, () => []).add(n);
    }
    // Sun 15 (16:30 is already past 10:00? no: still ahead), Wed 18, Sun 22, Wed 25.
    expect(byChannel[NotificationChannel.classes], hasLength(4));
    final first = byChannel[NotificationChannel.classes]!.first;
    expect(first.at, DateTime(2026, 3, 15, 16, 30));
    expect(first.title, 'ক্লাস: Math 9');
    expect(first.body, 'শুরু ১৭:০০');
    expect(
      first.payload,
      '/attendance?kind=batch&id=${first.payload!.split('id=')[1].split('&')[0]}'
      '&date=2026-03-15&time=17%3A00',
    );

    final fees = byChannel[NotificationChannel.fees]!.single;
    expect(fees.at, DateTime(2026, 3, 20, 8));
    expect(fees.title, 'আজ ১ জনের ফি আদায়ের দিন');
    expect(fees.payload, '/fees');
  });

  test('replanning twice leaves exactly the same set, no duplicates', () async {
    await seed();
    await scheduler.replan();
    final before = await notifications.pendingIds();
    await scheduler.replan();
    final after = await notifications.pendingIds();
    expect(after, before);
    expect(after.toSet(), hasLength(after.length));
  });

  test('a change to the data changes the plan on the next replan', () async {
    await seed();
    await scheduler.replan();
    final before = notifications.scheduled.length;
    await AttendanceRepository(h.db).markOff(
      owner: (await AttendanceRepository(
        h.db,
      ).watchBatchRules().first).first.owner,
      date: const LocalDate(2026, 3, 18),
      startTime: const ClockTime(17, 0),
      status: SessionStatus.cancelled,
    );
    await scheduler.replan();
    expect(notifications.scheduled.length, before - 1);
  });

  test('English texts when the language is English', () async {
    await seed();
    await h.settings.set(SettingKeys.language, AppLanguage.en);
    await h.settings.set(SettingKeys.numerals, NumeralStyle.western);
    await scheduler.replan();
    final cls = notifications.scheduled.firstWhere(
      (n) => n.channel == NotificationChannel.classes,
    );
    expect(cls.title, 'Class: Math 9');
    expect(cls.body, 'Starts at 17:00');
  });

  test('channels are created with names in the current language', () async {
    await seed();
    await scheduler.replan();
    expect(
      notifications.channels![NotificationChannel.classes]!.name,
      'ক্লাসের রিমাইন্ডার',
    );
  });

  test('the test notification is shown immediately', () async {
    await scheduler.sendTest();
    expect(notifications.shown.single.title, 'পরীক্ষামূলক নোটিফিকেশন');
  });

  test('status reports permission and what is scheduled', () async {
    await seed();
    await scheduler.replan();
    var status = await scheduler.status();
    expect(status.healthy, isTrue);
    expect(status.scheduled, notifications.scheduled.length);

    notifications.permitted = false;
    status = await scheduler.status();
    expect(status.healthy, isFalse);
  });
}
