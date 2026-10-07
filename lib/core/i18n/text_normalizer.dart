/// Canonicalises Bangla text so the same word typed on different keyboards
/// compares equal (design section 11: normalize before matching).
///
/// Dart has no built-in Unicode normalization, so this covers the Bengali
/// sequences that actually vary between keyboards:
///  - ড় ঢ় য় as one code point (U+09DC/09DD/09DF) or base + nukta (U+09BC),
///    which is the canonical form NFC produces;
///  - ো ৌ as one code point (U+09CB/09CC) or vowel sign pairs, which NFC
///    composes.
String normalizeBangla(String input) {
  return input
      .replaceAll('ড়', 'ড়')
      .replaceAll('ঢ়', 'ঢ়')
      .replaceAll('য়', 'য়')
      .replaceAll('ো', 'ো')
      .replaceAll('ৌ', 'ৌ');
}

/// Text as stored: Bangla-normalised, trimmed, inner whitespace collapsed.
String normalizeText(String input) =>
    normalizeBangla(input).trim().replaceAll(RegExp(r'\s+'), ' ');

/// Text as compared in searches: [normalizeText] plus lower-casing.
String searchKey(String input) => normalizeText(input).toLowerCase();
