import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/i18n/text_normalizer.dart';

void main() {
  test('precomposed and decomposed nukta letters become equal', () {
    // রড় typed with U+09DC vs ড + nukta.
    expect(normalizeBangla('রড়'), normalizeBangla('রড়'));
    expect(normalizeBangla('ঢ়'), 'ঢ়');
    expect(normalizeBangla('য়'), 'য়');
  });

  test('split and joined o/au vowel signs become equal', () {
    expect(normalizeBangla('কো'), 'কো');
    expect(normalizeBangla('কৌ'), 'কৌ');
    expect(normalizeBangla('কো'), 'কো');
  });

  test('normalizeText trims and collapses whitespace', () {
    expect(normalizeText('  রহিম   উদ্দিন \n'), 'রহিম উদ্দিন');
  });

  test('searchKey lower-cases Latin and keeps Bangla', () {
    expect(searchKey('  Rahim   KHAN '), 'rahim khan');
    expect(searchKey('রহিম'), 'রহিম');
  });
}
