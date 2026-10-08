import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/features/receipts/data/receipt_repository.dart';
import 'package:tution_tracker/features/receipts/domain/receipt_data.dart';

final receiptRepositoryProvider = FutureProvider<ReceiptRepository>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  return ReceiptRepository(db);
});

/// The receipt for a payment, or null if it is gone.
final receiptProvider = FutureProvider.autoDispose.family<ReceiptData?, String>(
  (ref, paymentId) async {
    final repo = await ref.watch(receiptRepositoryProvider.future);
    return repo.forPayment(paymentId);
  },
);
