import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';
import 'package:tution_tracker/router.dart';

import '../../support/test_app.dart';

DateTime _clock() => DateTime(2026, 10, 7, 9);

Future<void> _openAddForm(WidgetTester tester, AppDatabase db) async {
  await pumpApp(tester, db, clock: _clock);
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('শিক্ষার্থী'),
    ),
  );
  await settle(tester);
  await tester.tap(find.text('শিক্ষার্থী যোগ করুন'));
  await tester.pumpAndSettle();
}

Future<List<Student>> _students(WidgetTester tester, AppDatabase db) async =>
    (await tester.runAsync(() => db.select(db.students).get()))!;

/// Scrolls [target] to the middle of the form, then taps it. Tapping a widget
/// pinned to the very top edge misses it behind the app bar.
Future<void> _tapCentered(WidgetTester tester, Finder target) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
  await tester.pump();
  await tester.tap(target);
  await tester.pump();
}

Finder _field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  group('quick add', () {
    appTestWidgets('a name and a fee are enough, Bangla digits accepted', (
      tester,
      db,
    ) async {
      await _openAddForm(tester, db);

      // Only the two required fields and the "more details" toggle.
      expect(find.byType(TextFormField), findsNWidgets(2));

      await tester.enterText(_field('নাম *'), '  রহিম   উদ্দিন ');
      await tester.enterText(_field('মাসিক ফি (৳) *'), '১৫০০');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await settle(tester);
      await tester.pumpAndSettle();

      final rows = await _students(tester, db);
      expect(rows, hasLength(1));
      expect(rows.single.name, 'রহিম উদ্দিন');
      expect(rows.single.monthlyFee, 1500);
      expect(rows.single.feeDueDay, 10); // settings default
      expect(rows.single.joinedOn, '2026-10-07'); // today, from the clock

      // Back on the list, which now shows the student.
      expect(find.text('রহিম উদ্দিন'), findsOneWidget);
      expect(find.text('শিক্ষার্থী সংরক্ষিত হয়েছে'), findsOneWidget);
    });

    appTestWidgets('uses the default due day from settings', (
      tester,
      db,
    ) async {
      await tester.runAsync(
        () => SettingsStore(db).set(SettingKeys.defaultDueDay, 25),
      );
      await _openAddForm(tester, db);
      await tester.enterText(_field('নাম *'), 'Karim');
      await tester.enterText(_field('মাসিক ফি (৳) *'), '1000');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await settle(tester);
      await tester.pumpAndSettle();
      expect((await _students(tester, db)).single.feeDueDay, 25);
    });

    appTestWidgets('missing name and fee show errors and save nothing', (
      tester,
      db,
    ) async {
      await _openAddForm(tester, db);
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await tester.pumpAndSettle();

      expect(find.text('নাম লিখুন'), findsOneWidget);
      expect(find.text('মাসিক ফি লিখুন'), findsOneWidget);
      expect(await _students(tester, db), isEmpty);
    });

    appTestWidgets('the fee field rejects letters', (tester, db) async {
      await _openAddForm(tester, db);
      await tester.enterText(_field('মাসিক ফি (৳) *'), '12ab৩');
      expect(
        tester.widget<TextFormField>(_field('মাসিক ফি (৳) *')).controller!.text,
        '123',
      );
    });
  });

  group('full form', () {
    Future<void> showMore(WidgetTester tester) async {
      await tester.tap(find.text('আরও তথ্য যোগ করুন'));
      await tester.pumpAndSettle();
    }

    appTestWidgets('an invalid phone number shows an error and blocks saving', (
      tester,
      db,
    ) async {
      await _openAddForm(tester, db);
      await tester.enterText(_field('নাম *'), 'Rahim');
      await tester.enterText(_field('মাসিক ফি (৳) *'), '1500');
      await showMore(tester);

      await tester.enterText(_field('অভিভাবকের ফোন'), '12345');
      await tester.pump();
      expect(
        find.text('সঠিক মোবাইল নম্বর দিন (যেমন ০১৭১২৩৪৫৬৭৮)'),
        findsOneWidget,
      );

      await tester.tap(find.text('সংরক্ষণ করুন'));
      await tester.pumpAndSettle();
      expect(await _students(tester, db), isEmpty);

      // A valid number in another accepted format clears the error.
      await tester.enterText(_field('অভিভাবকের ফোন'), '+৮৮০ ১৭১২-৩৪৫৬৭৮');
      await tester.pump();
      expect(
        find.text('সঠিক মোবাইল নম্বর দিন (যেমন ০১৭১২৩৪৫৬৭৮)'),
        findsNothing,
      );
    });

    appTestWidgets('saves every field, normalising phone numbers', (
      tester,
      db,
    ) async {
      await _openAddForm(tester, db);
      await tester.enterText(_field('নাম *'), 'Rahim Uddin');
      await tester.enterText(_field('মাসিক ফি (৳) *'), '2000');
      await showMore(tester);

      await tester.enterText(_field('স্কুল / প্রতিষ্ঠান'), 'Dhaka College');
      await tester.enterText(_field('অভিভাবকের নাম'), 'Abdul Karim');
      await tester.enterText(_field('অভিভাবকের ফোন'), '+৮৮০ ১৭১২-৩৪৫৬৭৮');
      await tester.enterText(_field('শিক্ষার্থীর ফোন'), '01898 765432');
      await tester.enterText(_field('ঠিকানা / এলাকা'), 'Mirpur');
      await tester.enterText(_field('নোট'), 'Weak in algebra');

      for (final subject in ['গণিত', 'ইংরেজি']) {
        await _tapCentered(tester, find.widgetWithText(FilterChip, subject));
      }

      // Class level dropdown.
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Class 2').last);
      await tester.pumpAndSettle();

      // Due day dropdown.
      await tester.ensureVisible(find.byType(DropdownButtonFormField<int>));
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('১৫').last);
      await tester.pumpAndSettle();

      // Class days: Saturday and Monday.
      await _tapCentered(tester, find.widgetWithText(FilterChip, 'শনিবার'));
      await _tapCentered(tester, find.widgetWithText(FilterChip, 'সোমবার'));

      await tester.tap(find.text('সংরক্ষণ করুন'));
      await settle(tester);
      await tester.pumpAndSettle();

      final s = (await _students(tester, db)).single;
      expect(s.name, 'Rahim Uddin');
      expect(s.monthlyFee, 2000);
      expect(s.school, 'Dhaka College');
      expect(s.guardianName, 'Abdul Karim');
      expect(s.guardianPhone, '01712345678');
      expect(s.studentPhone, '01898765432');
      expect(s.address, 'Mirpur');
      expect(s.notes, 'Weak in algebra');
      expect(s.classLevel, 'Class 2');
      expect(s.feeDueDay, 15);
      expect(s.subjectList, unorderedEquals(['গণিত', 'ইংরেজি']));
      expect(s.classDayList, [1, 6]); // stored ascending
      expect(s.classTime, isNull);
    });

    appTestWidgets('a custom subject can be added', (tester, db) async {
      await _openAddForm(tester, db);
      await tester.enterText(_field('নাম *'), 'Rahim');
      await tester.enterText(_field('মাসিক ফি (৳) *'), '1500');
      await showMore(tester);

      final other = find.widgetWithText(TextField, 'অন্য বিষয় যোগ করুন');
      await tester.ensureVisible(other);
      await tester.enterText(other, 'Arabic');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.widgetWithText(FilterChip, 'Arabic'), findsOneWidget);

      await tester.tap(find.text('সংরক্ষণ করুন'));
      await settle(tester);
      await tester.pumpAndSettle();
      expect((await _students(tester, db)).single.subjectList, ['Arabic']);
    });

    appTestWidgets('the details toggle hides and shows the extra fields', (
      tester,
      db,
    ) async {
      await _openAddForm(tester, db);
      expect(find.text('অভিভাবকের নাম'), findsNothing);
      await showMore(tester);
      expect(find.text('অভিভাবকের নাম'), findsOneWidget);
      await tester.tap(find.text('কম তথ্য দেখান'));
      await tester.pumpAndSettle();
      expect(find.text('অভিভাবকের নাম'), findsNothing);
    });
  });

  group('edit', () {
    appTestWidgets('loads the student, locks the fee, saves changes', (
      tester,
      db,
    ) async {
      final repo = StudentRepository(db);
      final student = (await tester.runAsync(
        () => repo.create(
          const StudentDraft(
            name: 'Rahim',
            monthlyFee: 1500,
            joinedOn: LocalDate(2026, 9, 1),
            school: 'Old School',
            guardianPhone: '01712345678',
            classLevel: 'Class 8',
            subjects: ['Math'],
            classDays: [3, 5],
          ),
        ),
      ))!;

      await pumpApp(tester, db, clock: _clock);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      unawaited(
        container.read(routerProvider).push('/students/${student.id}/edit'),
      );
      await settle(tester);
      await tester.pumpAndSettle();

      expect(find.text('শিক্ষার্থী সম্পাদনা'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(_field('নাম *')).controller!.text,
        'Rahim',
      );
      expect(find.text('Old School'), findsOneWidget);
      expect(find.text('01712345678'), findsOneWidget);

      // The fee is shown but cannot be edited here.
      final fee = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'মাসিক ফি (৳) *'),
      );
      expect(fee.enabled, isFalse);
      expect(
        find.text('ফি পরিবর্তন করতে ফি সমন্বয় ব্যবহার করুন'),
        findsOneWidget,
      );

      await tester.enterText(_field('নাম *'), 'Rahim Uddin');
      await tester.enterText(_field('স্কুল / প্রতিষ্ঠান'), 'New School');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await settle(tester);
      await tester.pumpAndSettle();

      final s = (await _students(tester, db)).single;
      expect(s.name, 'Rahim Uddin');
      expect(s.school, 'New School');
      expect(s.monthlyFee, 1500);
      expect(s.joinedOn, '2026-09-01');
      expect(s.classLevel, 'Class 8');
      expect(s.subjectList, ['Math']);
      expect(s.classDayList, [3, 5]);
      expect(find.byType(GoRouter), findsNothing);
    });
  });
}
