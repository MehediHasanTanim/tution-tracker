import 'package:flutter/material.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Why a class is off: a public holiday is recorded as a holiday, anything
/// else as a cancelled class with the reason as its note (spec AT-4).
enum OffReason { holiday, tutorUnwell, exams, other }

/// The design's "Mark class off" sheet: a reason chip, then confirm.
/// Returns the status and the note to save, or null if the tutor backs out.
Future<({SessionStatus status, String? note})?> showMarkOffSheet(
  BuildContext context,
) {
  return showBlockSheet(context, builder: (_) => const _MarkOffSheet());
}

class _MarkOffSheet extends StatefulWidget {
  const _MarkOffSheet();

  @override
  State<_MarkOffSheet> createState() => _MarkOffSheetState();
}

class _MarkOffSheetState extends State<_MarkOffSheet> {
  OffReason _reason = OffReason.holiday;
  final _other = TextEditingController();

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  String _label(AppLocalizations l10n, OffReason r) => switch (r) {
    OffReason.holiday => l10n.offPublicHoliday,
    OffReason.tutorUnwell => l10n.offTutorUnwell,
    OffReason.exams => l10n.offExams,
    OffReason.other => l10n.offOther,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlockStack(
      children: [
        BlockSubheading(l10n.offTitle),
        BlockText(l10n.offBody),
        BlockChips<OffReason>(
          options: [for (final r in OffReason.values) (r, _label(l10n, r))],
          isSelected: (r) => r == _reason,
          onTap: (r) => setState(() => _reason = r),
        ),
        if (_reason == OffReason.other)
          TextField(
            controller: _other,
            decoration: InputDecoration(labelText: l10n.attReason),
          ),
        BlockButton(
          l10n.offConfirm,
          kind: BlockButtonKind.danger,
          onPressed: () {
            final note = switch (_reason) {
              OffReason.holiday => null,
              OffReason.other =>
                _other.text.trim().isEmpty ? null : _other.text.trim(),
              _ => _label(l10n, _reason),
            };
            Navigator.pop(context, (
              status: _reason == OffReason.holiday
                  ? SessionStatus.holiday
                  : SessionStatus.cancelled,
              note: note,
            ));
          },
        ),
        BlockButton(
          l10n.offNever,
          kind: BlockButtonKind.ghost,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
