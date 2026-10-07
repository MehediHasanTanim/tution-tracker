import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/platform/photo_picker.dart';
import 'package:tution_tracker/features/students/data/photo_store.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';
import 'package:tution_tracker/router.dart';

import '../../support/test_app.dart';

class FakePicker implements PhotoPicker {
  FakePicker(this.result);

  Uint8List? result;
  final requested = <PhotoSource>[];

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    requested.add(source);
    return result;
  }
}

Uint8List _bigPhoto() {
  final image = img.Image(width: 1600, height: 1200);
  for (final p in image) {
    p
      ..r = 255 * p.x / 1600
      ..g = 255 * p.y / 1200
      ..b = 128;
  }
  return Uint8List.fromList(img.encodeJpg(image));
}

class _Env {
  _Env(this.dir, this.store, this.picker);
  final Directory dir;
  final PhotoStore store;
  final FakePicker picker;

  List<File> get files => Directory('${dir.path}/photos').existsSync()
      ? Directory('${dir.path}/photos').listSync().whereType<File>().toList()
      : [];
}

_Env _env() {
  final dir = Directory.systemTemp.createTempSync('tk_photo_test_');
  addTearDown(() => dir.deleteSync(recursive: true));
  return _Env(dir, PhotoStore(dir), FakePicker(_bigPhoto()));
}

Future<void> _push(WidgetTester tester, String route) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(NavigationBar)),
  );
  unawaited(container.read(routerProvider).push(route));
  await settle(tester);
  await tester.pumpAndSettle();
}

Future<List<Student>> _students(WidgetTester tester, AppDatabase db) async =>
    (await tester.runAsync(() => db.select(db.students).get()))!;

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.text('সংরক্ষণ করুন'));
  // File writes are real I/O, which only progresses in real time.
  for (var i = 0; i < 4; i++) {
    await settle(tester);
  }
  await tester.pumpAndSettle();
}

Future<Student> _seedWithPhoto(
  WidgetTester tester,
  AppDatabase db,
  _Env env,
) async {
  return (await tester.runAsync(() async {
    final repo = StudentRepository(db);
    final s = await repo.create(
      const StudentDraft.quick(
        name: 'Rahim',
        monthlyFee: 1000,
        joinedOn: LocalDate(2026, 10, 1),
      ),
    );
    final path = await env.store.save(s.id, Uint8List.fromList([1, 2, 3]));
    await repo.setPhotoPath(s.id, path);
    return (await repo.getById(s.id))!;
  }))!;
}

