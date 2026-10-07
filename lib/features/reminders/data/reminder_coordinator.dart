import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/platform/notification_service.dart';
import 'package:tution_tracker/features/reminders/data/reminder_providers.dart';
import 'package:tution_tracker/router.dart';

/// Opens the screen a notification points at.
///
/// A class reminder opens the attendance sheet on top of Home, so Back
/// returns to Today instead of leaving the app.
void openNotificationRoute(GoRouter router, String payload) {
  if (payload.startsWith('/attendance')) {
    router.go('/home');
    unawaited(router.push<void>(payload));
  } else {
    router.go(payload);
  }
}

/// Keeps reminders fresh and routes notification taps (design 9.2, 9.3).
///
/// Replans on start, on resume, and shortly after any change to the data the
/// plan depends on. Taps, including the one that launched the app, open the
/// route in the notification's payload.
class ReminderCoordinator {
  ReminderCoordinator(this._ref);

  final Ref _ref;
  StreamSubscription<String>? _taps;
  StreamSubscription<void>? _changes;
  Timer? _debounce;
  bool _started = false;

  /// How long to wait for a burst of edits to settle before replanning.
  static const settleDelay = Duration(seconds: 2);

  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      final scheduler = await _ref.read(reminderSchedulerProvider.future);
      await scheduler.prepare();
      final service = _ref.read(notificationServiceProvider);
      _taps = service.taps.listen(_open);
      final launch = await service.takeLaunchPayload();
      if (launch != null) _open(launch);

      final db = await _ref.read(databaseProvider.future);
      _changes = db
          .tableUpdates(
            TableUpdateQuery.onAllTables([
              db.students,
              db.batches,
              db.batchMembers,
              db.classSessions,
              db.feeRecords,
              db.payments,
              db.paymentAllocations,
              db.settings,
            ]),
          )
          .listen((_) => _schedule());
    } on Object {
      // Reminders are best effort; the app works without them.
    }
    await refresh();
  }

  void _open(String payload) {
    openNotificationRoute(_ref.read(routerProvider), payload);
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(settleDelay, () => unawaited(refresh()));
  }

  /// Replans straight away (start, resume).
  Future<void> refresh() => _ref.read(replanRemindersProvider)();

  void dispose() {
    _debounce?.cancel();
    unawaited(_taps?.cancel());
    unawaited(_changes?.cancel());
  }
}

final reminderCoordinatorProvider = Provider<ReminderCoordinator>((ref) {
  final coordinator = ReminderCoordinator(ref);
  ref.onDispose(coordinator.dispose);
  return coordinator;
});
