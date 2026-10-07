import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/navigation/app_shell.dart';
import 'package:tution_tracker/features/fees/presentation/fees_screen.dart';
import 'package:tution_tracker/features/home/presentation/home_screen.dart';
import 'package:tution_tracker/features/reports/presentation/reports_screen.dart';
import 'package:tution_tracker/features/settings/presentation/settings_screen.dart';
import 'package:tution_tracker/features/students/presentation/students_screen.dart';

abstract final class AppRoutes {
  static const home = '/home';
  static const students = '/students';
  static const fees = '/fees';
  static const reports = '/reports';
  static const settings = '/settings';
}

GoRouter buildRouter({String initialLocation = AppRoutes.home}) {
  GoRoute tab(String path, Widget screen) =>
      GoRoute(path: path, builder: (context, state) => screen);

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      // Each branch keeps its own navigation stack and widget state alive.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [tab(AppRoutes.home, const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [tab(AppRoutes.students, const StudentsScreen())],
          ),
          StatefulShellBranch(
            routes: [tab(AppRoutes.fees, const FeesScreen())],
          ),
          StatefulShellBranch(
            routes: [tab(AppRoutes.reports, const ReportsScreen())],
          ),
          StatefulShellBranch(
            routes: [tab(AppRoutes.settings, const SettingsScreen())],
          ),
        ],
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = buildRouter();
  ref.onDispose(router.dispose);
  return router;
});
