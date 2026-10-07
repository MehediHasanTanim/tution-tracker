/// A typed key in the `settings` table. Values are stored as text; [decode]
/// throws on a corrupt value and the store then falls back to [defaultValue].
class SettingKey<T> {
  const SettingKey({
    required this.name,
    required this.defaultValue,
    required this.encode,
    required this.decode,
    this.validate,
  });

  final String name;
  final T defaultValue;
  final String Function(T value) encode;
  final T Function(String raw) decode;

  /// Throws [ArgumentError] for values that must never be stored.
  final void Function(T value)? validate;

  /// The stored value for [raw], or [defaultValue] when absent or corrupt.
  T read(String? raw) {
    if (raw == null) return defaultValue;
    try {
      return decode(raw);
    } on Object {
      return defaultValue;
    }
  }
}

SettingKey<E> enumKey<E extends Enum>(
  String name,
  List<E> values,
  E defaultValue,
) => SettingKey<E>(
  name: name,
  defaultValue: defaultValue,
  encode: (v) => v.name,
  decode: values.byName,
);

SettingKey<int> intKey(String name, int defaultValue, {int? min, int? max}) =>
    SettingKey<int>(
      name: name,
      defaultValue: defaultValue,
      encode: (v) => v.toString(),
      decode: (raw) {
        final value = int.parse(raw);
        if ((min != null && value < min) || (max != null && value > max)) {
          throw RangeError.range(value, min, max);
        }
        return value;
      },
      validate: (v) {
        if ((min != null && v < min) || (max != null && v > max)) {
          throw ArgumentError.value(v, name, 'must be in $min..$max');
        }
      },
    );

/// Free text, stored trimmed. The default is empty.
SettingKey<String> stringKey(String name) => SettingKey<String>(
  name: name,
  defaultValue: '',
  encode: (v) => v.trim(),
  decode: (raw) => raw,
);