void main() {
  group('add form', () {
    appTestWidgets('a picked photo is compressed and stored under 80 KB', (
      tester,
      db,
    ) async {
      final env = _env();
      await pumpApp(tester, db, photoStore: env.store, photoPicker: env.picker);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('শিক্ষার্থী'),
        ),
      );
      await settle(tester);
      await _tapText(tester, 'শিক্ষার্থী যোগ করুন');
      await _tapText(tester, 'আরও তথ্য যোগ করুন');

      await tester.enterText(
        find.widgetWithText(TextFormField, 'নাম *'),
        'Rahim',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'মাসিক ফি (৳) *'),
        '1500',
      );
      await _tapText(tester, 'ছবি যোগ করুন');
      await _tapText(tester, 'গ্যালারি থেকে বাছাই করুন');
      expect(env.picker.requested, [PhotoSource.gallery]);
      expect(find.text('ছবি পরিবর্তন করুন'), findsOneWidget);

      await _save(tester);

      final student = (await _students(tester, db)).single;
      expect(student.photoPath, matches(RegExp(r'^photos/.+_\d+\.jpg$')));
      final file = env.store.fileFor(student.photoPath!);
      expect(file.existsSync(), isTrue);
      final bytes = file.readAsBytesSync();
      expect(bytes.length, lessThan(80 * 1024));
      expect(img.decodeJpg(bytes)!.width, 512);
      expect(env.files, hasLength(1));
    });

    appTestWidgets('cancelling the picker leaves the student without a photo', (
      tester,
      db,
    ) async {
      final env = _env()..picker.result = null;
      await pumpApp(tester, db, photoStore: env.store, photoPicker: env.picker);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('শিক্ষার্থী'),
        ),
      );
      await settle(tester);
      await _tapText(tester, 'শিক্ষার্থী যোগ করুন');
      await _tapText(tester, 'আরও তথ্য যোগ করুন');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'নাম *'),
        'Rahim',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'মাসিক ফি (৳) *'),
        '1500',
      );
      await _tapText(tester, 'ছবি যোগ করুন');
      await _tapText(tester, 'ছবি তুলুন');
      expect(env.picker.requested, [PhotoSource.camera]);
      expect(find.text('ছবি যোগ করুন'), findsOneWidget); // unchanged

      await _save(tester);
      expect((await _students(tester, db)).single.photoPath, isNull);
      expect(env.files, isEmpty);
    });

    appTestWidgets('an unreadable image shows an error and is not saved', (
      tester,
      db,
    ) async {
      final env = _env()..picker.result = Uint8List.fromList([1, 2, 3]);
      await pumpApp(tester, db, photoStore: env.store, photoPicker: env.picker);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('শিক্ষার্থী'),
        ),
      );
      await settle(tester);
      await _tapText(tester, 'শিক্ষার্থী যোগ করুন');
      await _tapText(tester, 'আরও তথ্য যোগ করুন');
      await _tapText(tester, 'ছবি যোগ করুন');
      await _tapText(tester, 'গ্যালারি থেকে বাছাই করুন');
      await tester.pump();
      expect(find.text('ছবিটি ব্যবহার করা গেল না'), findsOneWidget);
      expect(find.text('ছবি যোগ করুন'), findsOneWidget);
    });

    appTestWidgets('quick-add has no photo control', (tester, db) async {
      await pumpApp(tester, db);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('শিক্ষার্থী'),
        ),
      );
      await settle(tester);
      await _tapText(tester, 'শিক্ষার্থী যোগ করুন');
      expect(find.text('ছবি যোগ করুন'), findsNothing);
    });
  });

  group('edit form', () {
    appTestWidgets('replacing a photo stores the new one and deletes the old', (
      tester,
      db,
    ) async {
      final env = _env();
      final student = await _seedWithPhoto(tester, db, env);
      final oldPath = student.photoPath!;
      await pumpApp(tester, db, photoStore: env.store, photoPicker: env.picker);
      await _push(tester, '/students/${student.id}/edit');

      await _tapText(tester, 'ছবি পরিবর্তন করুন');
      await _tapText(tester, 'গ্যালারি থেকে বাছাই করুন');
      await _save(tester);

      final updated = (await _students(tester, db)).single;
      expect(updated.photoPath, isNot(oldPath));
      expect(env.store.fileFor(oldPath).existsSync(), isFalse);
      expect(env.store.fileFor(updated.photoPath!).existsSync(), isTrue);
      expect(env.files, hasLength(1));
    });

    appTestWidgets('removing a photo deletes the file and clears the path', (
      tester,
      db,
    ) async {
      final env = _env();
      final student = await _seedWithPhoto(tester, db, env);
      await pumpApp(tester, db, photoStore: env.store, photoPicker: env.picker);
      await _push(tester, '/students/${student.id}/edit');

      await _tapText(tester, 'ছবি পরিবর্তন করুন');
      await _tapText(tester, 'ছবি সরান');
      expect(find.text('ছবি যোগ করুন'), findsOneWidget);
      await _save(tester);

      expect((await _students(tester, db)).single.photoPath, isNull);
      expect(env.files, isEmpty);
    });

    appTestWidgets('saving without touching the photo keeps it', (
      tester,
      db,
    ) async {
      final env = _env();
      final student = await _seedWithPhoto(tester, db, env);
      await pumpApp(tester, db, photoStore: env.store, photoPicker: env.picker);
      await _push(tester, '/students/${student.id}/edit');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'নাম *'),
        'Rahim Uddin',
      );
      await _save(tester);

      final updated = (await _students(tester, db)).single;
      expect(updated.photoPath, student.photoPath);
      expect(env.files, hasLength(1));
    });
  });

  group('display and delete', () {
    appTestWidgets('the list and profile show the photo', (tester, db) async {
      final env = _env();
      final student = await _seedWithPhoto(tester, db, env);
      await pumpApp(tester, db, photoStore: env.store, photoPicker: env.picker);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('শিক্ষার্থী'),
        ),
      );
      await settle(tester);

      final tileAvatar = tester.widget<CircleAvatar>(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.byType(CircleAvatar),
        ),
      );
      expect(tileAvatar.foregroundImage, isA<ResizeImage>());

      await _push(tester, '/students/${student.id}');
      final big = tester
          .widgetList<CircleAvatar>(find.byType(CircleAvatar))
          .where((a) => a.radius == 32)
          .single;
      expect(big.foregroundImage, isA<ResizeImage>());
    });

    appTestWidgets('a student without a photo shows their initial', (
      tester,
      db,
    ) async {
      await tester.runAsync(
        () => StudentRepository(db).create(
          const StudentDraft.quick(
            name: 'Rahim',
            monthlyFee: 1000,
            joinedOn: LocalDate(2026, 10, 1),
          ),
        ),
      );
      await pumpApp(tester, db);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('শিক্ষার্থী'),
        ),
      );
      await settle(tester);
      final avatar = tester.widget<CircleAvatar>(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.byType(CircleAvatar),
        ),
      );
      expect(avatar.foregroundImage, isNull);
      expect(
        find.descendant(
          of: find.byType(CircleAvatar),
          matching: find.text('R'),
        ),
        findsOneWidget,
      );
    });

    appTestWidgets('deleting a student removes their photo file', (
      tester,
      db,
    ) async {
      final env = _env();
      final student = await _seedWithPhoto(tester, db, env);
      expect(env.files, hasLength(1));
      await pumpApp(tester, db, photoStore: env.store, photoPicker: env.picker);
      await _push(tester, '/students/${student.id}');

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

      expect(await _students(tester, db), isEmpty);
      expect(env.files, isEmpty);
    });

    appTestWidgets('archiving keeps the photo file', (tester, db) async {
      final env = _env();
      final student = await _seedWithPhoto(tester, db, env);
      await pumpApp(tester, db, photoStore: env.store, photoPicker: env.picker);
      await _push(tester, '/students/${student.id}');
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('আর্কাইভ করুন'));
      await settle(tester);
      expect(env.files, hasLength(1));
    });
  });
}
