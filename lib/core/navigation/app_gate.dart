import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/features/lock/data/lock_controller.dart';
import 'package:tution_tracker/features/lock/presentation/lock_screen.dart';
import 'package:tution_tracker/features/onboarding/data/onboarding_providers.dart';
import 'package:tution_tracker/features/onboarding/presentation/onboarding_screen.dart';

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

enum _Cover { none, splash, onboarding, lock }

_Cover _coverOf(WidgetRef ref) {
  final onboarding = ref.watch(onboardingDoneProvider);
  final lock = ref.watch(lockControllerProvider);
  if (!onboarding.hasValue || lock == LockStatus.unknown) return _Cover.splash;
  if (onboarding.requireValue == false) return _Cover.onboarding;
  if (lock == LockStatus.locked) return _Cover.lock;
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
