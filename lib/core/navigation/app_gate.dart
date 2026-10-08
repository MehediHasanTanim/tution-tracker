import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock_guard.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/features/lock/data/lock_controller.dart';
import 'package:tution_tracker/features/lock/presentation/lock_screen.dart';
import 'package:tution_tracker/features/onboarding/data/onboarding_providers.dart';
import 'package:tution_tracker/features/onboarding/presentation/onboarding_screen.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Sits above the whole app: shows the first-run flow until it is finished,
/// and the lock screen whenever the app is locked. The app underneath stays
/// mounted (so nothing is lost on lock) but cannot be seen or touched.
class AppGate extends ConsumerStatefulWidget {
  const AppGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<AppGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(dateJumpProvider.notifier).check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = ref.read(lockControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        lock.didLeave();
      case AppLifecycleState.resumed:
        lock.didReturn();
        ref.read(dateJumpProvider.notifier).check();
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break; // system dialogs and the biometric prompt only make it inactive
    }
  }

  @override
  Widget build(BuildContext context) {
    final cover = _coverOf(ref);
    final covered = cover != _Cover.none;
    return Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            excluding: covered,
            child: IgnorePointer(ignoring: covered, child: widget.child),
          ),
        ),
        // Its own Navigator, so dialogs, menus and tooltips work above the
        // router. The page rebuilds itself from the providers.
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !covered,
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                opaque: false,
                pageBuilder: (_, _, _) => Consumer(
                  builder: (context, ref, _) => switch (_coverOf(ref)) {
                    _Cover.splash => const _Splash(),
                    _Cover.onboarding => const OnboardingScreen(),
                    _Cover.lock => const LockScreen(),
                    _Cover.dateJump => const _DateJumpNotice(),
                    _Cover.none => const SizedBox.shrink(),
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _Cover { none, splash, onboarding, lock, dateJump }

_Cover _coverOf(WidgetRef ref) {
  final onboarding = ref.watch(onboardingDoneProvider);
  final lock = ref.watch(lockControllerProvider);
  if (!onboarding.hasValue || lock == LockStatus.unknown) return _Cover.splash;
  if (onboarding.requireValue == false) return _Cover.onboarding;
  if (lock == LockStatus.locked) return _Cover.lock;
  if (ref.watch(dateJumpProvider) != null) return _Cover.dateJump;
  return _Cover.none;
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surface,
    child: Center(
      child: Icon(
        Icons.school_outlined,
        size: 72,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

/// Warns that the phone's date went backwards (spec section 7, case 7).
class _DateJumpNotice extends ConsumerWidget {
  const _DateJumpNotice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final days = ref.watch(dateJumpProvider) ?? 0;
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.dateJumpTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.dateJumpBody(formatCount(days, numerals)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () =>
                      ref.read(dateJumpProvider.notifier).acknowledge(),
                  child: Text(l10n.dateJumpOk),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
