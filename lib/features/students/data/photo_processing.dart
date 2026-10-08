import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

/// Longest side of a stored student photo, in pixels (design section 13).
const photoMaxSide = 512;

/// JPEG quality of stored photos.
const photoJpegQuality = 75;

/// Decodes [input] (JPEG, PNG, ...), applies its EXIF rotation, scales it
/// down so the longest side is at most [maxSide] (never up), and re-encodes
/// as JPEG. Typically a few tens of KB.
///
/// Throws [FormatException] when [input] is not a readable image.
Uint8List compressPhoto(
  Uint8List input, {
  int maxSide = photoMaxSide,
  int quality = photoJpegQuality,
}) {
  // The image package has lenient fallback decoders that accept almost any
  // bytes, so check for a real image signature first.
  final decoded = _hasImageSignature(input) ? img.decodeImage(input) : null;
  if (decoded == null) {
    throw const FormatException('Not a readable image');
  }
  var image = img.bakeOrientation(decoded);
  final longest = image.width > image.height ? image.width : image.height;
  if (longest > maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxSide)
        : img.copyResize(image, height: maxSide);
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: quality));
}

bool _hasImageSignature(Uint8List b) {
  bool starts(List<int> sig) =>
      b.length >= sig.length &&
      [for (var i = 0; i < sig.length; i++) b[i] == sig[i]].every((x) => x);
  return starts([0xFF, 0xD8, 0xFF]) || // JPEG
      starts([0x89, 0x50, 0x4E, 0x47]) || // PNG
      starts([0x47, 0x49, 0x46, 0x38]) || // GIF
      starts([0x42, 0x4D]) || // BMP
      (starts([0x52, 0x49, 0x46, 0x46]) &&
          b.length >= 12 &&
          b[8] == 0x57 &&
          b[9] == 0x45 &&
          b[10] == 0x42 &&
          b[11] == 0x50); // WebP: RIFF....WEBP
}

/// [compressPhoto] off the UI thread.
Future<Uint8List> compressPhotoInIsolate(Uint8List input) =>
    Isolate.run(() => compressPhoto(input));

typedef PhotoCompressor = Future<Uint8List> Function(Uint8List input);

/// Overridable so widget tests can compress synchronously.
final photoCompressorProvider = Provider<PhotoCompressor>(
  (ref) => compressPhotoInIsolate,
);
