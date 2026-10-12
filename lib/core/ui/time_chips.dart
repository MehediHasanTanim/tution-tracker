import 'package:flutter/material.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// The design's time chips: common class times, plus any other time and no
/// time at all.
class ClassTimeChips extends StatelessWidget {
  const ClassTimeChips({
    super.key,
    required this.value,
    required this.language,
    required this.numerals,
    required this.onChanged,
  });

  final ClockTime? value;
  final AppLanguage language;
  final NumeralStyle numerals;
  final ValueChanged<ClockTime?> onChanged;

  static const presets = [
    ClockTime(8, 0),
    ClockTime(10, 0),
    ClockTime(15, 30),
    ClockTime(17, 0),
    ClockTime(18, 30),
    ClockTime(19, 0),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String label(ClockTime t) {
      final p = formatClockParts(t, language: language, numerals: numerals);
      return '${p.time} ${p.period}';
    }

    final custom = value != null && !presets.contains(value);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in presets)
          ChoiceChip(
            label: Text(label(t)),
            selected: value == t,
            onSelected: (_) => onChanged(t),
          ),
        ChoiceChip(
          label: Text(custom ? label(value!) : l10n.timeOther),
          selected: custom,
          onSelected: (_) async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: value?.hour ?? 17,
                minute: value?.minute ?? 0,
              ),
            );
            if (picked != null) {
              onChanged(ClockTime(picked.hour, picked.minute));
            }
          },
        ),
        ChoiceChip(
          label: Text(l10n.none),
          selected: value == null,
          onSelected: (_) => onChanged(null),
        ),
      ],
    );
  }
}
