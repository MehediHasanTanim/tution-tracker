import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/money/taka.dart';

void main() {
  test('addition and subtraction', () {
    expect(const Taka(1500) + const Taka(500), const Taka(2000));
    expect(const Taka(1500) - const Taka(2000), const Taka(-500));
    expect(-const Taka(300), const Taka(-300));
  });

  test('comparison, min and max', () {
    expect(const Taka(1) < const Taka(2), isTrue);
    expect(const Taka(2) <= const Taka(2), isTrue);
    expect(const Taka(3) > const Taka(2), isTrue);
    expect(const Taka(2) >= const Taka(3), isFalse);
    expect(const Taka(5).min(const Taka(3)), const Taka(3));
    expect(const Taka(5).max(const Taka(3)), const Taka(5));
  });

  test('zero and sign', () {
    expect(Taka.zero.isZero, isTrue);
    expect(const Taka(-1).isNegative, isTrue);
    expect(const Taka(1).isNegative, isFalse);
  });

  group('applyPercent', () {
    test('exact results', () {
      expect(applyPercent(1000, 10), 100);
      expect(applyPercent(1500, 50), 750);
      expect(applyPercent(1234, 0), 0);
      expect(applyPercent(1234, 100), 1234);
    });

    test('rounds half up for positive amounts', () {
      expect(applyPercent(1005, 10), 101); // 100.5
      expect(applyPercent(1004, 10), 100); // 100.4
      expect(applyPercent(999, 15), 150); // 149.85
    });

    test('rounds half away from zero for negative amounts', () {
      expect(applyPercent(-1005, 10), -101);
      expect(applyPercent(-1004, 10), -100);
    });

    test('is exact for large amounts where doubles would drift', () {
      expect(applyPercent(900719925474099, 1), 9007199254741);
    });
  });
}
