import 'package:tution_tracker/core/i18n/digits.dart';

/// A validated Bangladeshi mobile number.
class BdPhone {
  const BdPhone._(this._subscriber);

  /// The ten digits after the leading 0, e.g. `1712345678`.
  final String _subscriber;

  /// `01712345678`, the form tutors type and see.
  String get local => '0$_subscriber';

  /// `+8801712345678`, for `tel:` and `sms:` links.
  String get e164 => '+880$_subscriber';

  /// `8801712345678`, as `wa.me` links require (no plus sign).
  String get whatsapp => '880$_subscriber';

  @override
  bool operator ==(Object other) =>
      other is BdPhone && other._subscriber == _subscriber;

  @override
  int get hashCode => _subscriber.hashCode;

  @override
  String toString() => local;
}

/// Parses `01XXXXXXXXX`, `+8801XXXXXXXXX`, `8801XXXXXXXXX` (also `008801…`),
/// with spaces, dashes, dots or parentheses, and Bangla digits.
/// Returns null when the input is not a valid mobile number (operator
/// codes 013 to 019).
BdPhone? parseBdPhone(String input) {
  var s = toWesternDigits(input).replaceAll(RegExp(r'[\s\-.()]'), '');
  if (s.startsWith('+')) s = s.substring(1);
  if (s.startsWith('00')) s = s.substring(2);
  if (s.startsWith('880')) s = s.substring(3);
  if (s.startsWith('0')) s = s.substring(1);
  // Now the subscriber part: 1[3-9] plus eight digits.
  if (!RegExp(r'^1[3-9]\d{8}$').hasMatch(s)) return null;
  return BdPhone._(s);
}

/// Empty input is allowed (phones are optional); otherwise must parse.
bool isValidOptionalPhone(String input) =>
    input.trim().isEmpty || parseBdPhone(input) != null;
