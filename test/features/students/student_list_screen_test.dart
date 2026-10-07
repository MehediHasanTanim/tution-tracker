import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';

import '../../support/db_fixtures.dart';
import '../../support/test_app.dart';

StudentDraft _draft(
  String name, {
  String? classLevel,
  int fee = 1500,
  String? guardianPhone,
}) => StudentDraft(
  name: name,
  monthlyFee: fee,
  joinedOn: const LocalDate(2026, 10, 1),
  classLevel: classLevel,
  guardianPhone: guardianPhone,
);

void main() {
  late AppDatabase db;
  late StudentRepository repo;

  setUp(() {
    db = openInMemoryDatabase();
    repo = StudentRepository(db);
  });

  void appTest(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      try {
        await body(tester);
      } finally {
        await shutdownApp(tester, db);
      }
    });
  }

  Future<void> openStudentsTab(WidgetTester tester) async {
    await pumpApp(tester, db);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('শিক্ষার্থী'),
      ),
    );
    await settle(tester);
  }

  Future<void> seed(WidgetTester tester, List<StudentDraft> drafts) => tester
      .runAsync(() async {
        for (final d in drafts) {
          await repo.create(d);
        }
      })
      .then((_) {});

  appTest('shows the empty state when there are no students', (tester) async {
    await openStudentsTab(tester);
    expect(find.text('এখনও কোনো শিক্ষার্থী নেই'), findsOneWidget);
    expect(find.text('প্রথম শিক্ষার্থী যোগ করুন'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  appTest('lists students with class, fee in Bangla digits and count', (
    tester,
  ) async {
    await seed(tester, [
      _draft('রহিম উদ্দিন', classLevel: 'Class 9', fee: 1500),
      _draft('করিম', fee: 125000),
    ]);
    await openStudentsTab(tester);

    expect(find.text('রহিম উদ্দিন'), findsOneWidget);
    expect(find.text('Class 9 · ৳ ১,৫০০ / মাস'), findsOneWidget);
    expect(find.text('৳ ১,২৫,০০০ / মাস'), findsOneWidget);
    expect(find.text('শিক্ষার্থী: ২'), findsOneWidget);
  });

  appTest('typing in the search box filters as you type', (tester) async {
    await seed(tester, [
      _draft('Rahim Uddin'),
      _draft('Karim Khan'),
      _draft('রহিম মিয়া'),
    ]);
    await openStudentsTab(tester);
    expect(find.byType(ListTile), findsNWidgets(3));

    await tester.enterText(find.byType(TextField), 'rah');
    await settle(tester);
    expect(find.text('Rahim Uddin'), findsOneWidget);
    expect(find.text('Karim Khan'), findsNothing);

    await tester.enterText(find.byType(TextField), 'রহিম');
    await settle(tester);
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('রহিম মিয়া'), findsOneWidget);

    await tester.tap(find.byTooltip('মুছুন'));
    await settle(tester);
    expect(find.byType(ListTile), findsNWidgets(3));
  });

  appTest('no match shows a message and Clear filters resets', (tester) async {
    await seed(tester, [_draft('Rahim')]);
    await openStudentsTab(tester);

    await tester.enterText(find.byType(TextField), 'zzz');
    await settle(tester);
    expect(find.text('কোনো শিক্ষার্থী মেলেনি'), findsOneWidget);

    await tester.tap(find.text('ফিল্টার মুছুন'));
    await settle(tester);
    expect(find.text('Rahim'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });

  appTest('archived students are hidden until the Archived chip is on', (
    tester,
  ) async {
    await seed(tester, [_draft('Active One'), _draft('Gone One')]);
    final gone = (await tester.runAsync(() => repo.list()))!
        .firstWhere((s) => s.name == 'Gone One');
    await tester.runAsync(() => repo.archive(gone.id));
    await openStudentsTab(tester);

    expect(find.text('Active One'), findsOneWidget);
    expect(find.text('Gone One'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'আর্কাইভ'));
    await settle(tester);
    expect(find.text('Gone One'), findsOneWidget);
    expect(find.text('Active One'), findsOneWidget);

    // Turn the others off: only archived remain.
    await tester.tap(find.widgetWithText(FilterChip, 'সক্রিয়'));
    await settle(tester);
    expect(find.text('Active One'), findsNothing);
    expect(find.text('Gone One'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'বিরতিতে'));
    await settle(tester);

    // The last selected status cannot be switched off.
    await tester.tap(find.widgetWithText(FilterChip, 'আর্কাইভ'));
    await settle(tester);
    expect(find.text('Gone One'), findsOneWidget);
  });

  appTest('class filter narrows the list', (tester) async {
    await seed(tester, [
      _draft('Aman', classLevel: 'Class 9'),
      _draft('Bijoy', classLevel: 'Class 10'),
    ]);
    await openStudentsTab(tester);

    await tester.tap(find.widgetWithText(Chip, 'শ্রেণি'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Class 9').last);
    await settle(tester);

    expect(find.text('Aman'), findsOneWidget);
    expect(find.text('Bijoy'), findsNothing);

    await tester.tap(find.widgetWithText(Chip, 'Class 9'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('সব শ্রেণি'));
    await settle(tester);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  appTest('batch filter shows only current members', (tester) async {
    await seed(tester, [_draft('In Batch'), _draft('Outside')]);
    final students = (await tester.runAsync(() => repo.list()))!;
    final inBatch = students.firstWhere((s) => s.name == 'In Batch');
    await tester.runAsync(() async {
      await insertBatch(db, 'b1');
      await db
          .into(db.batchMembers)
          .insert(
            BatchMembersCompanion.insert(
              id: 'm1',
              batchId: 'b1',
              studentId: inBatch.id,
              joinedOn: '2026-10-01',
            ),
          );
    });
    await openStudentsTab(tester);

    await tester.tap(find.widgetWithText(Chip, 'ব্যাচ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Math 9').last);
    await settle(tester);

    expect(find.text('In Batch'), findsOneWidget);
    expect(find.text('Outside'), findsNothing);
  });

  appTest('long Bangla names wrap instead of truncating to one line', (
    tester,
  ) async {
    const long =
        'মোহাম্মদ আব্দুল্লাহ আল মামুন চৌধুরী সিদ্দিকী ইসলাম উদ্দিন আহমেদ';
    await seed(tester, [_draft(long)]);
    await openStudentsTab(tester);
    final text = tester.widget<Text>(find.text(long));
    expect(text.maxLines, 2);
  });

  appTest('500 students: list is lazy and the last one is reachable', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await db.batch((b) {
        for (var i = 0; i < 500; i++) {
          b.insert(
            db.students,
            StudentsCompanion.insert(
              id: 's$i',
              name: 'Student ${i.toString().padLeft(3, '0')}',
              joinedOn: '2026-10-01',
              monthlyFee: 1000,
              createdAt: 0,
              updatedAt: 0,
            ),
          );
        }
      });
    });
    await openStudentsTab(tester);

    // Only the visible window is built, not all 500.
    expect(find.byType(ListTile).evaluate().length, lessThan(30));
    expect(find.text('শিক্ষার্থী: ৫০০'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Student 499'),
      find.byType(ListView).last,
      const Offset(0, -400),
      maxIteration: 400,
    );
    expect(find.text('Student 499'), findsOneWidget);
  });

  appTest('tapping a student opens their profile route', (tester) async {
    await seed(tester, [_draft('Rahim')]);
    await openStudentsTab(tester);
    await tester.tap(find.text('Rahim'));
    await settle(tester);
    expect(find.text('শিক্ষার্থীর প্রোফাইল'), findsOneWidget);
  });

  appTest('the add button opens the form route', (tester) async {
    await openStudentsTab(tester);
    await tester.tap(find.text('শিক্ষার্থী যোগ করুন'));
    await settle(tester);
    expect(find.text('শিক্ষার্থী যোগ করুন'), findsWidgets);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
