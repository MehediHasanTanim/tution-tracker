import 'package:flutter/material.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/theme/app_theme.dart';
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
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
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

    return Theme(
      data: base,
      child: DefaultTextStyle(
        style: text.bodyMedium!,
        child: Container(
          width: receiptWidth,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: text.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              if (tutor.name.isNotEmpty && tutor.name != title)
                Text(tutor.name, textAlign: TextAlign.center),
              if (tutor.phone.isNotEmpty)
                Text(
                  applyNumerals(tutor.phone, numerals),
                  textAlign: TextAlign.center,
                ),
              const Divider(height: 24, color: Colors.black26),
              Text(
                l10n.receiptTitle,
                textAlign: TextAlign.center,
                style: text.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
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
              const SizedBox(height: 12),
              _Pair(l10n.receiptStudent, data.studentName),
              if (data.guardianName != null)
                _Pair(l10n.receiptGuardian, data.guardianName!),
              const Divider(height: 24, color: Colors.black26),
              Text(
                l10n.receiptFor,
                style: text.labelMedium!.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 4),
              for (final line in data.lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(lineLabel(line))),
                      const SizedBox(width: 12),
                      Text(money(line.amount)),
                    ],
                  ),
                ),
              const Divider(height: 24, color: Colors.black26),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      l10n.receiptTotal,
                      style: text.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    money(data.amount),
                    style: text.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Pair(l10n.payMethod, paymentMethodLabel(l10n, data.method)),
              if (data.reference != null)
                _Pair(l10n.payReference, data.reference!),
              const SizedBox(height: 16),
              Text(
                l10n.receiptThanks,
                textAlign: TextAlign.center,
                style: text.bodyMedium!.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A label and its value; a long value wraps instead of being cut off.
class _Pair extends StatelessWidget {
  const _Pair(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
