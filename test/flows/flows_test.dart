import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/platform/file_picker_service.dart';
import 'package:tution_tracker/core/platform/share_service.dart';
import 'package:tution_tracker/core/platform/url_launcher_service.dart';
import 'package:tution_tracker/features/backup/data/backup_providers.dart';
import 'package:tution_tracker/features/backup/data/database_swapper.dart';
import 'package:tution_tracker/features/backup/data/restore_service.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';

import '../support/backup_fixture.dart';
import '../support/fake_notifications.dart';
import '../support/fee_ui.dart';
import '../support/test_app.dart';

/// The key user flows of spec section 4.3, driven through the real screens.
/// Each counts its taps against the spec's time target (a tap is about a
/// second for a practised user). The same flows run on an emulator in
/// integration_test/.
class _Launcher implements UrlLauncherService {
  final opened = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return true;
  }
}

/// A tap that is counted, and a clock for the whole flow: what a practised
/// tutor takes (aim and tap, a scroll, a look at each new screen) plus what the
/// app itself takes, measured, to show the result of each action.
class _Taps {
  _Taps(this.tester);

  static const tapSeconds = 1.0;
  static const scrollSeconds = 1.5;
  static const lookSeconds = 1.0;

  final WidgetTester tester;
  int count = 0;
  double humanSeconds = 0;
  final _app = Stopwatch();

  /// What the app spent responding, in seconds (this machine; a phone is
  /// several times slower, so the budgets below keep generous room for it).
  double get appSeconds => _app.elapsedMicroseconds / 1e6;

  /// Modelled seconds for the whole flow, with the app's share multiplied by
  /// [phoneFactor] for a slow phone.
  double total({double phoneFactor = 5}) =>
      humanSeconds + appSeconds * phoneFactor;

  Future<void> on(Finder target) async {
    await tester.tap(target);
    count++;
    humanSeconds += tapSeconds;
  }

  /// A scroll to bring something into view.
  void scrolled() {
    count++;
    humanSeconds += scrollSeconds;
  }

  /// Reading a screen that just appeared.
  void look() => humanSeconds += lookSeconds;

  /// Waits for the app to finish, timing it.
  Future<void> settle() async {
    _app.start();
    await waitFor(tester);
    _app.stop();
  }
}

