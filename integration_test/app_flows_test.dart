import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:tution_tracker/app.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/platform/share_service.dart';
import 'package:tution_tracker/features/backup/data/backup_providers.dart';
import 'package:tution_tracker/features/batches/data/batch_providers.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:tution_tracker/features/students/data/student_providers.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';

/// Runs the real app on an emulator or phone: the real database file, secure
/// storage and notification plugin. Each test starts from an empty app folder.
///
///     flutter test integration_test --flavor dev
///
/// The same flows are covered, with fakes for the platform, in test/flows/.
/// The system share sheet cannot be driven from here, so sharing is replaced
/// by a recorder.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late _Shares shares;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('tk_it_');
    shares = _Shares();
  });

  tearDown(() => dir.deleteSync(recursive: true));

  Future<ProviderContainer> launch(WidgetTester tester) async {
    final file = File(p.join(dir.path, 'data.sqlite'));
    final app = Directory(p.join(dir.path, 'app'))..createSync();
    final work = Directory(p.join(dir.path, 'work'))..createSync();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appFlavorProvider.overrideWithValue(AppFlavor.dev),
          databaseOpenerProvider.overrideWithValue(
            () => openDatabaseFile(file),
          ),
          databaseFileProvider.overrideWith((ref) async => file),
          appDirectoryProvider.overrideWith((ref) async => app),
          backupWorkDirProvider.overrideWith((ref) async => work),
          shareServiceProvider.overrideWithValue(shares),
        ],
        child: const TuitionTrackerApp(flavor: AppFlavor.dev),
      ),
    );
    await _settle(tester);
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  testWidgets('first run: pick a language and reach an empty Home', (
    tester,
  ) async {
    await launch(tester);
    expect(find.text('টিউশন খাতায় স্বাগতম'), findsOneWidget);
    await tester.tap(find.text('পরের ধাপ'));
    await _settle(tester);
    await tester.tap(find.text('এড়িয়ে যান'));
    await _settle(tester);
    await tester.tap(find.text('খালি অ্যাপ দিয়ে শুরু করুন'));
    await _settle(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
    binding.reportData = {'flow': 'first run'};
  });

  testWidgets('flow A and B: attendance, then a payment', (tester) async {
    final c = await launch(tester);
    await _skipOnboarding(tester);

    // A class today with three students, set up through the app's own data
    // layer (the same code the forms call).
    final today = LocalDate.fromDateTime(c.read(clockProvider)());
    final batches = await c.read(batchRepositoryProvider.future);
    final students = await c.read(studentRepositoryProvider.future);
    final batch = await batches.create(
      BatchDraft(
        name: 'Math 9',
        scheduleDays: [today.isoWeekday],
        startTime: const ClockTime(17, 0),
      ),
    );
    final ids = <String>[];
    for (final n in ['Aman', 'Bijoy', 'Chitra']) {
      ids.add(
        (await students.create(
          StudentDraft(name: n, monthlyFee: 1500, joinedOn: today),
        )).id,
      );
    }
    await batches.addMembers(batch.id, ids, today);
    await _settle(tester);

    // Flow A: open today's class, mark one absent, save. The time the app
    // itself takes to answer is measured on the device; with the person's
    // taps (about a second each) the spec's 20 and 15 seconds must hold.
    final appTime = Stopwatch();
    Future<void> answered() async {
      appTime.start();
      await answered();
      appTime.stop();
    }

    await tester.tap(find.text('Math 9'));
    await answered();
    await tester.tap(find.text('Bijoy'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'));
    await answered();
    expect(find.text('নেওয়া হয়েছে'), findsOneWidget);

    final appA = appTime.elapsed;
    expect(
      appA.inMilliseconds,
      lessThan(5000),
      reason: 'flow A: the app took $appA to respond',
    );
    appTime.reset();

    // Flow B: the Fees tab lists them; pay Aman in full.
    await tester.tap(find.text('ফি').last);
    await answered();
    await tester.tap(find.text('Aman'));
    await answered();
    await tester.tap(find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'));
    await answered();
    expect(find.text('পেমেন্ট সংরক্ষিত হয়েছে'), findsOneWidget);
    expect(
      appTime.elapsed.inMilliseconds,
      lessThan(4000),
      reason: 'flow B: the app took ${appTime.elapsed} to respond',
    );
  });

  testWidgets('flow D: back up from Settings', (tester) async {
    await launch(tester);
    await _skipOnboarding(tester);
    await tester.tap(find.text('সেটিংস').last);
    await _settle(tester);
    await tester.scrollUntilVisible(
      find.text('ব্যাকআপ ও রিস্টোর'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('ব্যাকআপ ও রিস্টোর'));
    await _settle(tester);
    await tester.tap(find.text('ব্যাকআপ নিন'));
    await _settle(tester, seconds: 20);
    expect(shares.paths, hasLength(1));
    expect(File(shares.paths.single).existsSync(), isTrue);
  });
}

Future<void> _skipOnboarding(WidgetTester tester) async {
  if (find.text('পরের ধাপ').evaluate().isEmpty) return;
  await tester.tap(find.text('পরের ধাপ'));
  await _settle(tester);
  await tester.tap(find.text('এড়িয়ে যান'));
  await _settle(tester);
  await tester.tap(find.text('খালি অ্যাপ দিয়ে শুরু করুন'));
  await _settle(tester);
}

/// Lets real time pass until the screen stops changing.
Future<void> _settle(WidgetTester tester, {int seconds = 10}) async {
  final end = DateTime.now().add(Duration(seconds: seconds));
  do {
    await tester.pump(const Duration(milliseconds: 250));
  } while (tester.binding.hasScheduledFrame && DateTime.now().isBefore(end));
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    Duration(seconds: seconds),
  );
}

class _Shares implements ShareService {
  final paths = <String>[];

  @override
  Future<bool> shareFile(
    String path, {
    required String mimeType,
    String? text,
    String? subject,
  }) async {
    paths.add(path);
    return true;
  }

  @override
  Future<bool> shareText(String text, {String? subject}) async => true;
}
