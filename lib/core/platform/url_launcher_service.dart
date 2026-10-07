import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

/// Opens a link in another app. Wrapped so the domain and UI stay testable
/// without the plugin (design section 3, principle 4).
abstract interface class UrlLauncherService {
  /// Returns false when no app could handle [uri].
  Future<bool> open(Uri uri);
}

class PluginUrlLauncherService implements UrlLauncherService {
  const PluginUrlLauncherService();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launcher.launchUrl(
        uri,
        mode: launcher.LaunchMode.externalApplication,
      );
    } on Object {
      return false;
    }
  }
}

final urlLauncherProvider = Provider<UrlLauncherService>(
  (ref) => const PluginUrlLauncherService(),
);
