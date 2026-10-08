import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/features/backup/data/backup_providers.dart';
import 'package:tution_tracker/features/backup/domain/backup_exception.dart';
import 'package:tution_tracker/features/backup/presentation/backup_dialogs.dart';
import 'package:tution_tracker/features/backup/presentation/backup_labels.dart';
import 'package:tution_tracker/features/lock/data/app_lock_service.dart';
import 'package:tution_tracker/features/lock/data/lock_controller.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Covers the whole app until the PIN (or fingerprint) is given.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _entered = '';
  int _length = 4;
  String? _error;
  DateTime? _blockedUntil;
  Timer? _ticker;
  bool _checking = false;
  bool _biometric = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final service = ref.read(appLockServiceProvider);
    final length = await service.pinLength();
    final settings = await service.settings();
    final blocked = await service.blockedUntil();
    if (!mounted) return;
    setState(() {
      _length = length ?? 4;
      _biometric = settings.biometric;
      _blockedUntil = blocked;
    });
    if (blocked != null) _startTicker();
    if (settings.biometric && blocked == null) {
      // Offer it straight away; the keypad stays there as the fallback.
      await _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    final reason = AppLocalizations.of(context).lockBiometricReason;
    await ref.read(lockControllerProvider.notifier).unlockWithBiometric(reason);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final until = _blockedUntil;
      if (until == null) return;
      if (!until.isAfter(ref.read(clockProvider)())) {
        _ticker?.cancel();
        setState(() => _blockedUntil = null);
      } else {
        setState(() {});
      }
    });
  }

  Future<void> _press(String digit) async {
    if (_checking || _blockedUntil != null || _entered.length >= _length) {
      return;
    }
    setState(() {
      _entered += digit;
      _error = null;
    });
    if (_entered.length == _length) await _submit();
  }

  Future<void> _submit() async {
    setState(() => _checking = true);
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(lockControllerProvider.notifier)
        .unlockWithPin(_entered);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _entered = '';
      switch (result) {
        case PinCorrect():
          break;
        case PinWrong(:final attemptsLeft):
          _error = l10n.lockWrong(
            formatCount(attemptsLeft, ref.read(_numerals)),
          );
        case PinBlocked(:final until):
          _blockedUntil = until;
          _error = null;
          _startTicker();
      }
    });
  }

  void _back() {
    if (_entered.isNotEmpty && !_checking) {
      setState(() => _entered = _entered.substring(0, _entered.length - 1));
    }
  }

  Future<void> _forgot() async {
    final l10n = AppLocalizations.of(context);
    final first = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.lockForgot),
        content: Text(l10n.lockForgotBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.rstContinue),
          ),
        ],
      ),
    );
    if (first != true || !mounted) return;
    final second = await showDialog<bool>(
      context: context,
      builder: (_) => const TypeToConfirmDialog(),
    );
    if (second != true || !mounted) return;
    try {
      final restore = await ref.read(restoreServiceProvider.future);
      await restore.resetToEmpty();
      await ref.read(appLockServiceProvider).disable();
      await ref.read(lockControllerProvider.notifier).settingsChanged();
    } on BackupException catch (e) {
      if (!mounted) return;
      await showMessage(
        context,
        l10n.rstTitle,
        backupProblemText(l10n, e.problem),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final numerals = ref.watch(_numerals);
    final blocked = _blockedUntil;
    final seconds = blocked == null
        ? 0
        : (blocked.difference(ref.read(clockProvider)()).inMilliseconds +
                  999) ~/
              1000;

    // [blank] leaves the space empty (no fingerprint on this phone); a key
    // that is only switched off stays visible, greyed out.
    Widget key(
      String label, {
      VoidCallback? onTap,
      IconData? icon,
      bool blank = false,
    }) => Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 72,
        height: 72,
        child: blank
            ? const SizedBox.shrink()
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                ),
                child: icon != null
                    ? Icon(icon)
                    : Text(label, style: theme.textTheme.headlineSmall),
              ),
      ),
    );

    final enabled = blocked == null && !_checking;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.lockEnterPin, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _length; i++)
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _entered.length
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: 48,
                    child: Center(
                      child: Text(
                        blocked != null
                            ? l10n.lockBlocked(formatCount(seconds, numerals))
                            : _error ?? '',
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  for (final row in const [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final d in row)
                          key(
                            applyNumerals(d, numerals),
                            onTap: enabled ? () => _press(d) : null,
                          ),
                      ],
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      key(
                        '',
                        icon: Icons.fingerprint,
                        blank: !_biometric,
                        onTap: _biometric && enabled ? _tryBiometric : null,
                      ),
                      key(
                        applyNumerals('0', numerals),
                        onTap: enabled ? () => _press('0') : null,
                      ),
                      key('', icon: Icons.backspace_outlined, onTap: _back),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _forgot, child: Text(l10n.lockForgot)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final _numerals = Provider.autoDispose<NumeralStyle>(
  (ref) => ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla,
);
