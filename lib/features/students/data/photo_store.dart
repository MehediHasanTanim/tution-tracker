import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Student photos in app-private storage: not visible in the gallery and
/// unreachable by other apps (design section 14).
///
/// The database stores a path relative to [root] (`photos/<id>_<ms>.jpg`) so
/// it stays valid after a restore onto a phone with a different app folder.
/// Each save uses a new file name, so an updated photo never shows a stale
/// cached image.
class PhotoStore {
  PhotoStore(this.root, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final Directory root;
  final DateTime Function() _now;

  static const folder = 'photos';

  /// Writes [jpegBytes] for [studentId] and returns the relative path.
  Future<String> save(String studentId, Uint8List jpegBytes) async {
    final relative = p.posix.join(
      folder,
      '${studentId}_${_now().toUtc().millisecondsSinceEpoch}.jpg',
    );
    final file = fileFor(relative);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(jpegBytes, flush: true);
    return relative;
  }

  /// The file for a stored relative path.
  File fileFor(String relativePath) =>
      File(p.joinAll([root.path, ...p.posix.split(relativePath)]));

  /// Deletes a stored photo. Missing files and null paths are fine.
  Future<void> delete(String? relativePath) async {
    if (relativePath == null) return;
    final file = fileFor(relativePath);
    if (file.existsSync()) await file.delete();
  }
}

final photoStoreProvider = FutureProvider<PhotoStore>((ref) async {
  return PhotoStore(await getApplicationDocumentsDirectory());
});
