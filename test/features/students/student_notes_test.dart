import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/features/students/domain/student_notes.dart';

void main() {
  test('no notes is an empty list', () {
    expect(parseStudentNotes(null), isEmpty);
    expect(parseStudentNotes('  '), isEmpty);
  });

  test('old free text is kept as one undated note', () {
    final notes = parseStudentNotes('Weak in algebra\nlikes geometry');
    expect(notes, hasLength(1));
    expect(notes.single.date, isNull);
    expect(notes.single.text, 'Weak in algebra\nlikes geometry');
  });

  test('adding puts the dated note first and keeps the rest', () {
    var notes = addStudentNote(
      'Old note',
      const LocalDate(2026, 10, 3),
      'First',
    );
    notes = addStudentNote(notes, const LocalDate(2026, 10, 10), ' Second ');
    final parsed = parseStudentNotes(notes);
    expect([for (final n in parsed) n.text], ['Second', 'First', 'Old note']);
    expect(parsed[0].date, const LocalDate(2026, 10, 10));
    expect(parsed[1].date, const LocalDate(2026, 10, 3));
    expect(parsed[2].date, isNull);
  });
}
