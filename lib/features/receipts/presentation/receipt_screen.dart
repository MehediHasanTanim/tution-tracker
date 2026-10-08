import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/platform/share_service.dart';
import 'package:tution_tracker/core/platform/temp_directory.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/fees/data/fee_providers.dart';
import 'package:tution_tracker/features/receipts/data/receipt_export.dart';
import 'package:tution_tracker/features/receipts/data/receipt_providers.dart';
import 'package:tution_tracker/features/receipts/domain/receipt_data.dart';
import 'package:tution_tracker/features/receipts/presentation/receipt_card.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Preview of a payment's receipt, with buttons to share it as an image or a
/// PDF (spec FE-9).
class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({required this.paymentId, super.key});

  final String paymentId;

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  final _boundaryKey = GlobalKey();
  bool _busy = false;

  Future<void> _share(ReceiptData data, {required bool pdf}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final png = await capturePng(_boundaryKey);
      final size = _boundaryKey.currentContext!.size!;
      final Uint8List bytes;
      if (pdf) {
        bytes = await receiptPdf(
          png,
          width: size.width,
          height: size.height,
          title: l10n.payReceiptNo('${data.receiptNo}'),
        );
      } else {
        bytes = png;
      }

      final dir = await ref.read(tempDirectoryProvider.future);
      final file = File(
        p.join(dir.path, 'receipt_${data.receiptNo}.${pdf ? 'pdf' : 'png'}'),
      );
      await file.writeAsBytes(bytes, flush: true);

      final shared = await ref
          .read(shareServiceProvider)
          .shareFile(
            file.path,
            mimeType: pdf ? 'application/pdf' : 'image/png',
            subject: l10n.receiptTitle,
          );
      // Remember it, so editing or deleting this payment can warn that the
      // guardian holds an earlier version.
      if (shared) {
        final payments = await ref.read(paymentRepositoryProvider.future);
        await payments.markReceiptShared(widget.paymentId);
      }
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.receiptShareFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final receipt = ref.watch(receiptProvider(widget.paymentId));
    final tutor = ref.watch(tutorProfileProvider).value ?? const TutorProfile();
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiptTitle)),
      body: receipt.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) {
          if (data == null) return Center(child: Text(l10n.studentsNoMatch));
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    // Scales down on narrow screens; the captured image is
                    // always the card's own size.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Card(
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        child: RepaintBoundary(
                          key: _boundaryKey,
                          child: ReceiptCard(
                            data: data,
                            tutor: tutor,
                            language: language,
                            numerals: numerals,
                            grouping: grouping,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _share(data, pdf: false),
                        icon: const Icon(Icons.image),
                        label: Text(l10n.receiptShareImage),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _busy ? null : () => _share(data, pdf: true),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(l10n.receiptSharePdf),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
