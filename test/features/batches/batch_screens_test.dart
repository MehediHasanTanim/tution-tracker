import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/features/batches/data/batch_repository.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';
import 'package:tution_tracker/router.dart';

import '../../support/test_app.dart';

DateTime _clock() => DateTime(2026, 10, 7, 9);

Future<void> _push(WidgetTester tester, String route) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(NavigationBar)),
  );
  unawaited(container.read(routerProvider).push(route));
  await settle(tester);
  await tester.pumpAndSettle();
}

Future<void> _openBatchesTab(WidgetTester tester, AppDatabase db) async {
  await pumpApp(tester, db, clock: _clock);
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('শিক্ষার্থী'),
    ),
  );
  await settle(tester);
  await tester.tap(find.widgetWithText(Tab, 'ব্যাচসমূহ'));
  await tester.pumpAndSettle();
}

Future<Batch> _batch(
  WidgetTester tester,
  AppDatabase db,
  String name, {
  int fee = 1500,
  String? subject,
}) => tester
    .runAsync(
      () => BatchRepository(db).create(
        BatchDraft(
          name: name,
          scheduleDays: const [1, 3],
          defaultFee: fee,
          subject: subject,
        ),
      ),
    )
    .then((b) => b!);

Future<Student> _student(WidgetTester tester, AppDatabase db, String name) =>
    tester
        .runAsync(
          () => StudentRepository(db).create(
            StudentDraft.quick(
              name: name,
              monthlyFee: 1000,
              joinedOn: const LocalDate(2026, 10, 1),
            ),
          ),
        )
        .then((s) => s!);

Future<void> _join(
  WidgetTester tester,
  AppDatabase db,
  Batch b,
  List<Student> students,
) => tester.runAsync(
  () => BatchRepository(db).addMembers(b.id, [
    for (final s in students) s.id,
  ], const LocalDate(2026, 10, 1)),
);

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _tapAndLoad(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await settle(tester);
  await tester.pumpAndSettle();
}

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Future<List<Batch>> _batches(WidgetTester tester, AppDatabase db) async =>
    (await tester.runAsync(() => db.select(db.batches).get()))!;

