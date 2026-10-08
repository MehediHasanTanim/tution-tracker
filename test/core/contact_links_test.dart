import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/utils/contact_links.dart';
import 'package:tution_tracker/core/utils/phone.dart';

void main() {
  final phone = parseBdPhone('01712-345678')!;

  test('call opens the dialer with the international number', () {
    expect(ContactLinks.call(phone).toString(), 'tel:+8801712345678');
  });

  test('sms targets the international number', () {
    final uri = ContactLinks.sms(phone);
    expect(uri.scheme, 'sms');
    expect(uri.toString(), 'sms:+8801712345678');
  });

  test('whatsapp uses wa.me with the number and no plus sign', () {
    final uri = ContactLinks.whatsapp(phone);
    expect(uri.toString(), 'https://wa.me/8801712345678');
    expect(uri.host, 'wa.me');
    expect(uri.path, '/8801712345678');
  });

  test('every accepted input format yields the same links', () {
    for (final input in [
      '01712345678',
      '+8801712345678',
      '8801712345678',
      '০১৭১২৩৪৫৬৭৮',
    ]) {
      final p = parseBdPhone(input)!;
      expect(
        ContactLinks.whatsapp(p).toString(),
        'https://wa.me/8801712345678',
      );
      expect(ContactLinks.sms(p).toString(), 'sms:+8801712345678');
    }
  });

  test('prefilled text is percent-encoded, Bangla and spaces included', () {
    const body = 'রহিমের ফি: ১,৫০০ টাকা & বাকি';
    final sms = ContactLinks.sms(phone, body: body);
    expect(sms.toString(), startsWith('sms:+8801712345678?body='));
    expect(sms.toString(), isNot(contains(' ')));
    expect(sms.toString(), contains('%20'));
    expect(sms.toString(), isNot(contains('+0')));
    expect(Uri.decodeComponent(sms.query.substring('body='.length)), body);

    final wa = ContactLinks.whatsapp(phone, text: body);
    expect(wa.queryParameters['text'], body);
    expect(wa.toString(), contains('%26')); // ampersand escaped
  });

  test('empty text adds no query', () {
    expect(ContactLinks.sms(phone, body: '').toString(), 'sms:+8801712345678');
    expect(
      ContactLinks.whatsapp(phone, text: '').toString(),
      'https://wa.me/8801712345678',
    );
  });
}
