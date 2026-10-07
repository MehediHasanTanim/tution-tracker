import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/platform/notification_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/reminders/data/reminder_providers.dart';

abstract final class ReminderRoutes {
  static const settings = '/settings/reminders';
  static const permission = '/settings/reminders/permission';
  static const battery = '/settings/reminders/battery';
}

/// Turns reminders on: straight away if the phone already allows
/// notifications, otherwise through the rationale screen (design 9.3).
Future<void> startEnableReminders(BuildContext context, WidgetRef ref) async {
  final router = GoRouter.of(context);
  if (await ref.read(notificationServiceProvider).isPermitted()) {
    await completeEnable(ref);
    if (!await _guideShown(ref)) {
      await router.push<void>(ReminderRoutes.battery);
    }
  } else {
    await router.push<void>(ReminderRoutes.permission);
  }
}

/// Records that reminders are on and plans them.
Future<void> completeEnable(WidgetRef ref) async {
  await writeSetting(ref, SettingKeys.remindersEnabled, true);
  await ref.read(replanRemindersProvider)();
}

Future<void> disableReminders(WidgetRef ref) async {
  await writeSetting(ref, SettingKeys.remindersEnabled, false);
  await ref.read(replanRemindersProvider)();
}

Future<bool> _guideShown(WidgetRef ref) async {
  final store = await ref.read(settingsStoreProvider.future);
  return store.get(SettingKeys.oemGuideShown);
}
