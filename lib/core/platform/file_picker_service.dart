import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets the user choose a file on the phone. Wrapped so screens and tests do
/// not need the plugin (design section 3, principle 4).
abstract interface class FilePickerService {
  /// The chosen file, or null if the user backed out. Any file type is
  /// allowed: Android does not know the `.tkbackup` extension, so filtering
  /// by it would hide the file.
  Future<File?> pickFile();
}

class PluginFilePickerService implements FilePickerService {
  const PluginFilePickerService();

  @override
  Future<File?> pickFile() async {
    final picked = await FilePicker.pickFile();
    final path = picked?.path;
    return path == null ? null : File(path);
  }
}

final filePickerProvider = Provider<FilePickerService>(
  (ref) => const PluginFilePickerService(),
);
