import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/messaging/data/message_template_repository.dart';
import 'package:tution_tracker/features/messaging/data/reminder_log.dart';
import 'package:tution_tracker/features/messaging/domain/message_template.dart';

const _facts = FeeReminderFacts(
  studentName: 'Rahim',
  guardianName: 'Karim Sir',
  balance: 4500,
  oldestMonth: YearMonth(2026, 1),
  oldestDueDate: LocalDate(2026, 1, 10),
  openMonths: 3,
);

String _render(
  String body, {
  AppLanguage language = AppLanguage.en,
  NumeralStyle numerals = NumeralStyle.western,
  String tutor = 'Mr Aziz',
}) => renderTemplate(
  body,
  facts: _facts,
  tutor: TutorSignature(name: tutor, institution: 'Aziz Coaching'),
  language: language,
  numerals: numerals,
  grouping: GroupingStyle.lakh,
);

void main() {
  group('renderTemplate', () {
    test('replaces every variable', () {
      final text = _render(
        '{student}|{guardian}|{month}|{amount}|{due}|{months}|{tutor}|{institution}',
      );
      expect(
        text,
        'Rahim|Karim Sir|January 2026|৳ 4,500|10 Jan 2026|3|Mr Aziz|Aziz Coaching',
      );
    });

    test('the same variable can appear more than once', () {
      expect(
        _render('{student} owes. Pay for {student}.'),
        'Rahim owes. Pay for Rahim.',
      );
    });

    test('Bangla digits and month names when asked', () {
      final text = _render(
        '{amount} / {month} / {due} / {months}',
        language: AppLanguage.bn,
        numerals: NumeralStyle.bangla,
      );
      expect(text, '৳ ৪,৫০০ / জানুয়ারি ২০২৬ / ১০ জানুয়ারি ২০২৬ / ৩');
    });

    test('Western digits inside a Bangla message when asked', () {
      final text = _render(
        '{amount}',
        language: AppLanguage.bn,
        numerals: NumeralStyle.western,
      );
      expect(text, '৳ 4,500');
    });

    test('the signature is "— name", or nothing without a name', () {
      expect(_render('Thanks\n{signature}'), 'Thanks\n— Mr Aziz');
      expect(_render('Thanks\n{signature}', tutor: ''), 'Thanks');
    });

    test('unknown words in braces are left as typed', () {
      expect(_render('Hi {student} {oops}'), 'Hi Rahim {oops}');
    });

    test('the built-in templates use only known variables', () {
      for (final language in AppLanguage.values) {
        final text = _render(
          defaultTemplate(MessageKind.feeReminder, language),
          language: language,
        );
        expect(RegExp(r'\{\w+\}').hasMatch(text), isFalse, reason: '$language');
        expect(text, contains('Rahim'));
      }
    });
  });

  group('MessageTemplateRepository', () {
    test('falls back to the default until edited', () async {
      final db = openInMemoryDatabase();
      addTearDown(db.close);
      final repo = MessageTemplateRepository(db);
      expect(
        await repo.body(MessageKind.feeReminder, AppLanguage.en),
        defaultTemplate(MessageKind.feeReminder, AppLanguage.en),
      );
      expect(
        await repo.isCustom(MessageKind.feeReminder, AppLanguage.en),
        isFalse,
      );
    });

    test('saves per language and resets to the default', () async {
      final db = openInMemoryDatabase();
      addTearDown(db.close);
      final repo = MessageTemplateRepository(db);
      await repo.save(
        MessageKind.feeReminder,
        AppLanguage.bn,
        '  {student} বাকি  ',
      );
      expect(
        await repo.body(MessageKind.feeReminder, AppLanguage.bn),
        '{student} বাকি',
      );
      // The other language is untouched.
      expect(
        await repo.body(MessageKind.feeReminder, AppLanguage.en),
        defaultTemplate(MessageKind.feeReminder, AppLanguage.en),
      );
      await repo.save(MessageKind.feeReminder, AppLanguage.bn, 'second');
      expect(
        await repo.body(MessageKind.feeReminder, AppLanguage.bn),
        'second',
      );

      await repo.reset(MessageKind.feeReminder, AppLanguage.bn);
      expect(
        await repo.body(MessageKind.feeReminder, AppLanguage.bn),
        defaultTemplate(MessageKind.feeReminder, AppLanguage.bn),
      );
    });

    test('a blank template is refused', () async {
      final db = openInMemoryDatabase();
      addTearDown(db.close);
      final repo = MessageTemplateRepository(db);
      expect(
        () => repo.save(MessageKind.feeReminder, AppLanguage.en, '   '),
        throwsArgumentError,
      );
    });
  });

  group('ReminderLog', () {
    test('records, overwrites and undoes marks', () async {
      final db = openInMemoryDatabase();
      addTearDown(db.close);
      final log = ReminderLog(SettingsStore(db));
      expect(await log.all(), isEmpty);

      await log.mark('s1', const LocalDate(2026, 3, 1));
      await log.mark('s2', const LocalDate(2026, 3, 2));
      await log.mark('s1', const LocalDate(2026, 3, 9));
      expect(await log.all(), {
        's1': const LocalDate(2026, 3, 9),
        's2': const LocalDate(2026, 3, 2),
      });

      await log.unmark('s1', previous: const LocalDate(2026, 3, 1));
      expect((await log.all())['s1'], const LocalDate(2026, 3, 1));
      await log.unmark('s2');
      expect((await log.all()).containsKey('s2'), isFalse);

      await log.clear();
      expect(await log.all(), isEmpty);
    });

    test('a damaged value is treated as empty, not a crash', () async {
      final db = openInMemoryDatabase();
      addTearDown(db.close);
      final settings = SettingsStore(db);
      await settings.set(SettingKeys.feeRemindersSent, 'not json');
      expect(await ReminderLog(settings).all(), isEmpty);
    });

    test('"recent" means within the last week', () {
      const today = LocalDate(2026, 3, 15);
      expect(isRecentlyReminded(null, today), isFalse);
      expect(isRecentlyReminded(const LocalDate(2026, 3, 15), today), isTrue);
      expect(isRecentlyReminded(const LocalDate(2026, 3, 9), today), isTrue);
      expect(isRecentlyReminded(const LocalDate(2026, 3, 8), today), isFalse);
    });
  });
}
