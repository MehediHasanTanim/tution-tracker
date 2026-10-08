# Google Play: Data safety form

Answers to give in Play Console, App content, Data safety. They follow what the
app actually does (verify against the built APK with `tool/check_manifest.sh`
before submitting).

## Data collection and sharing

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | Not applicable: no data is collected or transmitted |
| Do you provide a way for users to request that their data be deleted? | Not applicable (no data is collected). In-app: Settings, Backup & restore, Delete all data |

Why "No": the app declares no internet permission, contains no analytics,
advertising, crash-reporting or social SDKs, and keeps every record in the app's
private storage on the phone. Data the tutor chooses to send through SMS,
WhatsApp or the share sheet is sent by those apps at the user's own action, and is
not collected by the developer.

## Security practices

- Data is encrypted in transit: not applicable (nothing in transit).
- Users can request data deletion: users delete their own data in the app, or by
  uninstalling.
- Optional app lock (PIN with salted slow hash, biometric), optional
  password-protected backup (AES-256-GCM).

## Other App content answers

| Item | Answer |
|---|---|
| Ads | No |
| App access | All features available without login. Optionally lock with a PIN; reviewers need no credentials |
| Target audience | Adults (tutors and teachers). Not designed for children |
| Content rating (IARC) | Everyone: no violence, user-generated sharing, location or purchases |
| Government app | No |
| Financial features | Records fees the tutor receives; it does not move or process money, so it is not a payments or banking app |
| Health | No |
| Permissions declared | `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`, `USE_BIOMETRIC`. No sensitive permission needing a declaration form |
| Exact alarms | Not used (inexact alarms), so no exact-alarm declaration |
| Foreground services | None |
