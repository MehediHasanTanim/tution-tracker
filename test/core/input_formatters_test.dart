import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/ui/input_formatters.dart';

TextEditingValue _type(TextInputFormatter f, String text) =>
    f.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));

void main() {
  test('digits only keeps digits and converts Bangla digits', () {
    const f = DigitsOnlyFormatter();
    expect(_type(f, '১৫০০').text, '1500');
    expect(_type(f, '12a,5 0').text, '1250');
    expect(_type(f, '').text, '');
    expect(_type(f, '১২৩').selection.baseOffset, 3);
  });

  test('phone keeps digits, plus, dash and space; converts Bangla digits', () {
    const f = PhoneInputFormatter();
    expect(_type(f, '০১৭১২-৩৪৫ ৬৭৮').text, '01712-345 678');
    expect(_type(f, '+880 (17)x12').text, '+880 1712');
  });
}
