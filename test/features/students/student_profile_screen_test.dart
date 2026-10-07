import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/platform/url_launcher_service.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';
import 'package:tution_tracker/router.dart';

import '../../support/db_fixtures.dart';
import '../../support/test_app.dart';

class FakeLauncher implements UrlLauncherService {
  FakeLauncher({this.succeeds = true});

  final bool succeeds;
  final opened = <String>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri.toString());
    return succeeds;
  }
}

const _full = StudentDraft(
  name: 'রহিম উদ্দিন',
  monthlyFee: 125000,
  joinedOn: LocalDate(2026, 10, 6),
  feeDueDay: 15,
  classLevel: 'Class 9',
  school: 'Dhaka College',
  guardianName: 'আব্দুল করিম',
  guardianPhone: '01712-345 678', // typed messily on purpose
  studentPhone: '01898765432',
  address: 'Mirpur',
  subjects: ['Math', 'Physics'],
  classDays: [1, 3],
  notes: 'Weak in algebra',
);

/// Creates [draft], opens the app on its profile and returns the launcher.
Future<(Student, FakeLauncher)> _openProfile(
  WidgetTester tester,
  AppDatabase db,
  StudentDraft draft, {
  bool launchSucceeds = true,
}) async {
  final student = (await tester.runAsync(
    () => StudentRepository(db).create(draft),
  ))!;
  final launcher = FakeLauncher(succeeds: launchSucceeds);
  await pumpApp(
    tester,
    db,
    overrides: [urlLauncherProvider.overrideWithValue(launcher)],
  );
  final container = ProviderScope.containerOf(
    tester.element(find.byType(NavigationBar)),
  );
  unawaited(container.read(routerProvider).push('/students/${student.id}'));
  await settle(tester);
  await tester.pumpAndSettle();
  return (student, launcher);
}

Finder _button(String label) => find.widgetWithText(FilledButton, label);

