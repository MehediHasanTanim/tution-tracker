import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Shows a spinner with [message] while [work] runs; the tutor cannot dismiss
/// it. Used for the steps that must not be interrupted.
Future<T> runWithProgress<T>(
  BuildContext context,
  String message,
  Future<T> Function() work,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  // Not awaited: the dialog stays until the work is done.
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await work();
  } finally {
    if (navigator.canPop()) navigator.pop();
  }
}

/// Asks for a password. With [confirm] it asks twice and checks they match
/// and are long enough (for making a protected backup); without, once (for
/// opening one). [error] is shown under the field, e.g. after a wrong try.
Future<String?> askPassword(
  BuildContext context, {
  required String title,
  bool confirm = false,
  String? error,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) =>
        _PasswordDialog(title: title, confirm: confirm, error: error),
  );
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({
    required this.title,
    required this.confirm,
    this.error,
  });

  final String title;
  final bool confirm;
  final String? error;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  String? _problem;
  bool _show = false;

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
      if (_first.text.length < 6) {
        setState(() => _problem = l10n.bkPasswordShort);
        return;
      }
      if (_first.text != _second.text) {
        setState(() => _problem = l10n.bkPasswordMismatch);
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
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _first,
              autofocus: true,
              obscureText: !_show,
              decoration: InputDecoration(
                labelText: l10n.bkPassword,
                suffixIcon: IconButton(
                  icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _show = !_show),
                ),
              ),
              onSubmitted: widget.confirm ? null : (_) => _submit(),
            ),
            if (widget.confirm)
              TextField(
                controller: _second,
                obscureText: !_show,
                decoration: InputDecoration(labelText: l10n.bkPasswordConfirm),
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

/// A plain message the tutor must acknowledge.
Future<void> showMessage(BuildContext context, String title, String body) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.payDone),
        ),
      ],
    ),
  );
}
