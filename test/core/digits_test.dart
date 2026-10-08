import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/i18n/digits.dart';

void main() {
  test('converts every digit to Bangla', () {
    expect(toBanglaDigits('0123456789'), '০১২৩৪৫৬৭৮৯');
  });

  test('leaves other characters alone', () {
    expect(toBanglaDigits('৳ 1,250.50 abc'), '৳ ১,২৫০.৫০ abc');
    expect(toBanglaDigits(''), '');
  });

  test('converts Bangla digits back to western', () {
    expect(toWesternDigits('০১২৩৪৫৬৭৮৯'), '0123456789');
    expect(toWesternDigits('০১৭১২-৩৪৫৬৭৮'), '01712-345678');
  });

  test('round trips', () {
    expect(toWesternDigits(toBanglaDigits('2026-10-06')), '2026-10-06');
  });
}
