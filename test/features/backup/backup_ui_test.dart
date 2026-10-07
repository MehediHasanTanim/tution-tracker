import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/platform/file_picker_service.dart';
import 'package:tution_tracker/core/platform/share_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/backup/data/backup_providers.dart';
import 'package:tution_tracker/features/backup/data/database_swapper.dart';
import 'package:tution_tracker/features/backup/data/restore_service.dart';
import 'package:tution_tracker/router.dart';

import '../../support/backup_fixture.dart';
import '../../support/fake_notifications.dart';
import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

class _App {
  _App(this.phone, this.share, this.picker)
    : swapper = FileDatabaseSwapper(phone.swapper.databaseFile);

  /// What the restore service uses; closed again by [_shutdown].
  final FileDatabaseSwapper swapper;

  final Phone phone;
  final FakeShare share;
  final FakeFilePicker picker;

  File get dbFile => phone.swapper.databaseFile;
}

late Directory _tmp;
var _n = 0;

/// The app on a real database file in a pretend phone folder, so backup and
/// restore touch real files.
Future<_App> _launch(
  WidgetTester tester, {
  int students = 3,
  FakeShare? share,
  DateTime? now,
  String route = '/settings/backup',
  DateTime? lastBackup,
}) async {
  final phone = Phone(Directory(p.join(_tmp.path, 'p${_n++}'))..createSync());
  await real(tester, () async {
    if (students > 0) await phone.seed(students: students);
    if (lastBackup != null) {
      await (await phone.settings).set(SettingKeys.lastBackupAt, lastBackup);
    }
    await phone.close();
  });
  final app = _App(phone, share ?? FakeShare(), FakeFilePicker());
  await pumpApp(
    tester,
    openInMemoryDatabase(),
    clock: () => now ?? DateTime(2026, 3, 15, 10),
    reopenDb: () => openDatabaseFile(app.dbFile),
    overrides: [
      appDirectoryProvider.overrideWith((ref) async => phone.appDir),
      backupWorkDirProvider.overrideWith((ref) async => phone.workDir),
      databaseFileProvider.overrideWith((ref) async => app.dbFile),
      // The swap of the live database under Riverpod is covered by
      // restore_wiring_test. Here the restore works on the file directly, so
      // these tests exercise the screens (preview, password, messages)
      // without closing a database that has live queries, which fake time
      // cannot do reliably.
      restoreServiceProvider.overrideWith(
        (ref) async => RestoreService(
          swapper: app.swapper,
          appDir: phone.appDir,
          workRoot: phone.workDir,
        ),
      ),
      shareServiceProvider.overrideWithValue(app.share),
      filePickerProvider.overrideWithValue(app.picker),
    ],
  );
  if (route != '/home') {
    // `go`, not `push`: the page must belong to the Settings tab, so that
    // leaving for another tab and coming back finds it still open.
    ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
        .read(routerProvider)
        .go(route);
    await _idle(tester);
  }
  return app;
}

/// A backup made on another phone with [students] students.
Future<File> _backupFile(WidgetTester tester, {int students = 5}) async {
  final other = Phone(Directory(p.join(_tmp.path, 'src${_n++}'))..createSync());
  final file = await real(tester, () async {
    await other.seed(students: students, withPhotos: 1);
    final backup = (await (await other.backupService()).createBackup()).file;
    await other.close();
    return backup;
  });
  return file;
}

/// Lets real time pass until no progress spinner is left. File-backed
/// databases answer from a background isolate, so queries take real time that
/// `pumpAndSettle` (fake time) cannot provide. The budget is generous because
/// a busy machine runs the isolates slowly.
Future<void> _idle(WidgetTester tester, {int tries = 400}) async {
  for (var i = 0; i < tries; i++) {
    await settle(tester);
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
  }
  await tester.pumpAndSettle();
}

/// Waits until [finder] matches, then until everything is idle.
Future<void> _until(
  WidgetTester tester,
  Finder finder, {
  int tries = 400,
}) async {
  for (var i = 0; i < tries && finder.evaluate().isEmpty; i++) {
    await settle(tester);
  }
  await _idle(tester);
}

/// How many students the database file holds. Read after the app has been
/// shut down, when its write-ahead log has been folded into the main file.
int _studentCount(_App app) {
  final db = sqlite.sqlite3.open(app.dbFile.path);
  try {
    return db.select('SELECT COUNT(*) FROM students').first.values.first!
        as int;
  } finally {
    db.close();
  }
}

