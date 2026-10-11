import 'package:flutter/material.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_widgets.dart';
import 'package:tution_tracker/features/fees/domain/fee_status.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// The handoff's status colours: paid is sage, partial a terracotta tint, due
/// a neutral pill and overdue solid deep terracotta, so the one that needs
/// action stands out most.
(String, Color, Color) feeStatusStyle(
  FeeStatus status,
  AppLocalizations l10n,
  Organic o,
) => switch (status) {
  FeeStatus.paid => (l10n.statusPaid, o.sageSoft, o.onSageSoft),
  FeeStatus.partial => (l10n.statusPartial, o.accentSoft, o.onAccentSoft),
  FeeStatus.due => (l10n.statusDue, o.neutralSoft, o.onNeutralSoft),
  FeeStatus.overdue => (l10n.statusOverdue, o.accentStrong, Colors.white),
  FeeStatus.waived => (l10n.statusWaived, o.raised, o.muted),
};

class FeeStatusPill extends StatelessWidget {
  const FeeStatusPill(this.status, {super.key});

  final FeeStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = feeStatusStyle(
      status,
      AppLocalizations.of(context),
      Organic.of(context),
    );
    return StatusPill(label: label, background: bg, foreground: fg);
  }
}
