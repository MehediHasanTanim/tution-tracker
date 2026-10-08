#!/usr/bin/env bash
# Builds the production release: an app bundle for Google Play and one APK per
# CPU type for direct installs. Code is obfuscated; the symbols needed to read
# crash reports are written to build_symbols/ (keep them, never ship them).
#
#   tool/release.sh            build, then check sizes
#   SUPPORT_WHATSAPP=8801XXXXXXXXX PRIVACY_URL=https://... tool/release.sh
#
# Needs android/key.properties (docs/release/signing.md).
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f android/key.properties ]]; then
  echo "android/key.properties is missing: the build would not be uploadable." >&2
  echo "See docs/release/signing.md." >&2
  exit 1
fi

version=$(grep '^version:' pubspec.yaml | awk '{print $2}')
symbols="build_symbols/${version}"
mkdir -p "$symbols"

defines=()
[[ -n "${SUPPORT_WHATSAPP:-}" ]] && defines+=("--dart-define=SUPPORT_WHATSAPP=${SUPPORT_WHATSAPP}")
[[ -n "${SUPPORT_EMAIL:-}" ]] && defines+=("--dart-define=SUPPORT_EMAIL=${SUPPORT_EMAIL}")
[[ -n "${PRIVACY_URL:-}" ]] && defines+=("--dart-define=PRIVACY_URL=${PRIVACY_URL}")

common=(--release --flavor prod -t lib/main_prod.dart
  --obfuscate "--split-debug-info=${symbols}" "${defines[@]}")

flutter pub get
flutter build appbundle "${common[@]}"
flutter build apk --split-per-abi "${common[@]}"

echo
tool/check_size.sh
echo
echo "App bundle: build/app/outputs/bundle/prodRelease/app-prod-release.aab"
echo "APKs:       build/app/outputs/flutter-apk/app-*-prod-release.apk"
echo "Symbols:    ${symbols} (upload to Play Console as deobfuscation files)"
