import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';

import '../../support/fee_harness.dart';
import '../../support/fee_ui.dart';

/// The harness clock is Sunday 2026-03-15. Seeds a Sunday batch "Math 9"
/// with [names] enrolled and returns the batch id.
Future<String> _seedBatch(
  WidgetTester tester,
  FeeHarness h,
  List<String> names,
) => real(tester, () async {
  final batch = await h.batches.create(
    const BatchDraft(
      name: 'Math 9',
      scheduleDays: [7],
      startTime: ClockTime(17, 0),
    ),
  );
  final ids = <String>[];
  for (final n in names) {
    ids.add((await h.addStudent(name: n)).id);
  }
  await h.batches.addMembers(batch.id, ids, const LocalDate(2026, 1, 1));
  return batch.id;
});

Future<void> _openClass(WidgetTester tester) async {
  await tester.tap(find.text('Math 9'));
  await waitFor(tester);
}

void main() {
  feeUiTest('Today lists the scheduled class as not taken', (tester, h) async {
    await _seedBatch(tester, h, ['Aman']);
    await pumpHarnessApp(tester, h);
    await waitFor(tester);

    expect(find.text('Math 9'), findsOneWidget);
    expect(find.text('নেওয়া হয়নি'), findsOneWidget);
  });

  feeUiTest('a day with no classes says so', (tester, h) async {
    await pumpHarnessApp(tester, h);
    await waitFor(tester);
    expect(find.text('এই দিনে কোনো ক্লাস নেই'), findsOneWidget);
  });

  feeUiTest('mark one absentee, save, and the class shows as taken', (
    tester,
    h,
  ) async {
    await _seedBatch(tester, h, ['Aman', 'Bijoy', 'Chitra']);
    await pumpHarnessApp(tester, h);
    await waitFor(tester);
    await _openClass(tester);

    // Everyone starts present; one tap on a name flips to absent.
    await tester.tap(find.text('Bijoy'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'));
    await waitFor(tester);

    expect(find.text('নেওয়া হয়েছে'), findsOneWidget);
    expect(find.textContaining('উপস্থিত ২/৩'), findsOneWidget);
  });

  feeUiTest('leaving with unsaved changes asks first', (tester, h) async {
    await _seedBatch(tester, h, ['Aman']);
    await pumpHarnessApp(tester, h);
    await waitFor(tester);
    await _openClass(tester);

    await tester.tap(find.text('Aman'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('পরিবর্তন সংরক্ষণ করবেন?'), findsOneWidget);

    await tester.tap(find.text('বাদ দিন'));
    await waitFor(tester);
    expect(find.text('নেওয়া হয়নি'), findsOneWidget);
  });

  feeUiTest('cancelling a class marks it and it can be restored', (
    tester,
    h,
  ) async {
    await _seedBatch(tester, h, ['Aman']);
    await pumpHarnessApp(tester, h);
    await waitFor(tester);
    await _openClass(tester);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ক্লাস বাতিল করুন').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'),
      ),
    );
    await waitFor(tester);

    expect(find.text('বাতিল'), findsWidgets);

    await _openClass(tester);
    expect(find.text('এই ক্লাস বাতিল করা হয়েছে'), findsOneWidget);
    await tester.tap(find.text('ক্লাস আবার চালু করুন'));
    await waitFor(tester);
    expect(find.text('এই ক্লাস বাতিল করা হয়েছে'), findsNothing);
  });

  feeUiTest('an extra class can be added for a batch', (tester, h) async {
    await real(tester, () async {
      await h.batches.create(
        const BatchDraft(name: 'Physics', scheduleDays: [1]),
      );
    });
    await pumpHarnessApp(tester, h);
    await waitFor(tester);

    await tester.tap(find.text('অতিরিক্ত ক্লাস'));
    await waitFor(tester);
    await tester.tap(find.text('Physics'));
    await waitFor(tester);
    // The sheet opens for the new class; going back shows it on Today.
    await tester.tap(find.byType(BackButton));
    await waitFor(tester);
    expect(find.text('Physics'), findsOneWidget);
    expect(find.textContaining('অতিরিক্ত'), findsWidgets);
  });

  feeUiTest('student attendance tab shows the month and an empty note', (
    tester,
    h,
  ) async {
    final s = await seedStudent(tester, h);
    await pumpHarnessApp(tester, h);
    await pushRoute(tester, '/students/${s.id}');
    await tester.tap(find.widgetWithText(Tab, 'উপস্থিতি'));
    await waitFor(tester);

    expect(find.text('এই মাসে কোনো ক্লাসের তথ্য নেই'), findsOneWidget);
    expect(find.text('মার্চ ২০২৬'), findsOneWidget);
    await tester.tap(find.byTooltip('আগের মাস'));
    await tester.pumpAndSettle();
    expect(find.text('ফেব্রুয়ারি ২০২৬'), findsOneWidget);
  });
}
