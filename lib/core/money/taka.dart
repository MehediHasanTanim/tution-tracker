/// Whole-taka amount. Never use `double` for money (design section 5.1).
extension type const Taka(int value) {
  Taka operator +(Taka other) => Taka(value + other.value);

  Taka operator -(Taka other) => Taka(value - other.value);

  Taka operator -() => Taka(-value);

  bool operator <(Taka other) => value < other.value;

  bool operator <=(Taka other) => value <= other.value;

  bool operator >(Taka other) => value > other.value;

  bool operator >=(Taka other) => value >= other.value;

  static const zero = Taka(0);

  bool get isZero => value == 0;

  bool get isNegative => value < 0;

  Taka min(Taka other) => value <= other.value ? this : other;

  Taka max(Taka other) => value >= other.value ? this : other;
}

/// `amount * percent / 100`, rounded half away from zero, using integer
/// arithmetic only so results never depend on floating point behaviour.
int applyPercent(int amount, int percent) {
  final product = amount * percent;
  final half = product.isNegative ? -50 : 50;
  return (product + half) ~/ 100;
}
