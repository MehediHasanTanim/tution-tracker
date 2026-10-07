# App lock: how it works and how to get back in

## For the tutor

Settings, App lock. Turn on, choose a PIN of 4 to 8 digits (typed twice).
Options: fingerprint or face (if the phone has them set up), how long the app may
stay in the background before it locks again (immediately, 1, 5 or 15 minutes),
and "block screenshots and the recent-apps preview".

The lock covers the whole app, including after a reminder notification opens it.
What was on the screen is still there after unlocking.

### Wrong PINs

Five wrong tries in a row make the app wait 30 seconds; each further wrong try
doubles the wait, up to 15 minutes. The count survives closing the app. The right
PIN works again once the wait is over.

### Forgot the PIN

There is deliberately no back door: a PIN that anyone could bypass would protect
nothing. The way out is on the lock screen, **Forgot your PIN?**: it explains that
the only option is to erase all data and start fresh, asks to confirm twice (the
second time by typing a word), and only then erases the app's data and removes the
lock. A safety copy of the old data stays in the app's private storage until the
next restore, but it is not reachable from the app.

The data comes back from a backup made earlier (Settings, Backup & restore,
Restore). A backup file does not contain the PIN: restoring never changes or
sets the lock. So **keep backups**, and keep the backup password (if you set one)
somewhere you will find it.

## For developers

- PIN hash: PBKDF2-HMAC-SHA256, 60,000 iterations, 16-byte random salt, constant-time
  comparison. Stored as `v1:<length>:<iterations>:<salt>:<hash>` in
  `flutter_secure_storage` (Android Keystore), together with the lock preferences
  and the wrong-try counter. Nothing about the lock is in the database, so a
  restore or "delete all data" cannot change what unlocks the app.
- Code: `lib/features/lock/` (service, controller, screens), `lib/core/security/`,
  `lib/core/platform/{secure_store,biometric_auth,screen_security}.dart`,
  the overlay in `lib/core/navigation/app_gate.dart`.
- Screen protection is `FLAG_SECURE` set from `MainActivity.kt` over a method
  channel. `MainActivity` is a `FlutterFragmentActivity` (needed by the biometric
  prompt) and the launch theme extends AppCompat for Android 8 and below.
- Android reports `hidden` both on the way out and on the way back; only the first
  counts as "left" (a bug the unit tests pin down).
- Tests: `test/features/lock/`, `test/a11y/audit_test.dart` (lock screen on a small
  screen at 1.3x font).
