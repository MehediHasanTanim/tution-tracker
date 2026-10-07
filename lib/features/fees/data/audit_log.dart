import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:uuid/uuid.dart';

/// Writes `audit_log` rows. Call inside the transaction of the change being
/// logged, so the log and the change commit or roll back together.
///
/// [details] holds amounts and ids only, never names or phone numbers.
Future<void> writeAudit(
  AppDatabase db, {
  required String entity,
  required String entityId,
  required String action,
  required int at,
  Map<String, Object?>? details,
  String Function()? newId,
}) {
  return db
      .into(db.auditLog)
      .insert(
        AuditLogCompanion.insert(
          id: (newId ?? () => const Uuid().v4())(),
          entity: entity,
          entityId: entityId,
          action: action,
          at: at,
          details: Value(details == null ? null : jsonEncode(details)),
        ),
      );
}
