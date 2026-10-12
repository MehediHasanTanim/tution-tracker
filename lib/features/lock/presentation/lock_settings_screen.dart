import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/platform/biometric_auth.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
import 'package:tution_tracker/features/lock/data/app_lock_service.dart';
import 'package:tution_tracker/features/lock/data/lock_controller.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Turns the app lock on and off and sets how it behaves (spec SE-6).
class LockSettingsScreen extends ConsumerStatefulWidget {
  const LockSettingsScreen({super.key});

  @override
  ConsumerState<LockSettingsScreen> createState() => _LockSettingsScreenState();
}

class _LockSettingsScreenState extends ConsumerState<LockSettingsScreen> {
  LockSettings? _settings;
  bool _biometricAvailable = false;

  AppLockService get _service => ref.read(appLockServiceProvider);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final settings = await _service.settings();
    final available = await ref.read(biometricAuthProvider).isAvailable();
    if (mounted) {
      setState(() {
        _settings = settings;
        _biometricAvailable = available;
      });
    }
  }

  Future<void> _changed() async {
    await ref.read(lockControllerProvider.notifier).settingsChanged();
    await _reload();
  }

  Future<void> _turnOn() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final pin = await _askNewPin(l10n.lockSetPin);
    if (pin == null) return;
    await _service.enable(pin);
    await _changed();
    messenger.showSnackBar(SnackBar(content: Text(l10n.lockOnDone)));
  }

  Future<void> _changePin() async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirmCurrentPin()) return;
    if (!mounted) return;
    final pin = await _askNewPin(l10n.lockChangePin);
    if (pin == null) return;
    await _service.changePin(pin);
    await _changed();
  }

  Future<void> _turnOff() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await _confirmCurrentPin()) return;
    await _service.disable();
    await _changed();
    messenger.showSnackBar(SnackBar(content: Text(l10n.lockOffDone)));
  }

  /// Asks for the current PIN; false when cancelled or wrong.
  Future<bool> _confirmCurrentPin() async {
    final l10n = AppLocalizations.of(context);
    var error = false;
    while (true) {
      if (!mounted) return false;
      final pin = await showDialog<String>(
        context: context,
        builder: (_) => _PinDialog(
          title: l10n.lockCurrentPin,
          error: error ? l10n.lockWrongCurrent : null,
        ),
      );
      if (pin == null) return false;
      if (await _service.verify(pin) is PinCorrect) return true;
      error = true;
    }
  }

  /// Asks for a new PIN twice. Null when cancelled.
  Future<String?> _askNewPin(String title) {
    return showDialog<String>(
      context: context,
      builder: (_) => _PinDialog(title: title, confirm: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final s = _settings;

    String timeoutLabel(Duration d) => d == Duration.zero
        ? l10n.lockTimeoutNow
        : l10n.lockTimeoutMinutes(formatCount(d.inMinutes, numerals));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lockSettingsTitle)),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                BlockStack(
                  children: [
                    BlockToggle(
                      label: l10n.lockOn,
                      subtitle: l10n.lockSettingsHint,
                      value: s.enabled,
                      onChanged: (on) => on ? _turnOn() : _turnOff(),
                    ),
                    if (s.enabled) ...[
                      BlockToggle(
                        label: l10n.lockBiometricOn,
                        subtitle: _biometricAvailable
                            ? null
                            : l10n.lockBiometricNone,
                        value: s.biometric && _biometricAvailable,
                        onChanged: _biometricAvailable
                            ? (v) async {
                                await _service.setBiometric(enabled: v);
                                await _reload();
                              }
                            : null,
                      ),
                      BlockToggle(
                        label: l10n.lockProtect,
                        value: s.protectScreen,
                        onChanged: (v) async {
                          await _service.setProtectScreen(enabled: v);
                          await _changed();
                        },
                      ),
                      BlockSubheading(l10n.lockTimeout),
                      BlockChips<Duration>(
                        options: [
                          for (final d in const [
                            Duration.zero,
                            Duration(minutes: 1),
                            Duration(minutes: 5),
                            Duration(minutes: 15),
                          ])
                            (d, timeoutLabel(d)),
                        ],
                        isSelected: (d) => d == s.timeout,
                        onTap: (d) async {
                          await _service.setTimeout(d);
                          await _reload();
                        },
                      ),
                      BlockButton(
                        l10n.lockChangePin,
                        kind: BlockButtonKind.outlined,
                        onPressed: _changePin,
                      ),
                    ],
                    BlockText(l10n.lockRemember),
                  ],
                ),
              ],
            ),
    );
  }
}

/// A PIN entry dialog. With [confirm] it asks twice and checks the two match
/// and are 4 to 8 digits.
class _PinDialog extends StatefulWidget {
  const _PinDialog({required this.title, this.confirm = false, this.error});

  final String title;
  final bool confirm;
  final String? error;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  String? _problem;

  @override
  void initState() {
    super.initState();
    _problem = widget.error;
  }

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    if (widget.confirm) {
      if (!AppLockService.isValidPin(_first.text)) {
        setState(() => _problem = l10n.lockPinInvalid);
        return;
      }
      if (_first.text != _second.text) {
        setState(() => _problem = l10n.lockPinMismatch);
        return;
      }
    } else if (_first.text.isEmpty) {
      return;
    }
    Navigator.pop(context, _first.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    InputDecoration deco(String label, [String? hint]) =>
        InputDecoration(labelText: label, helperText: hint, counterText: '');
    const digits = TextInputType.number;
    final formatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(AppLockService.maxPinLength),
    ];
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _first,
              autofocus: true,
              obscureText: true,
              keyboardType: digits,
              inputFormatters: formatters,
              decoration: deco(
                widget.confirm ? l10n.lockSetPin : l10n.lockEnterPin,
                widget.confirm ? l10n.lockPinHint : null,
              ),
              onSubmitted: widget.confirm ? null : (_) => _submit(),
            ),
            if (widget.confirm)
              TextField(
                controller: _second,
                obscureText: true,
                keyboardType: digits,
                inputFormatters: formatters,
                decoration: deco(l10n.lockPinAgain),
                onSubmitted: (_) => _submit(),
              ),
            if (_problem != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _problem!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.actionSave)),
      ],
    );
  }
}
