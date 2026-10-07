import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// The Android notification channels the app uses. A channel's importance is
/// fixed once created, so each kind of reminder gets its own.
enum NotificationChannel { classes, fees, summary, backup }

/// A notification to show at [at] (local wall-clock time in Bangladesh).
class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.channel,
    this.payload,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;
  final NotificationChannel channel;

  /// The route to open when it is tapped.
  final String? payload;
}

/// The user-visible name and description of each channel, in the app's
/// current language (they show in the system notification settings).
typedef ChannelTexts = Map<NotificationChannel, ({String name, String about})>;

/// Local notifications, wrapped so the planner, scheduler and screens are
/// testable without the plugin (design section 3, principle 4).
abstract interface class NotificationService {
  /// Sets up time zones and channels. Safe to call repeatedly.
  Future<void> initialize(ChannelTexts channels);

  /// Whether the app may post notifications right now.
  Future<bool> isPermitted();

  /// Shows the system permission prompt (Android 13+). Returns whether it
  /// was granted. After two denials Android stops showing the prompt, so the
  /// caller must fall back to [openSystemSettings].
  Future<bool> requestPermission();

  /// Opens this app's notification page in system settings.
  Future<void> openSystemSettings();

  /// Shows [notification] immediately (used for the test notification).
  Future<void> showNow(ScheduledNotification notification);

  /// Cancels every pending notification and schedules [notifications].
  Future<void> replaceAll(List<ScheduledNotification> notifications);

  /// Cancels everything pending.
  Future<void> cancelAll();

  /// Ids of notifications waiting to fire.
  Future<List<int>> pendingIds();

  /// The payload of the notification that cold-started the app, once.
  Future<String?> takeLaunchPayload();

  /// Payloads of notifications tapped while the app is running.
  Stream<String> get taps;
}

/// Reminders are for a tutor in Bangladesh, which has no daylight saving, so
/// "08:00" always means 08:00 in Dhaka whatever the phone's zone says.
const reminderTimeZone = 'Asia/Dhaka';

class PluginNotificationService implements NotificationService {
  PluginNotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _taps = StreamController<String>.broadcast();
  bool _initialized = false;
  String? _launchPayload;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<void> initialize(ChannelTexts channels) async {
    if (!_initialized) {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(reminderTimeZone));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) _taps.add(payload);
        },
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _launchPayload = launch!.notificationResponse?.payload;
      }
      _initialized = true;
    }
    // Re-creating a channel only updates its texts, so a language change
    // shows up in system settings.
    for (final entry in channels.entries) {
      await _android?.createNotificationChannel(
        AndroidNotificationChannel(
          _channelId(entry.key),
          entry.value.name,
          description: entry.value.about,
          importance: entry.key == NotificationChannel.classes
              ? Importance.high
              : Importance.defaultImportance,
        ),
      );
    }
  }

  static String _channelId(NotificationChannel c) => 'tk_${c.name}';

  NotificationDetails _details(NotificationChannel c) => NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId(c),
      c.name,
      importance: c == NotificationChannel.classes
          ? Importance.high
          : Importance.defaultImportance,
      priority: c == NotificationChannel.classes
          ? Priority.high
          : Priority.defaultPriority,
    ),
  );

  @override
  Future<bool> isPermitted() async =>
      await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<void> openSystemSettings() async {
    await _plugin.openAppNotificationSettings();
  }

  @override
  Future<void> showNow(ScheduledNotification n) => _plugin.show(
    id: n.id,
    title: n.title,
    body: n.body,
    notificationDetails: _details(n.channel),
    payload: n.payload,
  );

  @override
  Future<void> replaceAll(List<ScheduledNotification> notifications) async {
    await _plugin.cancelAllPendingNotifications();
    for (final n in notifications) {
      await _plugin.zonedSchedule(
        id: n.id,
        scheduledDate: tz.TZDateTime(
          tz.local,
          n.at.year,
          n.at.month,
          n.at.day,
          n.at.hour,
          n.at.minute,
        ),
        title: n.title,
        body: n.body,
        notificationDetails: _details(n.channel),
        // A few minutes of drift is fine and inexact alarms are far more
        // reliable across phone makers (design 9.3).
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: n.payload,
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAllPendingNotifications();

  @override
  Future<List<int>> pendingIds() async => [
    for (final p in await _plugin.pendingNotificationRequests()) p.id,
  ];

  @override
  Future<String?> takeLaunchPayload() async {
    final payload = _launchPayload;
    _launchPayload = null;
    return payload;
  }
}

/// A service that does nothing, used off Android (desktop runs, web).
class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> initialize(ChannelTexts channels) async {}

  @override
  Future<bool> isPermitted() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<void> showNow(ScheduledNotification notification) async {}

  @override
  Future<void> replaceAll(List<ScheduledNotification> notifications) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<List<int>> pendingIds() async => const [];

  @override
  Future<String?> takeLaunchPayload() async => null;

  @override
  Stream<String> get taps => const Stream.empty();
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => defaultTargetPlatform == TargetPlatform.android
      ? PluginNotificationService()
      : const NoopNotificationService(),
);
