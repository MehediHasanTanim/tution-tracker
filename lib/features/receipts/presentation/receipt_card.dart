import 'package:flutter/material.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/theme/app_theme.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/features/fees/presentation/payment_labels.dart';
import 'package:tution_tracker/features/receipts/domain/receipt_data.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Logical width of the receipt. Fixed so a shared image looks the same on
/// every phone.
const receiptWidth = 360.0;

/// A receipt as it is shared: always black on white whatever the app theme.
///
/// Drawn with Flutter's own text engine, which shapes Bangla conjuncts
/// correctly (the `pdf` package cannot), then captured as an image.
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({
    required this.data,
    required this.tutor,
    required this.language,
    required this.numerals,
    required this.grouping,
    super.key,
  });

  final ReceiptData data;
  final TutorProfile tutor;
  final AppLanguage language;
  final NumeralStyle numerals;
  final GroupingStyle grouping;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final base = AppTheme.light();
    final text = base.textTheme.apply(
      bodyColor: OrganicPalette.text,
      displayColor: OrganicPalette.text,
    );

    String money(int a) =>
        formatTaka(Taka(a), numerals: numerals, grouping: grouping);

    String lineLabel(ReceiptLine line) {
      if (line.isCredit) return l10n.payCreditLine;
      final month = formatMonth(
        line.month!,
        language: language,
        numerals: numerals,
      );
      return line.label == null ? month : '${line.label} ($month)';
    }

    final title = tutor.title.isNotEmpty ? tutor.title : l10n.appTitle;
    final tutorLine = [
      if (tutor.name.isNotEmpty && tutor.name != title) tutor.name,
      if (tutor.phone.isNotEmpty) applyNumerals(tutor.phone, numerals),
    ];
    const ink = OrganicPalette.text;
    const muted = _ReceiptColors.muted;
    const dashed = _DashedRule();

    return Theme(
      data: base,
      child: DefaultTextStyle(
        style: text.bodyMedium!.copyWith(color: ink),
        child: Container(
          width: receiptWidth,
          // Always the light paper, whatever the app theme: it is shared.
          color: _ReceiptColors.paper,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brand: a terracotta tick badge, the tutor, and the kind.
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: OrganicPalette.accent500,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: _ReceiptColors.paper,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: text.titleLarge!.copyWith(
                            color: ink,
                            height: 1.2,
                          ),
                        ),
                        for (final t in tutorLine)
                          Text(
                            t,
                            style: const TextStyle(fontSize: 13, color: muted),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.receiptTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _ReceiptColors.kind,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              dashed,
              const SizedBox(height: 12),
              DefaultTextStyle.merge(
                style: const TextStyle(fontSize: 13, color: muted),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.payReceiptNo(formatCount(data.receiptNo, numerals)),
                    ),
                    Text(
                      formatDate(
                        data.date,
                        language: language,
                        numerals: numerals,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Pair(l10n.receiptStudent, data.studentName),
              if (data.guardianName != null)
                _Pair(l10n.receiptGuardian, data.guardianName!),
              _Pair(l10n.payMethod, paymentMethodLabel(l10n, data.method)),
              if (data.reference != null)
                _Pair(l10n.payReference, data.reference!),
              const SizedBox(height: 6),
              Text(
                l10n.receiptFor,
                style: const TextStyle(fontSize: 13, color: muted),
              ),
              for (final line in data.lines)
                _Pair(lineLabel(line), money(line.amount), end: true),
              const SizedBox(height: 14),
              dashed,
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.receiptTotal,
                          style: const TextStyle(fontSize: 13, color: muted),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            money(data.amount),
                            style: text.displaySmall!.copyWith(
                              color: ink,
                              fontSize: 36,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // The sage "paid" stamp, set at a slight angle.
                  Transform.rotate(
                    angle: -0.17,
                    child: Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: OrganicPalette.sage500,
                          width: 3,
                        ),
                      ),
                      child: Text(
                        l10n.statusPaid,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: OrganicPalette.sage700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${l10n.receiptThanks} · ${l10n.appTitle}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The receipt's own paper and ink, fixed so a shared receipt looks the same
/// from any phone.
abstract final class _ReceiptColors {
  static const paper = Color(0xFFFBF3E3);
  static const muted = Color(0xFF6B625A);
  static const kind = Color(0xFF8F4A1F);
  static const rule = Color(0xFFD9C9AA);
}

/// The receipt's dashed separator.
class _DashedRule extends StatelessWidget {
  const _DashedRule();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 2,
    width: double.infinity,
    child: CustomPaint(painter: _DashPainter()),
  );
}

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _ReceiptColors.rule
      ..strokeWidth = 2;
    for (var x = 0.0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, 1), Offset(x + 6, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => false;
}

/// A label and its value; a long value wraps instead of being cut off.
class _Pair extends StatelessWidget {
  const _Pair(this.label, this.value, {this.end = false});

  final String label;
  final String value;

  /// Value pushed to the end (amounts), rather than in a column.
  final bool end;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: _ReceiptColors.muted),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: end ? 1 : 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
