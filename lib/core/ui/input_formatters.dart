import 'package:flutter/services.dart';
import 'package:tution_tracker/core/i18n/digits.dart';

/// Keeps only digits, accepting Bangla digits typed on a Bangla keyboard and
/// storing them as ASCII.
class DigitsOnlyFormatter extends TextInputFormatter {
  const DigitsOnlyFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = toWesternDigits(newValue.text)
        .replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned == newValue.text) return newValue;
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}

/// Phone input: digits (Bangla converted), `+`, spaces and dashes.
class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = toWesternDigits(newValue.text)
        .replaceAll(RegExp(r'[^0-9+\- ]'), '');
    if (cleaned == newValue.text) return newValue;
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}
