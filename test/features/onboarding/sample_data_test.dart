import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/fees/data/consistency_checker.dart';
import 'package:tution_tracker/features/onboarding/data/sample_data_service.dart';

Future<Map<String, List<Map<String, Object?>>>> _dump(AppDatabase db) async {
  final out = <String, List<Map<String, Object?>>>{};
  for (final table in db.allTables) {
    final name = table.actualTableName;
    final rows = await db
        .customSelect('SELECT * FROM $name ORDER BY 1, 2')
        .get();
    out[name] = [for (final r in rows) Map<String, Object?>.from(r.data)];
  }
  return out;
}

Future<int> _count(AppDatabase db, String table) async =>
    (await db.customSelect('SELECT COUNT(*) c FROM $table').getSingle())
        .read<int>('c');

void main() {
  late AppDatabase db;
  late SettingsStore settings;
  late SampleDataService sample;
  final now = DateTime(2026, 3, 15, 10);

  setUp(() {
    db = openInMemoryDatabase();
    settings = SettingsStore(db);
    sample = SampleDataService(db, settings, now: () => now);
  });

  tearDown(() => db.close());

  test('loads students, batches, dues, payments and attendance', () async {
    expect(await sample.isLoaded(), isFalse);
    await sample.load(AppLanguage.bn);
    expect(await sample.isLoaded(), isTrue);

    expect(await _count(db, 'students'), 6);
    expect(await _count(db, 'batches'), 2);
    expect(await _count(db, 'batch_members'), 6);
    expect(await _count(db, 'payments'), 3);
    expect(await _count(db, 'fee_records'), greaterThan(6));
    expect(await _count(db, 'class_sessions'), greaterThan(0));
    expect(await _count(db, 'attendance'), greaterThan(0));
    // Someone still owes money, so the Fees tab has something to show.
    final owing = await db
        .customSelect(
          'SELECT COUNT(DISTINCT student_id) c FROM fee_balances WHERE balance > 0',
        )
        .getSingle();
    expect(owing.read<int>('c'), greaterThan(0));
  });

  test('the data is internally consistent', () async {
    await sample.load(AppLanguage.en);
    final issues = await ConsistencyChecker(db, settings).run();
    expect(issues, isEmpty);
  });

  test('names follow the language', () async {
    await sample.load(AppLanguage.en);
    final names = (await db.customSelect('SELECT name FROM students').get())
        .map((r) => r.read<String>('name'));
    expect(names, contains('Rahim Uddin'));
  });

  test('loading twice does not duplicate', () async {
    await sample.load(AppLanguage.bn);
    await sample.load(AppLanguage.bn);
    expect(await _count(db, 'students'), 6);
  });

  test('removal leaves no residue: the database is as before', () async {
    final before = await _dump(db);
    await sample.load(AppLanguage.bn);
    expect(await _dump(db), isNot(before));
    await sample.remove();

    expect(await sample.isLoaded(), isFalse);
    expect(await _dump(db), before);
  });

  test('removal keeps the tutor\'s own records', () async {
    await db.customStatement(
      'INSERT INTO students (id, name, joined_on, monthly_fee, created_at, updated_at) '
      "VALUES ('mine', 'My Student', '2026-01-01', 1000, 1, 1)",
    );
    await sample.load(AppLanguage.bn);
    await sample.remove();
    final rows = await db.customSelect('SELECT id FROM students').get();
    expect(rows.map((r) => r.read<String>('id')), ['mine']);
  });

  test('receipt numbers continue where they were', () async {
    await settings.set(SettingKeys.nextReceiptNo, 12);
    await sample.load(AppLanguage.bn);
    expect(await settings.get(SettingKeys.nextReceiptNo), 15);
    await sample.remove();
    expect(await settings.get(SettingKeys.nextReceiptNo), 12);
  });

  test('removal clears guardian-reminder marks for sample students', () async {
    await sample.load(AppLanguage.bn);
    final id =
        (await db.customSelect('SELECT id FROM students LIMIT 1').getSingle())
            .read<String>('id');
    await settings.set(SettingKeys.feeRemindersSent, '{"$id":"2026-03-01"}');
    await sample.remove();
    expect(await settings.get(SettingKeys.feeRemindersSent), '');
  });
}
