import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/app.dart';

Widget _app() =>
    const ProviderScope(child: TuitionTrackerApp(flavor: AppFlavor.dev));

void main() {
  testWidgets('starts in Bangla', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('টিউশন খাতা'), findsOneWidget);
  });

  testWidgets('switching locale changes strings', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Tuition Khata'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('টিউশন খাতা'), findsNothing);
  });

  testWidgets('Material widgets resolve the Bangla locale', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold));
    expect(Localizations.localeOf(context), const Locale('bn'));
  });
}
