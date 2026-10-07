#!/usr/bin/env bash
# Prints the permissions a built APK asks for and fails if it asks for any that
# the privacy policy says it does not (network, contacts, location, storage).
# Needs the Android SDK's aapt2 on PATH.
set -euo pipefail
apk=${1:?usage: tool/check_manifest.sh path/to/app.apk}
perms=$(aapt2 dump permissions "$apk" | sed -n 's/^uses-permission: name=//p' | tr -d "'")
echo "$perms"
forbidden='INTERNET|ACCESS_NETWORK_STATE|READ_CONTACTS|WRITE_CONTACTS|ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|READ_EXTERNAL_STORAGE|WRITE_EXTERNAL_STORAGE|READ_MEDIA|CAMERA|RECORD_AUDIO|READ_PHONE_STATE|SEND_SMS|READ_SMS'
if echo "$perms" | grep -E "$forbidden"; then
  echo "Unexpected permissions above: the privacy policy would be wrong." >&2
  exit 1
fi
echo "Permissions match the privacy policy."
