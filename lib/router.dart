import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/navigation/app_shell.dart';
import 'package:tution_tracker/features/batches/presentation/batch_detail_screen.dart';
import 'package:tution_tracker/features/batches/presentation/batch_form_screen.dart';
import 'package:tution_tracker/features/fees/presentation/fees_screen.dart';
import 'package:tution_tracker/features/fees/presentation/record_payment_screen.dart';
import 'package:tution_tracker/features/home/presentation/home_screen.dart';
import 'package:tution_tracker/features/receipts/presentation/receipt_screen.dart';
import 'package:tution_tracker/features/reports/presentation/reports_screen.dart';
import 'package:tution_tracker/features/settings/presentation/settings_screen.dart';
import 'package:tution_tracker/features/students/presentation/student_form_screen.dart';
import 'package:tution_tracker/features/students/presentation/student_profile_screen.dart';
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
            routes: [
              GoRoute(
                path: AppRoutes.students,
                builder: (context, state) => const StudentsScreen(),
                routes: [
                  // `new` must come before `:id` so it is not read as an id.
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const StudentFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => StudentProfileScreen(
                      studentId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => StudentFormScreen(
                          studentId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Batches live under the Students tab (spec section 4.1).
              GoRoute(
                path: '/batches/new',
                builder: (context, state) => const BatchFormScreen(),
              ),
              GoRoute(
                path: '/batches/:id',
                builder: (context, state) =>
                    BatchDetailScreen(batchId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) =>
                        BatchFormScreen(batchId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.fees,
                builder: (context, state) => const FeesScreen(),
                routes: [
                  GoRoute(
                    path: 'pay/:studentId',
                    builder: (context, state) => RecordPaymentScreen(
                      studentId: state.pathParameters['studentId'],
                    ),
                  ),
                  GoRoute(
                    path: 'receipt/:paymentId',
                    builder: (context, state) => ReceiptScreen(
                      paymentId: state.pathParameters['paymentId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'payments/:paymentId/edit',
                    builder: (context, state) => RecordPaymentScreen(
                      paymentId: state.pathParameters['paymentId'],
                    ),
                  ),
                ],
              ),
            ],
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
