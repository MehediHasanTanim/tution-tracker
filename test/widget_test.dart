import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';

import 'support/test_app.dart';

Finder _navLabel(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

void main() {
  late AppDatabase db;

  setUp(() => db = openInMemoryDatabase());

  void appTest(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      try {
        await body(tester);
      } finally {
        await shutdownApp(tester, db);
      }
    });
  }

  appTest('starts in Bangla on the Home tab', (tester) async {
    await pumpApp(tester, db);
    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['হোম', 'শিক্ষার্থী', 'ফি', 'রিপোর্ট', 'সেটিংস']) {
      expect(_navLabel(label), findsOneWidget);
    }
    expect(find.text('আজ'), findsOneWidget);
  });

  appTest('all five tabs navigate', (tester) async {
    await pumpApp(tester, db);
    for (final label in ['শিক্ষার্থী', 'ফি', 'রিপোর্ট', 'সেটিংস', 'হোম']) {
      await tester.tap(_navLabel(label));
      await settle(tester);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(label)),
        findsOneWidget,
      );
    }
  });

  appTest('tab state survives switching', (tester) async {
    await pumpApp(tester, db);
    await tester.tap(find.byTooltip('পরের দিন'));
    await tester.pump();
    expect(find.widgetWithText(TextButton, 'আজ'), findsOneWidget);

    await tester.tap(_navLabel('ফি'));
    await settle(tester);
    await tester.tap(_navLabel('হোম'));
    await settle(tester);
    expect(find.widgetWithText(TextButton, 'আজ'), findsOneWidget);
  });

  appTest('switching locale in Settings changes strings', (tester) async {
    await pumpApp(tester, db);
    await tester.tap(_navLabel('সেটিংস'));
    await settle(tester);

    await tester.tap(find.text('English'));
    await settle(tester);

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('ভাষা'), findsNothing);
  });
}
