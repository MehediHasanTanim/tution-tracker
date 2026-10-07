import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/app.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/platform/battery_guide_service.dart';
import 'package:tution_tracker/core/platform/notification_service.dart';
import 'package:tution_tracker/core/platform/photo_picker.dart';
import 'package:tution_tracker/features/students/data/photo_processing.dart';
import 'package:tution_tracker/features/students/data/photo_store.dart';

import 'fake_notifications.dart';

/// The real app wired to an in-memory [db] instead of the on-device file.
Widget testApp(
  AppDatabase db, {
  DateTime Function()? clock,
  List<Override> overrides = const [],
  PhotoStore? photoStore,
  PhotoPicker? photoPicker,
  NotificationService? notifications,
  BatteryGuideService? batteryGuide,
  Future<AppDatabase> Function()? reopenDb,
  AppFlavor flavor = AppFlavor.dev,
}) => ProviderScope(
  overrides: [
    appFlavorProvider.overrideWithValue(flavor),
    databaseProvider.overrideWith((ref) async {
      // With [reopenDb] the database can be closed and opened again, as a
      // restore does; otherwise one in-memory instance is used throughout.
      if (reopenDb == null) return db;
      await ref.read(databaseLockProvider).whenUnlocked;
      final opened = await reopenDb();
      ref.onDispose(() => closeDatabase(opened));
      return opened;
    }),
    photoStoreProvider.overrideWith(
      (ref) async =>
          photoStore ??
          PhotoStore(Directory.systemTemp.createTempSync('tk_ph_')),
    ),
    if (photoPicker != null) photoPickerProvider.overrideWithValue(photoPicker),
    photoCompressorProvider.overrideWithValue(
      (bytes) async => compressPhoto(bytes),
    ),
    if (clock != null) clockProvider.overrideWithValue(clock),
    notificationServiceProvider.overrideWithValue(
      notifications ?? FakeNotifications(),
    ),
    if (batteryGuide != null)
      batteryGuideServiceProvider.overrideWithValue(batteryGuide),
    ...overrides,
  ],
  child: TuitionTrackerApp(flavor: flavor),
);

/// Mounts the app on [db]. Pair with [shutdownApp] at the end of the test.
Future<void> pumpApp(
  WidgetTester tester,
  AppDatabase db, {
  DateTime Function()? clock,
  List<Override> overrides = const [],
  PhotoStore? photoStore,
  PhotoPicker? photoPicker,
  NotificationService? notifications,
  BatteryGuideService? batteryGuide,
  Future<AppDatabase> Function()? reopenDb,
  AppFlavor flavor = AppFlavor.dev,
}) async {
  await tester.pumpWidget(
    testApp(
      db,
      flavor: flavor,
      clock: clock,
      overrides: overrides,
      photoStore: photoStore,
      photoPicker: photoPicker,
      notifications: notifications,
      batteryGuide: batteryGuide,
      reopenDb: reopenDb,
    ),
  );
  await settle(tester);
}

/// Unmounts the app and closes [db].
///
/// Stream queries must be unmounted before the database closes, and closing
/// has to happen in real time, not fake time, or the test hangs. Call this
/// inside the test body: Flutter checks for pending timers right after the
/// body, before any `tearDown`.
Future<void> shutdownApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  // Drift schedules a zero-length timer when a stream is cancelled; fire it
  // so the test does not end with a pending timer.
  await tester.pump(const Duration(milliseconds: 10));
  await tester.runAsync(db.close);
}

/// Lets real async work (SQLite, streams) finish, then rebuilds the UI.
///
/// Widget tests run on fake time, so database futures only complete inside
/// [WidgetTester.runAsync].
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// A widget test with its own in-memory database, shut down cleanly after.
void appTestWidgets(
  String description,
  Future<void> Function(WidgetTester tester, AppDatabase db) body,
) {
  testWidgets(description, (tester) async {
    final db = openInMemoryDatabase();
    try {
      await body(tester, db);
    } finally {
      await shutdownApp(tester, db);
    }
  });
}

/// Scrolls [target] to the middle of its scroll view, then taps it.
///
/// Unfocuses first so text-field handles do not cover it, and avoids the top
/// edge, where a tap can miss behind the app bar.
Future<void> tapCentered(WidgetTester tester, Finder target) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
  await tester.pump();
  await tester.tap(target);
  await tester.pump();
}
