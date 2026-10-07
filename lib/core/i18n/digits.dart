const _bangla = '০১২৩৪৫৬৭৮৯';
final _banglaRunes = _bangla.runes.toList();

/// Replaces ASCII digits with Bangla digits (০১২৩৪৫৬৭৮৯).
String toBanglaDigits(String input) {
  final out = StringBuffer();
  for (final unit in input.codeUnits) {
    if (unit >= 0x30 && unit <= 0x39) {
      out.write(_bangla[unit - 0x30]);
    } else {
      out.writeCharCode(unit);
    }
  }
  return out.toString();
}

/// Replaces Bangla digits with ASCII digits. Used before parsing input.
String toWesternDigits(String input) {
  final out = StringBuffer();
  for (final rune in input.runes) {
    final index = _banglaRunes.indexOf(rune);
    if (index >= 0) {
      out.write(index);
    } else {
      out.writeCharCode(rune);
    }
  }
  return out.toString();
}
