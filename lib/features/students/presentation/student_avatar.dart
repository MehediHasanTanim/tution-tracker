import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/features/students/data/photo_store.dart';

/// The student's photo, or their first letter when there is none.
///
/// [previewBytes] shows a just-picked photo that is not saved yet.
class StudentAvatar extends ConsumerWidget {
  const StudentAvatar({
    required this.name,
    required this.photoPath,
    this.radius = 20,
    this.previewBytes,
    super.key,
  });

  final String name;
  final String? photoPath;
  final double radius;
  final Uint8List? previewBytes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ImageProvider? image;
    if (previewBytes != null) {
      image = MemoryImage(previewBytes!);
    } else if (photoPath != null) {
      final store = ref.watch(photoStoreProvider).value;
      if (store != null) {
        // Decode at display size, not 512 px, to keep long lists light.
        final pixels = (radius * 2 * MediaQuery.devicePixelRatioOf(context))
            .round();
        image = ResizeImage(
          FileImage(File(store.fileFor(photoPath!).path)),
          width: pixels,
        );
      }
    }
    return CircleAvatar(
      radius: radius,
      // foregroundImage keeps the letter visible if the file is missing.
      foregroundImage: image,
      onForegroundImageError: image == null ? null : (_, _) {},
      child: Text(
        name.characters.first,
        style: radius >= 32 ? Theme.of(context).textTheme.headlineSmall : null,
      ),
    );
  }
}
