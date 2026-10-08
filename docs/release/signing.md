# Signing keys

Play requires every update to be signed by the same key. **If the upload key is
lost the app can only be updated with Google's help, and a direct-APK key lost
means users must uninstall (losing their data) to update.** Treat the keystore
like the app's identity.

## Make the upload key (once)

```sh
mkdir -p keystore
keytool -genkeypair -v -storetype JKS \
  -keystore keystore/tuition-khata-upload.jks \
  -alias upload -keyalg RSA -keysize 4096 -validity 10000
```

Use a long passphrase. `keystore/` and `android/key.properties` are git-ignored.

## Back it up (do this before the first upload)

1. Copy `tuition-khata-upload.jks` to **two** offline places (an encrypted USB
   stick and a password manager's file storage).
2. Write the two passwords and the alias in the password manager.
3. Check you can open the copy: `keytool -list -keystore <copy>`.

## Point the build at it

```sh
cp android/key.properties.example android/key.properties
# edit storeFile, storePassword, keyAlias, keyPassword
```

`tool/release.sh` refuses to build without `android/key.properties`.

## Play App Signing

Enrol in Play App Signing when creating the app. Google then keeps the real app
signing key, and the key above is only the *upload* key, which Play support can
reset if it is ever lost.

One consequence: the APK you build for direct installs is signed with the upload
key, while the Play build is re-signed by Google with a different key. Android
will not update one over the other. A tutor who switches between the Play version
and a directly installed APK must uninstall first, which deletes the app's data
unless they took a backup. `install-apk.md` tells them to back up first.

## Symbols

`tool/release.sh` obfuscates the code and writes the symbol files to
`build_symbols/<version>/`. Keep them for every released version, upload them to
Play Console (Android vitals, deobfuscation files) and never ship them in the app.
Without them crash stack traces are unreadable.
