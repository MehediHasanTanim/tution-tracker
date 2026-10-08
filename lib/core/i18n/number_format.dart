import 'package:tution_tracker/core/i18n/digits.dart';
import 'package:tution_tracker/core/money/taka.dart';

enum NumeralStyle { western, bangla }

/// How digits are grouped in money amounts.
enum GroupingStyle {
  /// 1,234,567
  western,

  /// 12,34,567 (lakh/crore), common in Bangladesh.
  lakh,
}

/// Formats an integer with thousands separators in the given [grouping].
/// Output uses ASCII digits; apply [applyNumerals] for Bangla digits.
String groupDigits(int value, GroupingStyle grouping) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final String grouped;
  if (digits.length <= 3) {
    grouped = digits;
  } else {
    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    final size = grouping == GroupingStyle.lakh ? 2 : 3;
    final parts = <String>[];
    for (var end = head.length; end > 0; end -= size) {
      parts.add(head.substring(end - size < 0 ? 0 : end - size, end));
    }
    grouped = '${parts.reversed.join(',')},$tail';
  }
  return negative ? '-$grouped' : grouped;
}

String applyNumerals(String text, NumeralStyle style) =>
    style == NumeralStyle.bangla ? toBanglaDigits(text) : text;

/// Money amounts, e.g. `৳ ১২,৫০০` or `৳ 12,500`.
String formatTaka(
  Taka amount, {
  required NumeralStyle numerals,
  required GroupingStyle grouping,
}) {
  final text = groupDigits(amount.value, grouping);
  return '৳ ${applyNumerals(text, numerals)}';
}

/// Plain counts (students, classes) without grouping.
String formatCount(int value, NumeralStyle numerals) =>
    applyNumerals(value.toString(), numerals);
