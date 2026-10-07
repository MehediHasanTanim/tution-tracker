import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/fees/data/consistency_checker.dart';
import 'package:tution_tracker/features/fees/data/due_service.dart';
import 'package:tution_tracker/features/fees/data/fee_repository.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';

final paymentRepositoryProvider = FutureProvider<PaymentRepository>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  final settings = await ref.watch(settingsStoreProvider.future);
  return PaymentRepository(db, settings, now: ref.read(clockProvider));
});

final dueServiceProvider = FutureProvider<DueService>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final settings = await ref.watch(settingsStoreProvider.future);
  final payments = await ref.watch(paymentRepositoryProvider.future);
  return DueService(db, settings, payments, now: ref.read(clockProvider));
});

final feeRepositoryProvider = FutureProvider<FeeRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final payments = await ref.watch(paymentRepositoryProvider.future);
  final dues = await ref.watch(dueServiceProvider.future);
  return FeeRepository(db, payments, dues, now: ref.read(clockProvider));
});

final consistencyCheckerProvider = FutureProvider<ConsistencyChecker>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  final settings = await ref.watch(settingsStoreProvider.future);
  return ConsistencyChecker(db, settings);
});
