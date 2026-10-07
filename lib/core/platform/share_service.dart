import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Opens the system share sheet. Wrapped so UI and tests do not need the
/// plugin (design section 3, principle 4).
abstract interface class ShareService {
  /// Shares a file. Returns false if the user dismissed the sheet; true when
  /// it was shared or the platform cannot tell.
  Future<bool> shareFile(
    String path, {
    required String mimeType,
    String? text,
    String? subject,
  });

  Future<bool> shareText(String text, {String? subject});
}

class SharePlusShareService implements ShareService {
  const SharePlusShareService();

  @override
  Future<bool> shareFile(
    String path, {
    required String mimeType,
    String? text,
    String? subject,
  }) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: mimeType)],
        text: text,
        subject: subject,
      ),
    );
    return result.status != ShareResultStatus.dismissed;
  }

  @override
  Future<bool> shareText(String text, {String? subject}) async {
    final result = await SharePlus.instance.share(
      ShareParams(text: text, subject: subject),
    );
    return result.status != ShareResultStatus.dismissed;
  }
}

final shareServiceProvider = Provider<ShareService>(
  (ref) => const SharePlusShareService(),
);