/// Shuts the app down and gives its database connections time to close.
Future<void> _shutdown(WidgetTester tester, _App app) async {
  // Let screens that are still loading (they read settings) finish first.
  for (var i = 0; i < 6; i++) {
    await settle(tester);
  }
  await shutdownApp(tester, openInMemoryDatabase());
  await real(tester, app.swapper.close);
  await real(
    tester,
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
}

void main() {
  setUp(() => _tmp = Directory.systemTemp.createTempSync('tk_backup_ui_'));
  tearDown(() => _tmp.deleteSync(recursive: true));

  group('backing up', () {
    testWidgets('shares the file and remembers when', (tester) async {
      final app = await _launch(tester);
      expect(find.text('এখনো কোনো ব্যাকআপ নেওয়া হয়নি'), findsOneWidget);

      await tester.tap(find.text('ব্যাকআপ নিন'));
      await _until(tester, find.textContaining('সর্বশেষ ব্যাকআপ:'));

      expect(app.share.files, hasLength(1));
      final shared = app.share.files.single;
      expect(shared.path, endsWith('.tkbackup'));
      expect(File(shared.path).existsSync(), isTrue);
      expect(find.text('এখনো কোনো ব্যাকআপ নেওয়া হয়নি'), findsNothing);
      await shutdownApp(tester, openInMemoryDatabase());
    });

    testWidgets('a dismissed share does not count as a backup', (tester) async {
      final app = await _launch(tester, share: FakeShare(result: false));
      await tester.tap(find.text('ব্যাকআপ নিন'));
      await _idle(tester);
      expect(app.share.files, hasLength(1)); // it was offered...
      expect(find.text('এখনো কোনো ব্যাকআপ নেওয়া হয়নি'), findsOneWidget);
      await shutdownApp(tester, openInMemoryDatabase());
    });

    testWidgets('a password asks twice and protects the file', (tester) async {
      final app = await _launch(tester);
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.text('ব্যাকআপ নিন'));
      await tester.pumpAndSettle();

      // Too short.
      await tester.enterText(find.byType(TextField).first, 'abc');
      await tester.enterText(find.byType(TextField).last, 'abc');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await tester.pump();
      expect(find.text('কমপক্ষে ৬টি অক্ষর দিন'), findsOneWidget);

      // Not the same twice.
      await tester.enterText(find.byType(TextField).first, 'secret1');
      await tester.enterText(find.byType(TextField).last, 'secret2');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await tester.pump();
      expect(find.text('পাসওয়ার্ড দুটি মেলেনি'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'secret1');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await tester.pump();
      await _until(tester, find.textContaining('সর্বশেষ ব্যাকআপ:'));

      final bytes = File(app.share.files.single.path).readAsBytesSync();
      expect(String.fromCharCodes(bytes.sublist(0, 8)), 'TKENC001');
      await shutdownApp(tester, openInMemoryDatabase());
    });
  });

  group('restoring', () {
    testWidgets('previews, confirms, and replaces the data', (tester) async {
      final app = await _launch(tester, students: 3);
      app.picker.file = await _backupFile(tester, students: 5);
      expect(_studentCount(app), 3);

      await tester.tap(find.text('ব্যাকআপ থেকে রিস্টোর'));
      await _until(tester, find.text('এই ব্যাকআপ রিস্টোর করবেন?'));
      expect(find.text('শিক্ষার্থী: ৫'), findsOneWidget);
      expect(find.text('পেমেন্ট: ৫'), findsOneWidget);
      expect(find.textContaining('বর্তমান সব তথ্য মুছে'), findsOneWidget);

      await tester.tap(find.text('রিস্টোর করুন'));
      await _until(tester, find.text('রিস্টোর সম্পন্ন হয়েছে'));
      await tester.tap(find.text('ঠিক আছে'));
      await tester.pumpAndSettle();

      await _shutdown(tester, app);
      expect(_studentCount(app), 5);
    });

    testWidgets('cancelling the preview changes nothing', (tester) async {
      final app = await _launch(tester, students: 3);
      app.picker.file = await _backupFile(tester);
      await tester.tap(find.text('ব্যাকআপ থেকে রিস্টোর'));
      await _until(tester, find.text('এই ব্যাকআপ রিস্টোর করবেন?'));
      await tester.tap(find.text('বাতিল'));
      await _idle(tester);

      await _shutdown(tester, app);
      expect(_studentCount(app), 3);
    });

    testWidgets('backing out of the file picker does nothing', (tester) async {
      final app = await _launch(tester);
      await tester.tap(find.text('ব্যাকআপ থেকে রিস্টোর'));
      await _idle(tester);
      expect(app.picker.picks, 1);
      expect(find.byType(AlertDialog), findsNothing);
      await shutdownApp(tester, openInMemoryDatabase());
    });

    testWidgets('a file that is not a backup is explained', (tester) async {
      final app = await _launch(tester);
      app.picker.file = File(p.join(_tmp.path, 'notes.txt'))
        ..writeAsStringSync('hello');
      await tester.tap(find.text('ব্যাকআপ থেকে রিস্টোর'));
      await _until(tester, find.text('এটি টিউশন খাতার ব্যাকআপ ফাইল নয়'));
      expect(find.text('এটি টিউশন খাতার ব্যাকআপ ফাইল নয়'), findsOneWidget);
      await _shutdown(tester, app);
      expect(_studentCount(app), 3);
    });

    testWidgets('a protected backup asks for its password', (tester) async {
      final app = await _launch(tester, students: 1);
      final other = Phone(Directory(p.join(_tmp.path, 'enc'))..createSync());
      app.picker.file = await real(tester, () async {
        await other.seed(students: 4, withPhotos: 0);
        final f = (await (await other.backupService()).createBackup(
          password: 'open sesame',
        )).file;
        await other.close();
        return f;
      });

      await tester.tap(find.text('ব্যাকআপ থেকে রিস্টোর'));
      await _until(tester, find.text('ব্যাকআপের পাসওয়ার্ড দিন'));

      await tester.enterText(find.byType(TextField), 'wrong');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await _until(
        tester,
        find.text('পাসওয়ার্ড ভুল, অথবা ফাইলটি নষ্ট'),
        tries: 200,
      );
      expect(find.text('পাসওয়ার্ড ভুল, অথবা ফাইলটি নষ্ট'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'open sesame');
      await tester.tap(find.text('সংরক্ষণ করুন'));
      await _until(tester, find.text('এই ব্যাকআপ রিস্টোর করবেন?'));
      expect(find.text('শিক্ষার্থী: ৪'), findsOneWidget);
      await tester.tap(find.text('বাতিল'));
      await _idle(tester);
      await shutdownApp(tester, openInMemoryDatabase());
    });
  });

  group('delete all data', () {
    Future<void> openDialogs(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.text('সব তথ্য মুছে ফেলুন'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tapCentered(tester, find.text('সব তথ্য মুছে ফেলুন'));
      await tester.pumpAndSettle();
    }

    testWidgets('needs two confirmations, the second by typing', (
      tester,
    ) async {
      final app = await _launch(tester, students: 3);
      await openDialogs(tester);
      expect(find.text('সব তথ্য মুছে ফেলবেন?'), findsOneWidget);

      // Cancelling at the first step keeps everything.
      await tester.tap(find.text('বাতিল'));
      await tester.pumpAndSettle();

      await openDialogs(tester);
      await tester.tap(find.text('চালিয়ে যান'));
      await tester.pumpAndSettle();
      expect(find.text('শেষবার নিশ্চিত করুন'), findsOneWidget);

      // The button is off until the word is typed exactly.
      FilledButton button() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'সব মুছে ফেলুন'),
      );
      expect(button().onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'মুছ');
      await tester.pump();
      expect(button().onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'মুছুন');
      await tester.pump();
      expect(button().onPressed, isNotNull);

      await tester.tap(find.widgetWithText(FilledButton, 'সব মুছে ফেলুন'));
      await _until(tester, find.text('সব তথ্য মুছে ফেলা হয়েছে'));
      await tester.tap(find.text('ঠিক আছে'));
      await tester.pumpAndSettle();

      await _shutdown(tester, app);
      expect(_studentCount(app), 0);
    });

    testWidgets('cancelling at the typing step keeps everything', (
      tester,
    ) async {
      final app = await _launch(tester, students: 3);
      await openDialogs(tester);
      await tester.tap(find.text('চালিয়ে যান'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('বাতিল'));
      await _idle(tester);
      await _shutdown(tester, app);
      expect(_studentCount(app), 3);
    });
  });

  group('home banner', () {
    testWidgets('appears when data exists and no backup was ever made', (
      tester,
    ) async {
      await _launch(tester, students: 2, route: '/home');
      await _idle(tester);
      expect(find.text('এখনো ব্যাকআপ নেওয়া হয়নি'), findsOneWidget);
      await shutdownApp(tester, openInMemoryDatabase());
    });

    testWidgets('stays away from an empty app', (tester) async {
      await _launch(tester, students: 0, route: '/home');
      await _idle(tester);
      expect(find.text('এখনো ব্যাকআপ নেওয়া হয়নি'), findsNothing);
      await shutdownApp(tester, openInMemoryDatabase());
    });

    testWidgets('says how old the last backup is', (tester) async {
      await _launch(
        tester,
        students: 2,
        route: '/home',
        lastBackup: DateTime(2026, 2, 23), // 20 days before the test clock
      );
      await _idle(tester);
      expect(find.text('সর্বশেষ ব্যাকআপ ২০ দিন আগে'), findsOneWidget);
      await shutdownApp(tester, openInMemoryDatabase());
    });

    testWidgets('goes away when the backup is recent', (tester) async {
      await _launch(
        tester,
        students: 2,
        route: '/home',
        lastBackup: DateTime(2026, 3, 14),
      );
      await _idle(tester);
      expect(find.textContaining('ব্যাকআপ'), findsNothing);
      await shutdownApp(tester, openInMemoryDatabase());
    });

    testWidgets('its button opens the backup screen', (tester) async {
      await _launch(tester, students: 2, route: '/home');
      await _idle(tester);
      await tester.tap(find.text('ব্যাকআপ নিন'));
      await _idle(tester);
      expect(find.text('ব্যাকআপ ও রিস্টোর'), findsWidgets);
      await shutdownApp(tester, openInMemoryDatabase());
    });
  });
}
