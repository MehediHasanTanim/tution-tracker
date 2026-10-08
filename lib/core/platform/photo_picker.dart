import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum PhotoSource { camera, gallery }

/// Lets the user pick a photo. Wrapped so UI and tests do not need the plugin.
abstract interface class PhotoPicker {
  /// The picked image's bytes, or null when the user cancelled.
  Future<Uint8List?> pick(PhotoSource source);
}

class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      // Cap the decode size up front so a 12 MP camera shot does not eat RAM
      // on a 2 GB phone; the real downscale to 512 px happens in
      // compressPhoto.
      maxWidth: 1600,
      maxHeight: 1600,
    );
    return file?.readAsBytes();
  }
}

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => ImagePickerPhotoPicker(),
);
