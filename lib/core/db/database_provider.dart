import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';

/// Opened lazily on first read (design section 13: lazy DB init).
final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final db = await openAppDatabase();
  ref.onDispose(db.close);
  return db;
});