void main() {
  group('batches tab', () {
    appTestWidgets('shows an empty state and an Add batch button', (
      tester,
      db,
    ) async {
      await _openBatchesTab(tester, db);
      expect(find.text('এখনও কোনো ব্যাচ নেই'), findsOneWidget);
      expect(find.text('ব্যাচ যোগ করুন'), findsOneWidget);
      expect(find.text('শিক্ষার্থী যোগ করুন'), findsNothing);

      // Back on the first tab the other button returns.
      await tester.tap(find.widgetWithText(Tab, 'সব শিক্ষার্থী'));
      await tester.pumpAndSettle();
      expect(find.text('শিক্ষার্থী যোগ করুন'), findsOneWidget);
    });

    appTestWidgets('lists batches with schedule, members and fee', (
      tester,
      db,
    ) async {
      final b = await _batch(
        tester,
        db,
        'Math 9',
        fee: 125000,
        subject: 'Math',
      );
      await _join(tester, db, b, [
        await _student(tester, db, 'Rahim'),
        await _student(tester, db, 'Karim'),
      ]);
      await _openBatchesTab(tester, db);

      expect(find.text('Math 9'), findsOneWidget);
      expect(find.textContaining('সোমবার, বুধবার'), findsOneWidget);
      expect(find.textContaining('সদস্য: ২ · ৳ ১,২৫,০০০'), findsOneWidget);
    });

    appTestWidgets('archived batches show only with the archived chip', (
      tester,
      db,
    ) async {
      final b = await _batch(tester, db, 'Old Batch');
      await tester.runAsync(() => BatchRepository(db).archive(b.id));
      await _batch(tester, db, 'Live Batch');
      await _openBatchesTab(tester, db);

      expect(find.text('Live Batch'), findsOneWidget);
      expect(find.text('Old Batch'), findsNothing);

      await _tapAndLoad(
        tester,
        find.widgetWithText(FilterChip, 'আর্কাইভ দেখান'),
      );
      expect(find.text('Old Batch'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'আর্কাইভ'), findsOneWidget);
    });
  });

  group('batch form', () {
    appTestWidgets('requires a name and at least one day', (tester, db) async {
      await _openBatchesTab(tester, db);
      await _tap(tester, find.text('ব্যাচ যোগ করুন'));
      await _tap(tester, find.text('সংরক্ষণ করুন'));

      expect(find.text('নাম লিখুন'), findsOneWidget);
      expect(find.text('অন্তত একটি দিন বাছাই করুন'), findsOneWidget);
      expect(await _batches(tester, db), isEmpty);
    });

    appTestWidgets('saves a batch with schedule, duration and fee', (
      tester,
      db,
    ) async {
      await _openBatchesTab(tester, db);
      await _tap(tester, find.text('ব্যাচ যোগ করুন'));

      await tester.enterText(_field('ব্যাচের নাম *'), 'Math 9');
      await tester.enterText(_field('বিষয়'), 'Math');
      await tester.enterText(_field('সময়কাল (মিনিট)'), '৯০');
      await tester.enterText(_field('ডিফল্ট মাসিক ফি (৳)'), '২০০০');
      await tapCentered(tester, find.widgetWithText(FilterChip, 'শনিবার'));
      await tapCentered(tester, find.widgetWithText(FilterChip, 'সোমবার'));
      expect(find.text('অন্তত একটি দিন বাছাই করুন'), findsNothing);

      await _tapAndLoad(tester, find.text('সংরক্ষণ করুন'));

      final b = (await _batches(tester, db)).single;
      expect(b.name, 'Math 9');
      expect(b.subject, 'Math');
      expect(b.scheduleDayList, [1, 6]);
      expect(b.durationMin, 90);
      expect(b.defaultFee, 2000);

      // Back on the list.
      expect(find.text('Math 9'), findsOneWidget);
      expect(find.text('ব্যাচ সংরক্ষিত হয়েছে'), findsOneWidget);
    });

    appTestWidgets('editing loads the batch and saves changes', (
      tester,
      db,
    ) async {
      final b = await _batch(tester, db, 'Math 9', fee: 1500, subject: 'Math');
      await pumpApp(tester, db, clock: _clock);
      await _push(tester, '/batches/${b.id}/edit');

      expect(find.text('ব্যাচ সম্পাদনা'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(_field('ব্যাচের নাম *')).controller!.text,
        'Math 9',
      );
      expect(
        tester
            .widget<TextFormField>(_field('ডিফল্ট মাসিক ফি (৳)'))
            .controller!
            .text,
        '1500',
      );

      await tester.enterText(_field('ব্যাচের নাম *'), 'Math 10');
      await _tapAndLoad(tester, find.text('সংরক্ষণ করুন'));

      final saved = (await _batches(tester, db)).single;
      expect(saved.name, 'Math 10');
      expect(saved.scheduleDayList, [1, 3]);
      expect(saved.defaultFee, 1500);
    });
  });

  group('batch detail and members', () {
    appTestWidgets('shows the header and an empty member list', (
      tester,
      db,
    ) async {
      final b = await _batch(tester, db, 'Math 9', fee: 1500, subject: 'Math');
      await pumpApp(tester, db, clock: _clock);
      await _push(tester, '/batches/${b.id}');

      expect(find.text('Math 9'), findsWidgets);
      expect(find.text('ডিফল্ট ফি: ৳ ১,৫০০'), findsOneWidget);
      expect(find.text('এই ব্যাচে এখনও কেউ নেই'), findsOneWidget);
    });

    appTestWidgets('adds several students at once from the picker', (
      tester,
      db,
    ) async {
      final b = await _batch(tester, db, 'Math 9');
      await _student(tester, db, 'Rahim');
      await _student(tester, db, 'Karim');
      await _student(tester, db, 'Sara');
      await pumpApp(tester, db, clock: _clock);
      await _push(tester, '/batches/${b.id}');

      await _tapAndLoad(tester, find.text('শিক্ষার্থী যোগ করুন'));
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, '০ জনকে যোগ করুন'),
            )
            .enabled,
        isFalse,
      );

      await tester.tap(find.widgetWithText(CheckboxListTile, 'Rahim'));
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Sara'));
      await tester.pump();
      await _tapAndLoad(tester, find.text('২ জনকে যোগ করুন'));

      expect(find.text('শিক্ষার্থী যোগ করা হয়েছে'), findsOneWidget);
      expect(find.text('Rahim'), findsOneWidget);
      expect(find.text('Sara'), findsOneWidget);
      expect(find.text('Karim'), findsNothing);
      expect(find.text('সদস্য · ২'), findsOneWidget);

      final rows = await tester.runAsync(
        () => db.select(db.batchMembers).get(),
      );
      expect(rows!.map((r) => r.joinedOn).toSet(), {'2026-10-07'});
    });

    appTestWidgets('the picker hides current members and can search', (
      tester,
      db,
    ) async {
      final b = await _batch(tester, db, 'Math 9');
      final rahim = await _student(tester, db, 'Rahim');
      await _student(tester, db, 'Karim');
      await _join(tester, db, b, [rahim]);
      await pumpApp(tester, db, clock: _clock);
      await _push(tester, '/batches/${b.id}');

      await _tapAndLoad(tester, find.text('শিক্ষার্থী যোগ করুন'));
      expect(find.widgetWithText(CheckboxListTile, 'Rahim'), findsNothing);
      expect(find.widgetWithText(CheckboxListTile, 'Karim'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'zzz');
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.text('যোগ করার মতো আর কোনো শিক্ষার্থী নেই'), findsOneWidget);
    });

    appTestWidgets('a student in several batches shows them on the profile', (
      tester,
      db,
    ) async {
      final math = await _batch(tester, db, 'Math 9');
      final physics = await _batch(tester, db, 'Physics 9');
      final rahim = await _student(tester, db, 'Rahim');
      await _join(tester, db, math, [rahim]);
      await _join(tester, db, physics, [rahim]);

      await pumpApp(tester, db, clock: _clock);
      await _push(tester, '/students/${rahim.id}');
      expect(find.text('Math 9, Physics 9'), findsOneWidget);
    });

    appTestWidgets('a custom fee is saved, shown, and can be cleared', (
      tester,
      db,
    ) async {
      final b = await _batch(tester, db, 'Math 9', fee: 1500);
      final rahim = await _student(tester, db, 'Rahim');
      await _join(tester, db, b, [rahim]);
      await pumpApp(tester, db, clock: _clock);
      await _push(tester, '/batches/${b.id}');

      expect(find.text('ফি: ৳ ১,৫০০'), findsOneWidget);

      await _tap(tester, find.byType(PopupMenuButton<String>));
      await _tap(tester, find.text('আলাদা ফি নির্ধারণ'));
      await tester.enterText(find.byType(TextField).last, '১০০০');
      await _tapAndLoad(
        tester,
        find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'),
      );

      expect(find.text('ফি: ৳ ১,০০০ · আলাদা ফি'), findsOneWidget);
      var rows = await tester.runAsync(() => db.select(db.batchMembers).get());
      expect(rows!.single.feeOverride, 1000);

      await _tap(tester, find.byType(PopupMenuButton<String>));
      await _tap(tester, find.text('আলাদা ফি নির্ধারণ'));
      await tester.enterText(find.byType(TextField).last, '');
      await _tapAndLoad(
        tester,
        find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'),
      );

      expect(find.text('ফি: ৳ ১,৫০০'), findsOneWidget);
      rows = await tester.runAsync(() => db.select(db.batchMembers).get());
      expect(rows!.single.feeOverride, isNull);
    });

    appTestWidgets('cancelling the fee dialog changes nothing', (
      tester,
      db,
    ) async {
      final b = await _batch(tester, db, 'Math 9');
      await _join(tester, db, b, [await _student(tester, db, 'Rahim')]);
      await pumpApp(tester, db, clock: _clock);
      await _push(tester, '/batches/${b.id}');
      await _tap(tester, find.byType(PopupMenuButton<String>));
      await _tap(tester, find.text('আলাদা ফি নির্ধারণ'));
      await tester.enterText(find.byType(TextField).last, '1');
      await _tapAndLoad(tester, find.text('বাতিল'));
      final rows = await tester.runAsync(
        () => db.select(db.batchMembers).get(),
      );
      expect(rows!.single.feeOverride, isNull);
    });

    appTestWidgets('removing a member records the leave date', (
      tester,
      db,
    ) async {
      final b = await _batch(tester, db, 'Math 9');
      await _join(tester, db, b, [
        await _student(tester, db, 'Rahim'),
        await _student(tester, db, 'Karim'),
      ]);
      await pumpApp(tester, db, clock: _clock);
      await _push(tester, '/batches/${b.id}');

      await _tap(tester, find.byType(PopupMenuButton<String>).last); // Rahim
      await _tapAndLoad(tester, find.text('ব্যাচ থেকে সরান'));

      expect(find.text('Rahim'), findsNothing);
      expect(find.text('Karim'), findsOneWidget);
      expect(find.text('শিক্ষার্থীকে ব্যাচ থেকে সরানো হয়েছে'), findsOneWidget);
      final rows = await tester.runAsync(
        () => db.select(db.batchMembers).get(),
      );
      expect(rows!.where((r) => r.leftOn == '2026-10-07'), hasLength(1));
    });

    appTestWidgets('archive hides the Add button; restore brings it back', (
      tester,
      db,
    ) async {
      final b = await _batch(tester, db, 'Math 9');
      await pumpApp(tester, db, clock: _clock);
      await _push(tester, '/batches/${b.id}');
      expect(find.text('শিক্ষার্থী যোগ করুন'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await _tapAndLoad(tester, find.text('আর্কাইভ করুন'));
      expect(find.text('শিক্ষার্থী যোগ করুন'), findsNothing);
      expect(find.widgetWithText(Chip, 'আর্কাইভ'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await _tapAndLoad(tester, find.text('পুনরুদ্ধার করুন'));
      expect(find.text('শিক্ষার্থী যোগ করুন'), findsOneWidget);
    });

    appTestWidgets('tapping a member opens their profile', (tester, db) async {
      final b = await _batch(tester, db, 'Math 9');
      await _join(tester, db, b, [await _student(tester, db, 'Rahim')]);
      await pumpApp(tester, db, clock: _clock);
      await _push(tester, '/batches/${b.id}');
      await _tapAndLoad(tester, find.text('Rahim'));
      expect(find.widgetWithText(Tab, 'সারসংক্ষেপ'), findsOneWidget);
    });
  });
}
