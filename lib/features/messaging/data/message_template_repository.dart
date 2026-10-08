import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/features/messaging/domain/message_template.dart';

/// Templates the tutor has edited. Where there is no row the built-in
/// default applies, so a fresh install needs no seeding and a restore never
/// brings back stale defaults.
class MessageTemplateRepository {
  MessageTemplateRepository(this._db);

  final AppDatabase _db;

  String _id(MessageKind kind, AppLanguage language) =>
      '${kind.key}:${language.name}';

  Future<String> body(MessageKind kind, AppLanguage language) async {
    final row = await (_db.select(
      _db.messageTemplates,
    )..where((t) => t.id.equals(_id(kind, language)))).getSingleOrNull();
    return row?.body ?? defaultTemplate(kind, language);
  }

  Stream<String> watchBody(MessageKind kind, AppLanguage language) {
    return (_db.select(_db.messageTemplates)
          ..where((t) => t.id.equals(_id(kind, language))))
        .watchSingleOrNull()
        .map((row) => row?.body ?? defaultTemplate(kind, language));
  }

  /// Whether the tutor has changed this template from the default.
  Future<bool> isCustom(MessageKind kind, AppLanguage language) async =>
      (await (_db.select(
        _db.messageTemplates,
      )..where((t) => t.id.equals(_id(kind, language)))).getSingleOrNull()) !=
      null;

  /// Saves an edited template. Throws [ArgumentError] when it is blank.
  Future<void> save(MessageKind kind, AppLanguage language, String body) async {
    final text = body.trim();
    if (text.isEmpty) throw ArgumentError.value(body, 'body', 'is blank');
    await _db
        .into(_db.messageTemplates)
        .insertOnConflictUpdate(
          MessageTemplatesCompanion.insert(
            id: _id(kind, language),
            kind: kind.key,
            language: language.name,
            body: text,
          ),
        );
  }

  /// Back to the built-in default.
  Future<void> reset(MessageKind kind, AppLanguage language) => (_db.delete(
    _db.messageTemplates,
  )..where((t) => t.id.equals(_id(kind, language)))).go();
}
