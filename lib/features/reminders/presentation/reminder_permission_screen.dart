import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/platform/notification_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
import 'package:tution_tracker/features/reminders/presentation/reminder_actions.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
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
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    String numeral(int n) => applyNumerals('$n', numerals);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.remPermTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          BlockStack(
            children: [
              BlockIllustration(
                icon: _denied
                    ? Icons.notifications_off_rounded
                    : Icons.notifications_active_rounded,
                sage: false,
              ),
              BlockSubheading(_denied ? l10n.remPermTitle : l10n.remPermAsk),
              if (_denied)
                BlockText(l10n.remPermDenied)
              else ...[
                BlockStep(number: numeral(1), text: l10n.remPermStep1),
                BlockStep(number: numeral(2), text: l10n.remPermStep2),
                BlockStep(number: numeral(3), text: l10n.remPermStep3),
              ],
            ],
          ),
        ],
      ),
      // The actions stay in reach on small phones, under the explanation.
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: BlockStack(
          children: [
            if (_denied)
              BlockButton(
                l10n.remPermOpenSettings,
                onPressed: () =>
                    ref.read(notificationServiceProvider).openSystemSettings(),
              )
            else
              BlockButton(l10n.remPermAllow, onPressed: _busy ? null : _allow),
            BlockButton(
              l10n.remPermNotNow,
              kind: BlockButtonKind.ghost,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
