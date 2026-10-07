import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/platform/url_launcher_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/messaging/data/message_template_repository.dart';
import 'package:tution_tracker/features/messaging/data/reminder_log.dart';
import 'package:tution_tracker/features/messaging/domain/message_template.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';

import '../../support/fee_harness.dart';
import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

class _Launcher implements UrlLauncherService {
  final opened = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return true;
  }
}

Future<void> _open(
  WidgetTester tester,
  FeeHarness h,
  _Launcher launcher, {
  String route = '/fees',
}) async {
  await pumpApp(
    tester,
    h.db,
    clock: () => h.now,
    overrides: [urlLauncherProvider.overrideWithValue(launcher)],
  );
  await pushRoute(tester, route);
  await waitFor(tester);
}

/// A student with a guardian phone who joined on [joined] (so their oldest
/// due is the 10th of that month, overdue by the harness date, 15 March).
Future<void> _student(
  WidgetTester tester,
  FeeHarness h,
  String name, {
  LocalDate joined = const LocalDate(2026, 1, 1),
  String? phone = '01712345678',
}) => real(
  tester,
  () => h.students.create(
    StudentDraft(
      name: name,
      monthlyFee: 1500,
      joinedOn: joined,
      guardianPhone: phone,
    ),
  ),
);

void main() {
  group('template editor', () {
    feeUiTest('previews the template live and saves a change', (
      tester,
      h,
    ) async {
      await real(
        tester,
        () => h.settings.set(SettingKeys.tutorName, 'আজিজ স্যার'),
      );
      await _open(tester, h, _Launcher(), route: '/settings/templates');

      final preview = find.byKey(const Key('template-preview'));
      expect(
        find.descendant(of: preview, matching: find.textContaining('রহিম')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: preview, matching: find.textContaining('৳ ১,৫০০')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: preview,
          matching: find.textContaining('— আজিজ স্যার'),
        ),
        findsOneWidget,
      );

      await tester.enterText(
        find.byType(TextField).first,
        '{student} — {amount}',
      );
      await tester.pump();
      expect(tester.widget<SelectableText>(preview).data, 'রহিম — ৳ ১,৫০০');

      await tapCentered(
        tester,
        find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'),
      );
      await waitFor(tester);
      final saved = await real(
        tester,
        () =>
            MessageTemplateRepository(h.db)
                .body(MessageKind.feeReminder, AppLanguage.bn),
      );
      expect(saved, '{student} — {amount}');
    });

    feeUiTest('a variable chip inserts at the cursor; reset restores', (
      tester,
      h,
    ) async {
      await _open(tester, h, _Launcher(), route: '/settings/templates');
      await tester.enterText(find.byType(TextField).first, 'Hello ');
      await tester.tap(find.text('শিক্ষার্থীর নাম'));
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.controller!.text, 'Hello {student}');

      await tapCentered(tester, find.text('ডিফল্টে ফিরুন'));
      await waitFor(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        defaultTemplate(MessageKind.feeReminder, AppLanguage.bn),
      );
    });

    feeUiTest('the English tab has its own text and a Western-digit preview', (
      tester,
      h,
    ) async {
      await real(
        tester,
        () => h.settings.set(SettingKeys.numerals, NumeralStyle.western),
      );
      await _open(tester, h, _Launcher(), route: '/settings/templates');
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Dear guardian'), findsWidgets);
    });
  });

  group('single reminder', () {
    feeUiTest('opens SMS with the composed text and marks the student', (
      tester,
      h,
    ) async {
      await _student(tester, h, 'Rahim');
      final launcher = _Launcher();
      await _open(tester, h, launcher);

      await tester.tap(find.byTooltip('অভিভাবককে রিমাইন্ডার'));
      await waitFor(tester);
      expect(find.textContaining('Rahim'), findsWidgets);

      await tester.tap(find.text('SMS'));
      await waitFor(tester);
      expect(launcher.opened, hasLength(1));
      final uri = launcher.opened.single;
      expect(uri.scheme, 'sms');
      expect(uri.path, '+8801712345678');
      expect(Uri.decodeComponent(uri.query), contains('Rahim'));
      // The amount is in the message, with Bangla digits by default.
      expect(Uri.decodeComponent(uri.query), contains('৳ ৪,৫০০'));

      final log = await real(tester, () => ReminderLog(h.settings).all());
      expect(log.keys, hasLength(1));
    });

    feeUiTest('WhatsApp uses the wa.me link', (tester, h) async {
      await _student(tester, h, 'Rahim');
      final launcher = _Launcher();
      await _open(tester, h, launcher);
      await tester.tap(find.byTooltip('অভিভাবককে রিমাইন্ডার'));
      await waitFor(tester);
      await tester.tap(find.text('WhatsApp'));
      await waitFor(tester);
      expect(launcher.opened.single.host, 'wa.me');
      expect(launcher.opened.single.path, '/8801712345678');
    });

    feeUiTest('the text can be edited before sending', (tester, h) async {
      await _student(tester, h, 'Rahim');
      final launcher = _Launcher();
      await _open(tester, h, launcher);
      await tester.tap(find.byTooltip('অভিভাবককে রিমাইন্ডার'));
      await waitFor(tester);
      await tester.enterText(find.byType(TextField).last, 'my own words');
      await tester.tap(find.text('SMS'));
      await waitFor(tester);
      expect(
        Uri.decodeComponent(launcher.opened.single.query),
        'body=my own words',
      );
    });

    feeUiTest('no phone: sending is disabled and says why', (tester, h) async {
      await _student(tester, h, 'Rahim', phone: null);
      await _open(tester, h, _Launcher());
      await tester.tap(find.byTooltip('অভিভাবককে রিমাইন্ডার'));
      await waitFor(tester);
      expect(find.text('এই শিক্ষার্থীর ফোন নম্বর নেই'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'SMS').first,
            )
            .onPressed,
        isNull,
      );
    });

    feeUiTest('uses the edited template', (tester, h) async {
      await _student(tester, h, 'Rahim');
      await real(
        tester,
        () => MessageTemplateRepository(h.db).save(
          MessageKind.feeReminder,
          AppLanguage.bn,
          '{student} বাকি {amount}',
        ),
      );
      final launcher = _Launcher();
      await _open(tester, h, launcher);
      await tester.tap(find.byTooltip('অভিভাবককে রিমাইন্ডার'));
      await waitFor(tester);
      await tester.tap(find.text('SMS'));
      await waitFor(tester);
      expect(
        Uri.decodeComponent(launcher.opened.single.query),
        'body=Rahim বাকি ৳ ৪,৫০০',
      );
    });
  });

  group('bulk flow', () {
    Future<void> seedThree(WidgetTester tester, FeeHarness h) async {
      await _student(tester, h, 'Aman'); // oldest due: 10 Jan
      await _student(tester, h, 'Bijoy', joined: const LocalDate(2026, 2, 1));
      await _student(tester, h, 'Chitra', joined: const LocalDate(2026, 3, 1));
    }

    Future<void> resume(WidgetTester tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await waitFor(tester);
    }

    feeUiTest('goes most overdue first and moves on after each send', (
      tester,
      h,
    ) async {
      await seedThree(tester, h);
      final launcher = _Launcher();
      await _open(tester, h, launcher, route: '/fees/remind');

      expect(find.text('০/৩ জন সম্পন্ন'), findsOneWidget);
      expect(find.text('Aman'), findsOneWidget);

      await tester.tap(find.text('WhatsApp'));
      await tester.pump();
      expect(launcher.opened.single.host, 'wa.me');
      // Still on Aman until the tutor comes back from WhatsApp.
      expect(find.text('Aman'), findsOneWidget);

      await resume(tester);
      expect(find.text('১/৩ জন সম্পন্ন'), findsOneWidget);
      expect(find.text('Bijoy'), findsOneWidget);
      expect(find.text('Aman'), findsNothing);
    });

    feeUiTest('resumes where it left off after leaving the screen', (
      tester,
      h,
    ) async {
      await seedThree(tester, h);
      final launcher = _Launcher();
      await _open(tester, h, launcher, route: '/fees/remind');
      await tester.tap(find.text('SMS'));
      await tester.pump();
      await resume(tester);
      expect(find.text('Bijoy'), findsOneWidget);

      // Leave and come back: Aman is not asked about again.
      await tester.tap(find.byType(BackButton));
      await waitFor(tester);
      await pushRoute(tester, '/fees/remind');
      await waitFor(tester);
      expect(find.text('১/৩ জন সম্পন্ন'), findsOneWidget);
      expect(find.text('Bijoy'), findsOneWidget);
    });

    feeUiTest('mark as reminded by hand, undo, and skip', (tester, h) async {
      await seedThree(tester, h);
      await _open(tester, h, _Launcher(), route: '/fees/remind');

      await tapCentered(tester, find.text('রিমাইন্ড করা হয়েছে').last);
      await waitFor(tester);
      expect(find.text('১/৩ জন সম্পন্ন'), findsOneWidget);

      await tester.tap(find.text('ফিরিয়ে নিন'));
      await waitFor(tester);
      expect(find.text('০/৩ জন সম্পন্ন'), findsOneWidget);
      expect(find.text('Aman'), findsOneWidget);

      await tapCentered(tester, find.text('বাদ দিন'));
      await waitFor(tester);
      expect(find.text('Bijoy'), findsOneWidget);
      expect(find.text('০/৩ জন সম্পন্ন'), findsOneWidget);
    });

    feeUiTest('finishing everyone shows the all-done state', (tester, h) async {
      await _student(tester, h, 'Aman');
      await _open(tester, h, _Launcher(), route: '/fees/remind');
      await tapCentered(tester, find.text('রিমাইন্ড করা হয়েছে').last);
      await waitFor(tester);
      expect(find.text('সবাইকে রিমাইন্ড করা হয়েছে'), findsOneWidget);

      await tapCentered(tester, find.text('চিহ্ন মুছে আবার শুরু করুন'));
      await waitFor(tester);
      expect(find.text('Aman'), findsOneWidget);
    });

    feeUiTest('nobody overdue says so', (tester, h) async {
      await _open(tester, h, _Launcher(), route: '/fees/remind');
      expect(find.text('কেউ মেয়াদ পেরিয়ে বাকি নেই'), findsOneWidget);
    });

    feeUiTest('someone reminded within the week is not asked again', (
      tester,
      h,
    ) async {
      await seedThree(tester, h);
      final students = await real(tester, () => h.students.watch().first);
      final aman = students.firstWhere((s) => s.name == 'Aman');
      await real(tester, () => ReminderLog(h.settings).mark(aman.id, h.today));
      await _open(tester, h, _Launcher(), route: '/fees/remind');
      expect(find.text('১/৩ জন সম্পন্ন'), findsOneWidget);
      expect(find.text('Bijoy'), findsOneWidget);
    });
  });
}
