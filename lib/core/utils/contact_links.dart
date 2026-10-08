import 'package:tution_tracker/core/utils/phone.dart';

/// Links that open the phone, messaging and WhatsApp apps (design 9.4).
/// The app only opens the compose screen; the user taps send, so no SMS
/// permission is needed.
abstract final class ContactLinks {
  /// `tel:+8801712345678`
  static Uri call(BdPhone phone) => Uri.parse('tel:${phone.e164}');

  /// `sms:+8801712345678`, with an optional prefilled [body].
  static Uri sms(BdPhone phone, {String? body}) =>
      Uri.parse('sms:${phone.e164}${_query('body', body)}');

  /// `https://wa.me/8801712345678`, with an optional prefilled [text].
  /// wa.me wants the number without the plus sign.
  static Uri whatsapp(BdPhone phone, {String? text}) =>
      Uri.parse('https://wa.me/${phone.whatsapp}${_query('text', text)}');

  // Percent-encode with %20 for spaces: some Android SMS apps show a literal
  // "+" if the body uses form encoding.
  static String _query(String key, String? value) =>
      value == null || value.isEmpty
      ? ''
      : '?$key=${Uri.encodeComponent(value)}';
}