void main() {
  group('header and overview', () {
    appTestWidgets('shows the student and their details', (tester, db) async {
      await _openProfile(tester, db, _full);

      expect(find.text('রহিম উদ্দিন'), findsWidgets);
      expect(find.text('Class 9 · Dhaka College'), findsOneWidget);
      expect(
        find.text('০১৭১২৩৪৫৬৭৮'),
        findsWidgets,
      ); // normalized, Bangla digits
      expect(find.text('৳ ১,২৫,০০০'), findsOneWidget);
      expect(find.text('১৫'), findsOneWidget);
      expect(find.text('৬ অক্টোবর ২০২৬'), findsOneWidget);
      expect(find.text('আব্দুল করিম'), findsOneWidget);
      expect(find.text('Math, Physics'), findsOneWidget);
      expect(find.text('সোমবার, বুধবার'), findsOneWidget);
    });

    appTestWidgets('has Overview, Attendance, Fees and Notes tabs', (
      tester,
      db,
    ) async {
      await _openProfile(tester, db, _full);

      for (final tab in ['সারসংক্ষেপ', 'উপস্থিতি', 'ফি', 'নোট']) {
        expect(find.widgetWithText(Tab, tab), findsOneWidget);
      }

      await tester.tap(find.widgetWithText(Tab, 'উপস্থিতি'));
      await tester.pumpAndSettle();
      expect(find.text('শীঘ্রই আসছে'), findsOneWidget);

      await tester.tap(find.widgetWithText(Tab, 'নোট'));
      await tester.pumpAndSettle();
      expect(find.text('Weak in algebra'), findsOneWidget);
    });
  });

  group('contact actions', () {
    appTestWidgets('Call, SMS and WhatsApp open the normalized number', (
      tester,
      db,
    ) async {
      final (_, launcher) = await _openProfile(tester, db, _full);

      await tester.tap(_button('কল'));
      await tester.pump();
      await tester.tap(_button('এসএমএস'));
      await tester.pump();
      await tester.tap(_button('হোয়াটসঅ্যাপ'));
      await tester.pump();

      expect(launcher.opened, [
        'tel:+8801712345678',
        'sms:+8801712345678',
        'https://wa.me/8801712345678',
      ]);
    });

    appTestWidgets('falls back to the student phone without a guardian phone', (
      tester,
      db,
    ) async {
      final (_, launcher) = await _openProfile(
        tester,
        db,
        const StudentDraft(
          name: 'Karim',
          monthlyFee: 1000,
          joinedOn: LocalDate(2026, 10, 1),
          studentPhone: '+8801898765432',
        ),
      );
      await tester.tap(_button('হোয়াটসঅ্যাপ'));
      await tester.pump();
      expect(launcher.opened, ['https://wa.me/8801898765432']);
    });

    appTestWidgets('buttons are disabled when there is no phone number', (
      tester,
      db,
    ) async {
      final (_, launcher) = await _openProfile(
        tester,
        db,
        const StudentDraft.quick(
          name: 'Karim',
          monthlyFee: 1000,
          joinedOn: LocalDate(2026, 10, 1),
        ),
      );
      expect(find.text('ফোন নম্বর নেই'), findsOneWidget);
      for (final label in ['কল', 'এসএমএস', 'হোয়াটসঅ্যাপ']) {
        expect(tester.widget<FilledButton>(_button(label)).enabled, isFalse);
      }
      await tester.tap(_button('কল'), warnIfMissed: false);
      await tester.pump();
      expect(launcher.opened, isEmpty);
    });

    appTestWidgets('tells the user when no app can open the link', (
      tester,
      db,
    ) async {
      await _openProfile(tester, db, _full, launchSucceeds: false);
      await tester.tap(_button('হোয়াটসঅ্যাপ'));
      await tester.pump();
      await tester.pump();
      expect(
        find.text('খুলতে পারেনি। অ্যাপটি ইনস্টল করা আছে কি?'),
        findsOneWidget,
      );
    });
  });

  group('menu actions', () {
    appTestWidgets('archive then restore updates the profile live', (
      tester,
      db,
    ) async {
      await _openProfile(tester, db, _full);
      expect(find.widgetWithText(Chip, 'আর্কাইভ'), findsNothing);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('আর্কাইভ করুন'));
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(Chip, 'আর্কাইভ'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('আর্কাইভ করুন'), findsNothing);
      await tester.tap(find.text('পুনরুদ্ধার করুন'));
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(Chip, 'আর্কাইভ'), findsNothing);
    });

    appTestWidgets('delete asks first; cancel keeps the student', (
      tester,
      db,
    ) async {
      final (student, _) = await _openProfile(tester, db, _full);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('স্থায়ীভাবে মুছুন'));
      await tester.pumpAndSettle();
      expect(find.text('শিক্ষার্থী মুছবেন?'), findsOneWidget);

      await tester.tap(find.text('বাতিল'));
      await tester.pumpAndSettle();
      final rows = await tester.runAsync(() => db.select(db.students).get());
      expect(rows!.map((s) => s.id), [student.id]);
    });

    appTestWidgets('confirming delete removes the student and goes back', (
      tester,
      db,
    ) async {
      final (student, _) = await _openProfile(tester, db, _full);
      await tester.runAsync(() => insertPayment(db, 'p1', student.id));

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('স্থায়ীভাবে মুছুন'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('স্থায়ীভাবে মুছুন'),
        ),
      );
      await settle(tester);
      await tester.pumpAndSettle();

      expect(
        await tester.runAsync(() => db.select(db.students).get()),
        isEmpty,
      );
      expect(
        await tester.runAsync(() => db.select(db.payments).get()),
        isEmpty,
      );
      expect(find.byType(NavigationBar), findsOneWidget); // back on a tab
      expect(find.text('শিক্ষার্থী সংরক্ষিত হয়েছে'), findsNothing);
    });

    appTestWidgets('the edit button opens the edit form for this student', (
      tester,
      db,
    ) async {
      await _openProfile(tester, db, _full);
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.text('শিক্ষার্থী সম্পাদনা'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.widgetWithText(TextFormField, 'নাম *'))
            .controller!
            .text,
        'রহিম উদ্দিন',
      );
    });
  });
}
