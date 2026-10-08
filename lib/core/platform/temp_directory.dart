import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Where files made for sharing (receipts) are written. App-private cache,
/// which the system may clear.
final tempDirectoryProvider = FutureProvider<Directory>(
  (ref) => getTemporaryDirectory(),
);
