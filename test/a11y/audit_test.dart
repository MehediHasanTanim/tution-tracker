import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/platform/secure_store.dart';
import 'package:tution_tracker/features/attendance/data/attendance_providers.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/features/lock/data/app_lock_service.dart';
import 'package:tution_tracker/features/onboarding/data/sample_data_service.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';

import '../support/fee_harness.dart';
import '../support/fee_ui.dart';
import '../support/test_app.dart';

/// A name much longer than a list row, with conjuncts (spec edge case 9).
const longName =
    'মোহাম্মদ আবদুর রহমান আল মামুন চৌধুরী সিদ্দিকী বিশ্ববিদ্যালয় উচ্চ বিদ্যালয়';

/// ASCII digits in Bangla-numeral mode are a bug, except phone numbers (kept
/// as people write them) and the like.
final _asciiDigits = RegExp('[0-9]');
final _phone = RegExp(r'^\+?(88)?01[0-9]{9}$');

Set<String> _visibleTexts(WidgetTester tester) => {
  for (final e in find.byType(Text).evaluate())
    if ((e.widget as Text).data != null) (e.widget as Text).data!,
};

Future<void> _seed(WidgetTester tester, FeeHarness h) async {
  await real(tester, () async {
    await SampleDataService(
      h.db,
      h.settings,
      now: () => h.now,
    ).load(AppLanguage.bn);
    await h.students.create(
      const StudentDraft(
        name: longName,
        monthlyFee: 1800,
        joinedOn: LocalDate(2026, 1, 1),
        guardianName: longName,
        guardianPhone: '01712345678',
      ),
    );
  });
}

Future<String> _firstStudentId(WidgetTester tester, FeeHarness h) async {
  final rows = await real(
    tester,
    () => h.db
        .customSelect('SELECT id FROM students ORDER BY name LIMIT 1')
        .get(),
  );
  return rows.first.read<String>('id');
}

void main() {
  testWidgets('the guidelines used here really do catch problems', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: GestureDetector(
                onTap: () {},
                child: Semantics(label: 'tiny', child: const SizedBox()),
              ),
            ),
          ),
        ),
      ),
    );
    expect((await androidTapTargetGuideline.evaluate(tester)).passed, isFalse);
  });

  final problems = <String>[];

  Future<void> audit(
    WidgetTester tester,
    FeeHarness h,
    String name,
    String route, {
    String? tab,
  }) async {
    await pushRoute(tester, route);
    for (var i = 0; i < 6; i++) {
      await settle(tester);
    }
    if (tab != null) {
      await tester.tap(find.widgetWithText(Tab, tab));
      await tester.pumpAndSettle();
    }
    final overflow = tester.takeException();
    if (overflow != null) problems.add('$name: exception: $overflow');

    for (final t in _visibleTexts(tester)) {
      // "English (123)" shows what the digits look like, on purpose.
      if (_asciiDigits.hasMatch(t) &&
          !_phone.hasMatch(t.trim()) &&
          t != 'ইংরেজি (123)') {
        problems.add('$name: ASCII digits in "$t"');
      }
    }

    for (final (label, guideline) in [
      ('tap target', androidTapTargetGuideline),
      ('labelled', labeledTapTargetGuideline),
      ('contrast', textContrastGuideline),
    ]) {
      final r = await guideline.evaluate(tester);
      if (!r.passed) problems.add('$name: $label: ${r.reason}');
    }
  }

  testWidgets('every screen at 1.3x font in Bangla', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    final h = FeeHarness();
    try {
      await _seed(tester, h);
      await pumpHarnessApp(tester, h);
      final id = await _firstStudentId(tester, h);
      final batch = await real(
        tester,
        () => h.db
            .customSelect('SELECT id, name FROM batches LIMIT 1')
            .getSingle(),
      );
      final sheet = attendanceLocation(
        ClassOwner.batch(batch.read<String>('id'), batch.read<String>('name')),
        const LocalDate(2026, 3, 14),
        const ClockTime(17, 0),
      );

      final screens = <(String, String, String?)>[
        ('home', '/home', null),
        ('students', '/students', null),
        ('profile overview', '/students/$id', null),
        ('profile attendance', '/students/$id', 'উপস্থিতি'),
        ('profile fees', '/students/$id', 'ফি'),
        ('new student', '/students/new', null),
        ('attendance sheet', sheet, null),
        ('fees', '/fees', null),
        ('record payment', '/fees/pay/$id', null),
        ('bulk reminders', '/fees/remind', null),
        ('reports', '/reports', null),
        ('settings', '/settings', null),
        ('reminders', '/settings/reminders', null),
        ('templates', '/settings/templates', null),
        ('backup', '/settings/backup', null),
        ('lock settings', '/settings/lock', null),
      ];
      for (final (name, route, tab) in screens) {
        await audit(tester, h, name, route, tab: tab);
      }
    } finally {
      await shutdownApp(tester, h.db);
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  group('small 5-inch screen at 1.3x font', () {
    void smallScreen(WidgetTester tester) {
      tester.view.physicalSize = const Size(720, 1280); // 360 x 640 dp at 2x
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearAllTestValues();
      });
    }

    testWidgets('first-run screens do not overflow', (tester) async {
      smallScreen(tester);
      final h = FeeHarness();
      try {
        await pumpApp(tester, h.db, clock: () => h.now, onboardingDone: null);
        await waitFor(tester);
        for (var step = 0; step < 5; step++) {
          expect(tester.takeException(), isNull, reason: 'step $step');
          final next = find.text('পরের ধাপ');
          if (next.evaluate().isEmpty) break;
          await tester.tap(next);
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        for (final g in [
          androidTapTargetGuideline,
          labeledTapTargetGuideline,
        ]) {
          expect((await g.evaluate(tester)).passed, isTrue);
        }
      } finally {
        await shutdownApp(tester, h.db);
      }
    });

    testWidgets('lock screen does not overflow', (tester) async {
      smallScreen(tester);
      final h = FeeHarness();
      final store = MemorySecureKeyValueStore();
      await AppLockService(store, iterations: 100).enable('123456');
      try {
        await pumpApp(tester, h.db, clock: () => h.now, secureStore: store);
        await waitFor(tester);
        expect(find.text('পিন দিন'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(
          (await androidTapTargetGuideline.evaluate(tester)).passed,
          isTrue,
        );
      } finally {
        await shutdownApp(tester, h.db);
      }
    });
  });
}
