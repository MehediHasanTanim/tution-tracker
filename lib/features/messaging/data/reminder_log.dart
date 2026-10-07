import 'dart:convert';

import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';

/// When each student's guardian was last sent a fee reminder. Kept in
/// settings, so it is saved in backups and survives leaving the app halfway
/// through a bulk send.
class ReminderLog {
  ReminderLog(this._settings);

  final SettingsStore _settings;

  Future<Map<String, LocalDate>> all() async {
    final raw = await _settings.get(SettingKeys.feeRemindersSent);
    return _decode(raw);
  }

  Stream<Map<String, LocalDate>> watch() =>
      _settings.watch(SettingKeys.feeRemindersSent).map(_decode);

  static Map<String, LocalDate> _decode(String raw) {
    if (raw.isEmpty) return {};
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in json.entries) e.key: LocalDate.parse(e.value as String),
      };
    } on Object {
      return {};
    }
  }

  Future<void> mark(String studentId, LocalDate on) async {
    final map = await all();
    map[studentId] = on;
    await _write(map);
  }

  /// Undoes a mark, restoring [previous] when there was an earlier one.
  Future<void> unmark(String studentId, {LocalDate? previous}) async {
    final map = await all();
    if (previous == null) {
      map.remove(studentId);
    } else {
      map[studentId] = previous;
    }
    await _write(map);
  }

  Future<void> clear() => _settings.reset(SettingKeys.feeRemindersSent);

  Future<void> _write(Map<String, LocalDate> map) => _settings.set(
    SettingKeys.feeRemindersSent,
    jsonEncode({for (final e in map.entries) e.key: e.value.toIso()}),
  );
}

/// A reminder counts as recent for this many days, so a student reminded
/// this week is not nagged again in the next bulk round.
const reminderFreshDays = 7;

bool isRecentlyReminded(LocalDate? last, LocalDate today) =>
    last != null && last.daysUntil(today) < reminderFreshDays;
