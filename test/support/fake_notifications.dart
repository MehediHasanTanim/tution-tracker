import 'dart:async';

import 'package:tution_tracker/core/platform/battery_guide_service.dart';
import 'package:tution_tracker/core/platform/notification_service.dart';

/// An in-memory [NotificationService] that records what was scheduled.
class FakeNotifications implements NotificationService {
  FakeNotifications({this.permitted = true, this.grants = true});

  bool permitted;

  /// What [requestPermission] does: grant (and become permitted) or not.
  bool grants;
  int permissionRequests = 0;
  int settingsOpened = 0;
  int initializeCalls = 0;
  int cancelAllCalls = 0;
  ChannelTexts? channels;
  String? launchPayload;
  final scheduled = <ScheduledNotification>[];
  final shown = <ScheduledNotification>[];
  final tapController = StreamController<String>.broadcast();

  @override
  Stream<String> get taps => tapController.stream;

  @override
  Future<void> initialize(ChannelTexts channels) async {
    initializeCalls++;
    this.channels = channels;
  }

  @override
  Future<bool> isPermitted() async => permitted;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    if (grants) permitted = true;
    return grants;
  }

  @override
  Future<void> openSystemSettings() async => settingsOpened++;

  @override
  Future<void> showNow(ScheduledNotification notification) async =>
      shown.add(notification);

  @override
  Future<void> replaceAll(List<ScheduledNotification> notifications) async {
    scheduled
      ..clear()
      ..addAll(notifications);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    scheduled.clear();
  }

  @override
  Future<List<int>> pendingIds() async => [for (final n in scheduled) n.id];

  @override
  Future<String?> takeLaunchPayload() async {
    final p = launchPayload;
    launchPayload = null;
    return p;
  }
}

/// A [BatteryGuideService] for tests: a fixed maker, and a record of opens.
class FakeBatteryGuide implements BatteryGuideService {
  FakeBatteryGuide([this.detected = PhoneMaker.xiaomi]);

  final PhoneMaker detected;
  final opened = <PhoneMaker>[];

  @override
  Future<PhoneMaker> maker() async => detected;

  @override
  Future<bool> openBatterySettings(PhoneMaker maker) async {
    opened.add(maker);
    return true;
  }
}
