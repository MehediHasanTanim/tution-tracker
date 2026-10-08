/// Keep in step with `version:` in pubspec.yaml. Written into backups so a
/// restore can say which app version made the file.
const appVersion = '1.0.0';

/// Set at build time (`--dart-define=SUPPORT_WHATSAPP=8801XXXXXXXXX`, see
/// tool/release.sh). When empty the matching Settings entry is hidden, so a
/// build without them never shows a dead link.
const supportWhatsApp = String.fromEnvironment('SUPPORT_WHATSAPP');
const supportEmail = String.fromEnvironment('SUPPORT_EMAIL');
const privacyPolicyUrl = String.fromEnvironment('PRIVACY_URL');
