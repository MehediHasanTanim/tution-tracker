import 'package:tution_tracker/core/dates/local_date.dart';

/// One note on a student. Notes written before dated notes existed have no
/// date.
class StudentNote {
  const StudentNote(this.text, {this.date});

  final LocalDate? date;
  final String text;
}

final _entry = RegExp(r'^\[(\d{4}-\d{2}-\d{2})\] ?');

/// Reads the notes field: dated entries (`[2026-10-10] text`) separated by
/// blank lines, newest first. Text without a date prefix is kept as an
/// undated note, so nothing written earlier is lost.
List<StudentNote> parseStudentNotes(String? notes) {
  final text = (notes ?? '').trim();
  if (text.isEmpty) return const [];
  final result = <StudentNote>[];
  for (final block in text.split(RegExp(r'\n\s*\n'))) {
    final trimmed = block.trim();
    if (trimmed.isEmpty) continue;
    final match = _entry.firstMatch(trimmed);
    if (match == null) {
      result.add(StudentNote(trimmed));
    } else {
      result.add(
        StudentNote(
          trimmed.substring(match.end).trim(),
          date: LocalDate.parse(match.group(1)!),
        ),
      );
    }
  }
  return result;
}

/// The notes field with [text] added on [date], newest first.
String addStudentNote(String? notes, LocalDate date, String text) {
  final entry = '[${date.toIso()}] ${text.trim()}';
  final rest = (notes ?? '').trim();
  return rest.isEmpty ? entry : '$entry\n\n$rest';
}
