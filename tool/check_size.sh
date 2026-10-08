#!/usr/bin/env bash
# Fails if any release APK is over the size target (plan: under 25 MB each).
set -euo pipefail
cd "$(dirname "$0")/.."
limit_mb=${LIMIT_MB:-25}
status=0
shopt -s nullglob
apks=(build/app/outputs/flutter-apk/app-*-prod-release.apk)
if [[ ${#apks[@]} -eq 0 ]]; then
  echo "No release APKs found: run tool/release.sh first." >&2
  exit 1
fi
for apk in "${apks[@]}"; do
  bytes=$(stat -c %s "$apk")
  mb=$(awk "BEGIN { printf \"%.1f\", ${bytes}/1048576 }")
  if (( bytes > limit_mb * 1048576 )); then
    echo "TOO BIG  ${mb} MB  ${apk}"
    status=1
  else
    echo "ok       ${mb} MB  ${apk}"
  fi
done
exit $status
