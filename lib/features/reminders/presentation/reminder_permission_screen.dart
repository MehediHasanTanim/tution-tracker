import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/platform/notification_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/reminders/presentation/reminder_actions.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Explains why the app wants to send notifications before the system asks,
/// and says plainly what happens if the tutor refuses (design 9.3).
class ReminderPermissionScreen extends ConsumerStatefulWidget {
  const ReminderPermissionScreen({super.key});

  @override
  ConsumerState<ReminderPermissionScreen> createState() =>
      _ReminderPermissionScreenState();
}

class _ReminderPermissionScreenState
    extends ConsumerState<ReminderPermissionScreen>
    with WidgetsBindingObserver {
  bool _denied = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from system settings: pick up a permission granted there.
    if (state == AppLifecycleState.resumed && _denied) _recheck();
  }

  Future<void> _recheck() async {
    if (await ref.read(notificationServiceProvider).isPermitted()) {
      await _granted();
    }
  }

  Future<void> _allow() async {
    if (_busy) return;
    setState(() => _busy = true);
    final granted = await ref
        .read(notificationServiceProvider)
        .requestPermission();
    if (!mounted) return;
    setState(() => _busy = false);
    if (granted) {
      await _granted();
    } else {
      setState(() => _denied = true);
    }
  }

  Future<void> _granted() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).remPermGranted;
    await completeEnable(ref);
    final store = await ref.read(settingsStoreProvider.future);
    final seen = await store.get(SettingKeys.oemGuideShown);
    if (seen) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
      if (router.canPop()) router.pop();
    } else {
      await router.pushReplacement<void>(ReminderRoutes.battery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.remPermTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                _denied
                    ? Icons.notifications_off_outlined
                    : Icons.notifications_active_outlined,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _denied ? l10n.remPermDenied : l10n.remPermWhy,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (_denied)
                FilledButton(
                  onPressed: () => ref
                      .read(notificationServiceProvider)
                      .openSystemSettings(),
                  child: Text(l10n.remPermOpenSettings),
                )
              else
                FilledButton(
                  onPressed: _busy ? null : _allow,
                  child: Text(l10n.remPermAllow),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(l10n.remPermNotNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
