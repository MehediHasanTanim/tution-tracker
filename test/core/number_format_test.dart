import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';

String _taka(int v, NumeralStyle n, GroupingStyle g) =>
    formatTaka(Taka(v), numerals: n, grouping: g);

void main() {
  group('lakh grouping', () {
    const g = GroupingStyle.lakh;
    test('boundaries', () {
      expect(groupDigits(0, g), '0');
      expect(groupDigits(999, g), '999');
      expect(groupDigits(1000, g), '1,000');
      expect(groupDigits(12500, g), '12,500');
      expect(groupDigits(99999, g), '99,999');
      expect(groupDigits(100000, g), '1,00,000');
      expect(groupDigits(125000, g), '1,25,000');
      expect(groupDigits(1234567, g), '12,34,567');
      expect(groupDigits(12345678, g), '1,23,45,678');
    });

    test('negative', () {
      expect(groupDigits(-125000, g), '-1,25,000');
      expect(groupDigits(-500, g), '-500');
    });
  });

  group('western grouping', () {
    const g = GroupingStyle.western;
    test('boundaries', () {
      expect(groupDigits(999, g), '999');
      expect(groupDigits(1000, g), '1,000');
      expect(groupDigits(125000, g), '125,000');
      expect(groupDigits(1234567, g), '1,234,567');
      expect(groupDigits(-1234567, g), '-1,234,567');
    });
  });

  group('taka', () {
    test('Bangla digits with lakh grouping', () {
      expect(
        _taka(125000, NumeralStyle.bangla, GroupingStyle.lakh),
        '৳ ১,২৫,০০০',
      );
      expect(
        _taka(12500, NumeralStyle.bangla, GroupingStyle.western),
        '৳ ১২,৫০০',
      );
    });

    test('western digits', () {
      expect(
        _taka(12500, NumeralStyle.western, GroupingStyle.lakh),
        '৳ 12,500',
      );
      expect(_taka(0, NumeralStyle.western, GroupingStyle.lakh), '৳ 0');
      expect(_taka(-300, NumeralStyle.western, GroupingStyle.lakh), '৳ -300');
    });
  });

  test('counts', () {
    expect(formatCount(42, NumeralStyle.bangla), '৪২');
    expect(formatCount(42, NumeralStyle.western), '42');
  });
}
