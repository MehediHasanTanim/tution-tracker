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
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
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

  /// Share as PDF rather than an image (the design's format chips).
  bool _pdf = false;

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
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    BlockChips<bool>(
                      options: [
                        (false, l10n.receiptFormatImage),
                        (true, 'PDF'),
                      ],
                      isSelected: (v) => v == _pdf,
                      onTap: (v) => setState(() => _pdf = v),
                    ),
                    const SizedBox(height: 12),
                    BlockText(l10n.receiptExactly),
                    const SizedBox(height: 12),
                    // Scales down on narrow screens; the captured image is
                    // always the card's own size.
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              OrganicRadius.panel,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x292E2B25),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              OrganicRadius.panel,
                            ),
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
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Organic.of(context).raised,
                  border: Border(
                    top: BorderSide(color: Organic.of(context).divider),
                  ),
                ),
                child: SafeArea(
                  minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: BlockButton(
                    _pdf ? l10n.receiptSharePdf : l10n.receiptShareImage,
                    kind: BlockButtonKind.sage,
                    icon: Icons.share_rounded,
                    onPressed: _busy ? null : () => _share(data, pdf: _pdf),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
