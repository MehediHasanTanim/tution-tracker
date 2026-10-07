import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/utils/phone.dart';

void main() {
  group('accepted formats normalise to the same number', () {
    for (final input in [
      '01712345678',
      '+8801712345678',
      '8801712345678',
      '008801712345678',
      '017 1234 5678',
      '01712-345678',
      '+880 1712-345678',
      ' (01712) 345678 ',
      '০১৭১২৩৪৫৬৭৮',
      '+৮৮০১৭১২৩৪৫৬৭৮',
    ]) {
      test(input, () {
        final phone = parseBdPhone(input);
        expect(phone, isNotNull);
        expect(phone!.local, '01712345678');
        expect(phone.e164, '+8801712345678');
        expect(phone.whatsapp, '8801712345678');
      });
    }
  });

  group('rejected input', () {
    for (final input in [
      '',
      '0171234567', // too short
      '017123456789', // too long
      '02123456789', // not a mobile prefix
      '01212345678', // operator code 012 does not exist
      '01012345678', // operator code 010 does not exist
      '+8801712345', // truncated
      '+441712345678', // other country
      'abc',
      '0171234567a',
    ]) {
      test('"$input"', () => expect(parseBdPhone(input), isNull));
    }
  });

  test('every valid operator prefix 013 to 019 is accepted', () {
    for (var op = 13; op <= 19; op++) {
      expect(parseBdPhone('0${op}12345678'), isNotNull, reason: '0$op');
    }
  });

  test('equality', () {
    expect(parseBdPhone('01712345678'), parseBdPhone('+880 1712-345678'));
  });

  test('optional phone validation allows empty', () {
    expect(isValidOptionalPhone(''), isTrue);
    expect(isValidOptionalPhone('   '), isTrue);
    expect(isValidOptionalPhone('01712345678'), isTrue);
    expect(isValidOptionalPhone('12345'), isFalse);
  });
}
