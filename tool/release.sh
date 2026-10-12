#!/usr/bin/env bash
# Builds the production release: an app bundle for Google Play and one APK per
# CPU type for direct installs. Code is obfuscated; the symbols needed to read
# crash reports are written to build_symbols/ (keep them, never ship them).
#
#   tool/release.sh            build, then check sizes
#   SUPPORT_WHATSAPP=8801XXXXXXXXX PRIVACY_URL=https://... tool/release.sh
#
# Ads (docs/release/ads.md). Without ADS_MODE the release has no ads:
#   ADS_MODE=live ADMOB_APP_ID=ca-app-pub-...~... \
#     ADMOB_BANNER_ID=ca-app-pub-.../... ADMOB_INTERSTITIAL_ID=ca-app-pub-.../... \
#     tool/release.sh
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

ads_mode=${ADS_MODE:-off}
case "$ads_mode" in
  off) ;;
  live)
    for v in ADMOB_APP_ID ADMOB_BANNER_ID ADMOB_INTERSTITIAL_ID; do
      if [[ -z "${!v:-}" ]]; then
        echo "ADS_MODE=live needs $v." >&2
        exit 1
      fi
      # 3940256099942544 is Google's sample publisher id: test ads only.
      if [[ "${!v}" == *3940256099942544* ]]; then
        echo "$v is one of Google's sample ids; a release must use your own." >&2
        exit 1
      fi
    done
    defines+=("--dart-define=ADS_MODE=live"
      "--dart-define=ADMOB_BANNER_ID=${ADMOB_BANNER_ID}"
      "--dart-define=ADMOB_INTERSTITIAL_ID=${ADMOB_INTERSTITIAL_ID}")
    export ORG_GRADLE_PROJECT_ADMOB_APP_ID="${ADMOB_APP_ID}"
    ;;
  *)
    echo "ADS_MODE must be off or live for a release (use test only in debug builds)." >&2
    exit 1
    ;;
esac

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
