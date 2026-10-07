import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/router.dart';

import 'fee_harness.dart';
import 'test_app.dart';

/// A UI test over a [FeeHarness]: the harness's database and clock drive the
/// real app, so data is seeded through the same code the app uses.
void feeUiTest(
  String description,
  Future<void> Function(WidgetTester tester, FeeHarness h) body,
) {
  testWidgets(description, (tester) async {
    final h = FeeHarness(); // clock: 2026-03-15 10:00
    try {
      await body(tester, h);
    } finally {
      await shutdownApp(tester, h.db);
    }
  });
}

DateTime clockOf(FeeHarness h) => h.now;

/// Mounts the app on the harness database with its clock.
Future<void> pumpHarnessApp(
  WidgetTester tester,
  FeeHarness h, {
  List<dynamic> extra = const [],
}) => pumpApp(tester, h.db, clock: () => h.now);

/// Runs [work] against the harness in real time.
Future<T> real<T>(WidgetTester tester, Future<T> Function() work) async =>
    (await tester.runAsync(work)) as T;

Future<void> pushRoute(WidgetTester tester, String route) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(NavigationBar)),
  );
  unawaited(container.read(routerProvider).push(route));
  await settle(tester);
  await tester.pumpAndSettle();
}

Future<void> goTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await settle(tester);
  await tester.pumpAndSettle();
}

/// Waits (in real time) for async work started by a tap to finish.
Future<void> waitFor(WidgetTester tester, [int rounds = 4]) async {
  for (var i = 0; i < rounds; i++) {
    await settle(tester);
  }
  await tester.pumpAndSettle();
}

Future<Student> seedStudent(
  WidgetTester tester,
  FeeHarness h, {
  String name = 'Rahim',
  int fee = 1500,
  LocalDate joinedOn = const LocalDate(2026, 1, 1),
  int dueDay = 10,
}) => real(
  tester,
  () => h.addStudent(name: name, fee: fee, joinedOn: joinedOn, dueDay: dueDay),
);