void main() {
  group('Flow A: daily attendance (under 20 seconds)', () {
    feeUiTest('open the class, tap the absentees, save', (tester, h) async {
      final names = [
        for (var i = 1; i <= 15; i++) 'Student ${i.toString().padLeft(2, '0')}',
      ];
      await real(tester, () async {
        final batch = await h.batches.create(
          const BatchDraft(
            name: 'Math 9',
            scheduleDays: [7], // Sunday: the harness clock is 15 March
            startTime: ClockTime(17, 0),
          ),
        );
        final ids = <String>[];
        for (final n in names) {
          ids.add((await h.addStudent(name: n)).id);
        }
        await h.batches.addMembers(batch.id, ids, const LocalDate(2026, 1, 1));
      });
      await pumpHarnessApp(tester, h);
      await waitFor(tester);

      final taps = _Taps(tester);
      await taps.on(find.text('Math 9')); // Home -> today's class
      await taps.settle();
      taps.look();
      // Everyone starts present; two are away.
      for (final name in ['Student 04', 'Student 11']) {
        if (find.text(name).hitTestable().evaluate().isEmpty) {
          // Fifteen names do not fit one screen: a scroll is a gesture too.
          await tester.scrollUntilVisible(
            find.text(name),
            120,
            scrollable: find.byType(Scrollable).first,
          );
          taps.scrolled();
        }
        await taps.on(find.text(name));
      }
      await tester.pumpAndSettle();
      await taps.on(find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'));
      await taps.settle();

      // Back on Today with the class marked taken: 13 of 15 present.
      expect(find.text('নেওয়া হয়েছে'), findsOneWidget);
      expect(find.textContaining('উপস্থিত ১৩/১৫'), findsOneWidget);
      // One open, two absentees, one save: well inside 20 seconds.
      expect(taps.count, lessThanOrEqualTo(6));
      // The spec's budget, with the app five times slower than here.
      expect(taps.total(), lessThan(20), reason: '${taps.total()} s');

      final marks = await real(
        tester,
        () => h.db
            .customSelect(
              'SELECT s.name, a.status FROM attendance a '
              "JOIN students s ON s.id = a.student_id WHERE a.status = 'absent' "
              'ORDER BY s.name',
            )
            .get(),
      );
      expect(marks.map((r) => r.read<String>('name')), [
        'Student 04',
        'Student 11',
      ]);
    });
  });

  group('Flow B: record a payment (under 15 seconds)', () {
    feeUiTest('Fees tab, tap the student, save', (tester, h) async {
      final s = await seedStudent(tester, h); // owes January to March: 4,500
      await pumpHarnessApp(tester, h);
      await goTab(tester, 'ফি');
      await waitFor(tester);

      final taps = _Taps(tester);
      await taps.on(find.text(s.name)); // the due list row
      await taps.settle();
      taps.look();
      // The amount is already the balance.
      expect(find.text('মোট বাকি: ৳ ৪,৫০০'), findsOneWidget);
      await taps.on(find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'));
      await taps.settle();
      taps.look();
      expect(find.text('পেমেন্ট সংরক্ষিত হয়েছে'), findsOneWidget);
      expect(find.text('রসিদ নং ১'), findsOneWidget);
      await taps.on(find.widgetWithText(FilledButton, 'ঠিক আছে'));
      await tester.pumpAndSettle();

      expect(taps.count, 3);
      expect(taps.total(), lessThan(15), reason: '${taps.total()} s');
      expect(await real(tester, () => h.balanceOf(s.id)), 0);
      // The due list no longer shows them.
      await waitFor(tester);
      expect(find.text('কারও কোনো বাকি নেই'), findsOneWidget);
    });
  });

  group('Flow C: chase overdue fees', () {
    feeUiTest(
      'overdue filter, reminder icon, WhatsApp opens with the message',
      (tester, h) async {
        await real(
          tester,
          () => h.students.create(
            const StudentDraft(
              name: 'Rahim',
              monthlyFee: 1500,
              joinedOn: LocalDate(2026, 1, 1),
              guardianPhone: '01712345678',
            ),
          ),
        );
        final launcher = _Launcher();
        await pumpApp(
          tester,
          h.db,
          clock: () => h.now,
          overrides: [urlLauncherProvider.overrideWithValue(launcher)],
        );
        await goTab(tester, 'ফি');
        await waitFor(tester);

        final taps = _Taps(tester);
        await taps.on(find.text('বিলম্বিত'));
        await tester.pumpAndSettle();
        await taps.on(find.byTooltip('অভিভাবককে রিমাইন্ডার'));
        await waitFor(tester);
        await taps.on(find.text('WhatsApp'));
        await waitFor(tester);

        expect(launcher.opened, hasLength(1));
        final uri = launcher.opened.single;
        expect(uri.host, 'wa.me');
        expect(uri.path, '/8801712345678');
        final text = Uri.decodeComponent(uri.query);
        expect(text, contains('Rahim'));
        expect(text, contains('৳ ৪,৫০০')); // Bangla digits, the default
        expect(text, contains('সম্মানিত অভিভাবক')); // the Bangla template
        expect(taps.count, 3);
      },
    );
  });

  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('tk_flows_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  group('Flow D: back up data', () {
    testWidgets('Settings, Backup, share the file', (tester) async {
      final phone = Phone(Directory(p.join(tmp.path, 'a'))..createSync());
      await real(tester, () async {
        await phone.seed(students: 8, withPhotos: 3);
        await phone.close();
      });
      final share = FakeShare();
      await pumpApp(
        tester,
        openInMemoryDatabase(),
        clock: () => DateTime(2026, 3, 15, 10),
        reopenDb: () => openDatabaseFile(phone.swapper.databaseFile),
        overrides: [
          appDirectoryProvider.overrideWith((ref) async => phone.appDir),
          backupWorkDirProvider.overrideWith((ref) async => phone.workDir),
          shareServiceProvider.overrideWithValue(share),
        ],
      );
      await goTab(tester, 'সেটিংস');
      await waitFor(tester);

      final taps = _Taps(tester);
      await tapCentered(tester, find.text('ব্যাকআপ ও রিস্টোর'));
      taps.count++;
      await waitFor(tester);
      await taps.on(find.text('ব্যাকআপ নিন'));
      for (var i = 0; i < 100 && share.files.isEmpty; i++) {
        await settle(tester);
      }
      await waitFor(tester);

      expect(share.files, hasLength(1));
      expect(share.files.single.path, endsWith('.tkbackup'));
      expect(File(share.files.single.path).lengthSync(), greaterThan(1000));
      expect(find.textContaining('সর্বশেষ ব্যাকআপ:'), findsOneWidget);
      expect(taps.count, lessThanOrEqualTo(4));
      await shutdownApp(tester, openInMemoryDatabase());
    });
  });

  group('Flow E: migrate to a new phone', () {
    testWidgets('restore a backup on a fresh install', (tester) async {
      // The old phone, with a year of records.
      final old = Phone(Directory(p.join(tmp.path, 'old'))..createSync());
      final backup = await real(tester, () async {
        await old.seed(students: 12, withPhotos: 4);
        final file = (await (await old.backupService()).createBackup()).file;
        await old.close();
        return file;
      });

      // The new phone: a fresh install, nothing in it.
      final fresh = Phone(Directory(p.join(tmp.path, 'new'))..createSync());
      final dbFile = fresh.swapper.databaseFile;
      final swapper = FileDatabaseSwapper(dbFile);
      await real(tester, () async {
        await openDatabaseFile(dbFile).then((d) => d.close());
      });
      final picker = FakeFilePicker(backup);
      await pumpApp(
        tester,
        openInMemoryDatabase(),
        clock: () => DateTime(2026, 3, 15, 10),
        reopenDb: () => openDatabaseFile(dbFile),
        overrides: [
          appDirectoryProvider.overrideWith((ref) async => fresh.appDir),
          backupWorkDirProvider.overrideWith((ref) async => fresh.workDir),
          databaseFileProvider.overrideWith((ref) async => dbFile),
          filePickerProvider.overrideWithValue(picker),
          restoreServiceProvider.overrideWith(
            (ref) async => RestoreService(
              swapper: swapper,
              appDir: fresh.appDir,
              workRoot: fresh.workDir,
            ),
          ),
        ],
      );
      await goTab(tester, 'সেটিংস');
      await waitFor(tester);

      final taps = _Taps(tester);
      await tapCentered(tester, find.text('ব্যাকআপ ও রিস্টোর'));
      taps.count++;
      await waitFor(tester);
      await taps.on(find.text('ব্যাকআপ থেকে রিস্টোর'));
      for (
        var i = 0;
        i < 200 && find.text('এই ব্যাকআপ রিস্টোর করবেন?').evaluate().isEmpty;
        i++
      ) {
        await settle(tester);
      }
      await tester.pumpAndSettle();
      // The preview says what is about to arrive.
      expect(find.text('শিক্ষার্থী: ১২'), findsOneWidget);
      expect(find.text('পেমেন্ট: ১২'), findsOneWidget);
      await taps.on(find.text('রিস্টোর করুন'));
      for (
        var i = 0;
        i < 200 && find.text('রিস্টোর সম্পন্ন হয়েছে').evaluate().isEmpty;
        i++
      ) {
        await settle(tester);
      }
      await tester.pumpAndSettle();
      expect(find.text('রিস্টোর সম্পন্ন হয়েছে'), findsOneWidget);
      await shutdownApp(tester, openInMemoryDatabase());
      await real(tester, swapper.close);
      await real(
        tester,
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );

      // Everything arrived: the same rows and the same photos.
      final a = sqlite.sqlite3.open(old.swapper.databaseFile.path);
      final b = sqlite.sqlite3.open(dbFile.path);
      try {
        for (final table in [
          'students',
          'payments',
          'fee_records',
          'payment_allocations',
          'class_sessions',
          'attendance',
          'batches',
          'message_templates',
        ]) {
          expect(
            b
                .select('SELECT * FROM $table ORDER BY 1')
                .map((r) => r.values)
                .toList(),
            a
                .select('SELECT * FROM $table ORDER BY 1')
                .map((r) => r.values)
                .toList(),
            reason: table,
          );
        }
      } finally {
        a.close();
        b.close();
      }
      expect(fresh.photoBytes(), old.photoBytes());
      expect(taps.count, lessThanOrEqualTo(5));
    });
  });
}
