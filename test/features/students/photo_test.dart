import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/features/students/data/photo_processing.dart';
import 'package:tution_tracker/features/students/data/photo_store.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';

/// A photo-like test image: smooth colour gradients plus a few shapes.
Uint8List _photo(int width, int height, {bool png = false}) {
  final image = img.Image(width: width, height: height);
  for (final pixel in image) {
    final x = pixel.x / width;
    final y = pixel.y / height;
    pixel
      ..r = 255 * x
      ..g = 255 * y
      ..b = 255 * (1 - x) * (1 - y);
  }
  img.fillCircle(
    image,
    x: width ~/ 2,
    y: height ~/ 2,
    radius: height ~/ 4,
    color: img.ColorRgb8(240, 200, 160),
  );
  return Uint8List.fromList(png ? img.encodePng(image) : img.encodeJpg(image));
}

img.Image _decode(Uint8List bytes) => img.decodeJpg(bytes)!;

void main() {
  group('compressPhoto', () {
    test('shrinks a large landscape photo to 512 px wide, under 80 KB', () {
      final input = _photo(2400, 1600);
      final out = compressPhoto(input);
      final image = _decode(out);
      expect(image.width, 512);
      expect(image.height, 341); // 1600 * 512 / 2400, aspect kept
      expect(out.length, lessThan(80 * 1024));
      expect(out.length, lessThan(input.length));
    });

    test('shrinks a portrait photo by its height', () {
      final image = _decode(compressPhoto(_photo(1200, 2000)));
      expect(image.height, 512);
      expect(image.width, 307);
    });

    test('output is a JPEG even when the input is a PNG', () {
      final out = compressPhoto(_photo(900, 900, png: true));
      expect(out[0], 0xFF);
      expect(out[1], 0xD8);
      expect(_decode(out).width, 512);
    });

    test('never scales a small image up', () {
      final image = _decode(compressPhoto(_photo(200, 100)));
      expect(image.width, 200);
      expect(image.height, 100);
    });

    test('applies EXIF rotation before sizing', () {
      final base = img.Image(width: 800, height: 400)
        ..exif.imageIfd.orientation = 6; // rotate 90 degrees clockwise
      final out = compressPhoto(Uint8List.fromList(img.encodeJpg(base)));
      final image = _decode(out);
      // Rotated to 400x800 (portrait), then sized to 512 high.
      expect(image.height, 512);
      expect(image.width, 256);
    });

    test('unreadable data throws a FormatException', () {
      expect(
        () => compressPhoto(Uint8List.fromList([1, 2, 3, 4])),
        throwsFormatException,
      );
    });

    test('the isolate version gives the same result', () async {
      final input = _photo(1000, 800);
      expect(await compressPhotoInIsolate(input), compressPhoto(input));
    });
  });

  group('PhotoStore', () {
    late Directory dir;
    var clock = DateTime.utc(2026, 10, 7, 12);
    late PhotoStore store;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('tk_photos_');
      clock = DateTime.utc(2026, 10, 7, 12);
      store = PhotoStore(dir, now: () => clock);
    });

    tearDown(() => dir.deleteSync(recursive: true));

    test('saves under photos/ and returns a relative path', () async {
      final path = await store.save('s1', Uint8List.fromList([1, 2, 3]));
      expect(path, 'photos/s1_${clock.millisecondsSinceEpoch}.jpg');
      expect(store.fileFor(path).readAsBytesSync(), [1, 2, 3]);
      expect(store.fileFor(path).path, startsWith(dir.path));
    });

    test('a new save gets a new file name', () async {
      final first = await store.save('s1', Uint8List.fromList([1]));
      clock = clock.add(const Duration(seconds: 1));
      final second = await store.save('s1', Uint8List.fromList([2]));
      expect(second, isNot(first));
      expect(store.fileFor(first).existsSync(), isTrue);
    });

    test(
      'delete removes the file and tolerates null or missing paths',
      () async {
        final path = await store.save('s1', Uint8List.fromList([1]));
        await store.delete(path);
        expect(store.fileFor(path).existsSync(), isFalse);
        await store.delete(path);
        await store.delete(null);
      },
    );
  });

  group('repository photo path', () {
    test('setPhotoPath stores and clears the path', () async {
      final db = openInMemoryDatabase();
      addTearDown(db.close);
      final repo = StudentRepository(db);
      final s = await repo.create(
        const StudentDraft.quick(
          name: 'Rahim',
          monthlyFee: 1000,
          joinedOn: LocalDate(2026, 10, 1),
        ),
      );
      expect(s.photoPath, isNull);
      await repo.setPhotoPath(s.id, 'photos/x.jpg');
      expect((await repo.getById(s.id))!.photoPath, 'photos/x.jpg');
      await repo.setPhotoPath(s.id, null);
      expect((await repo.getById(s.id))!.photoPath, isNull);
    });
  });
}
