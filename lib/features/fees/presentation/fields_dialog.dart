import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/i18n/digits.dart';
import 'package:tution_tracker/core/ui/input_formatters.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// One text input in a [FieldsDialog].
class DialogField {
  const DialogField({
    required this.key,
    required this.label,
    this.numeric = false,
    this.required = true,
    this.initial = '',
    this.helper,
    this.max,
    this.requiredMessage,
  });

  final String key;
  final String label;

  /// Digits only (Bangla digits accepted); the value is returned as ASCII.
  final bool numeric;
  final bool required;
  final String initial;
  final String? helper;

  /// Largest allowed number, for numeric fields.
  final int? max;
  final String? requiredMessage;
}

class FieldsResult {
  const FieldsResult(this.values, this.month);

  final Map<String, String> values;
  final YearMonth? month;

  int intValue(String key) => int.parse(values[key]!);
}

/// A small form in a dialog: a few text fields and, optionally, a month
/// picker. It owns its controllers, so they are disposed only after the
/// dialog has fully gone (disposing them early crashes the closing animation).
class FieldsDialog extends StatefulWidget {
  const FieldsDialog({
    required this.title,
    required this.fields,
    this.months,
    this.monthLabel,
    this.initialMonth,
    this.monthText,
    this.message,
    super.key,
  });

  final String title;
  final List<DialogField> fields;
  final String? message;

  /// Months to choose from, with [initialMonth] preselected.
  final List<YearMonth>? months;
  final String? monthLabel;
  final YearMonth? initialMonth;

  /// How to show a month in the picker.
  final String Function(YearMonth month)? monthText;

  @override
  State<FieldsDialog> createState() => _FieldsDialogState();
}

class _FieldsDialogState extends State<FieldsDialog> {
  late final Map<String, TextEditingController> _controllers = {
    for (final f in widget.fields)
      f.key: TextEditingController(text: f.initial),
  };
  final Map<String, String?> _errors = {};
  late YearMonth? _month = widget.initialMonth;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final values = <String, String>{};
    final errors = <String, String?>{};
    for (final f in widget.fields) {
      var text = _controllers[f.key]!.text.trim();
      if (f.numeric) text = toWesternDigits(text);
      if (text.isEmpty && f.required) {
        errors[f.key] = f.requiredMessage ?? l10n.payAmountRequired;
      } else if (f.numeric && text.isNotEmpty) {
        final n = int.tryParse(text);
        if (n == null || (f.max != null && n > f.max!)) {
          errors[f.key] = f.requiredMessage ?? l10n.payAmountRequired;
        }
      }
      values[f.key] = text;
    }
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    if (errors.isEmpty) Navigator.pop(context, FieldsResult(values, _month));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.message != null) ...[
              Text(widget.message!),
              const SizedBox(height: 12),
            ],
            if (widget.months != null) ...[
              DropdownButtonFormField<YearMonth>(
                initialValue: _month,
                decoration: InputDecoration(
                  labelText: widget.monthLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final m in widget.months!)
                    DropdownMenuItem(
                      value: m,
                      child: Text(widget.monthText?.call(m) ?? m.toKey()),
                    ),
                ],
                onChanged: (m) => setState(() => _month = m),
              ),
              const SizedBox(height: 12),
            ],
            for (final f in widget.fields) ...[
              TextField(
                controller: _controllers[f.key],
                autofocus: f == widget.fields.first && widget.months == null,
                keyboardType: f.numeric
                    ? TextInputType.number
                    : TextInputType.text,
                inputFormatters: f.numeric
                    ? [
                        const DigitsOnlyFormatter(),
                        LengthLimitingTextInputFormatter(8),
                      ]
                    : null,
                decoration: InputDecoration(
                  labelText: f.label,
                  helperText: f.helper,
                  errorText: _errors[f.key],
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
            ],
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
