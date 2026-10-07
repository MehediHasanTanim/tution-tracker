import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/app.dart';

Widget _app() =>
    const ProviderScope(child: TuitionTrackerApp(flavor: AppFlavor.dev));

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('সেটিংস'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('starts in Bangla on the Home tab', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final bar = find.byType(NavigationBar);
    expect(bar, findsOneWidget);
    for (final label in ['হোম', 'শিক্ষার্থী', 'ফি', 'রিপোর্ট', 'সেটিংস']) {
      expect(
        find.descendant(of: bar, matching: find.text(label)),
        findsOneWidget,
      );
    }
    expect(find.text('হোম · 0'), findsOneWidget);
  });

  testWidgets('all five tabs navigate', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    for (final label in ['শিক্ষার্থী', 'ফি', 'রিপোর্ট', 'সেটিংস', 'হোম']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(label)),
        findsOneWidget,
      );
    }
  });

  testWidgets('tab state survives switching', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('হোম · 0'));
    await tester.pump();
    expect(find.text('হোম · 1'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('ফি'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('হোম'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('হোম · 1'), findsOneWidget);
  });

  testWidgets('switching locale in Settings changes strings', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _openSettings(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('ভাষা'), findsNothing);
  });
}
