# Google Play: Data safety form

Answers to give in Play Console, App content, Data safety. They follow what the
app actually does (verify against the built APK with `tool/check_manifest.sh`
before submitting).

## Data collection and sharing

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **Yes**, only the ad SDK's (below). The developer collects nothing |
| Is all of the user data collected by your app encrypted in transit? | Yes (the Google Mobile Ads SDK uses HTTPS) |
| Do you provide a way for users to request that their data be deleted? | Tutoring records: in-app, Settings, Backup & restore, Delete all data (they never leave the phone). Ad data: held by Google; users manage it in Android's Google ad settings |

Declare these, for the **Google Mobile Ads SDK** (AdMob), as collected **and**
shared, purpose **Advertising or marketing** (and **Fraud prevention, security,
and compliance**), not optional, not required for the app's own features:

| Data type | Category |
|---|---|
| Device or other IDs (advertising ID) | Device or other IDs |
| Approximate location (from IP address) | Location |
| App interactions, diagnostics | App activity, App info and performance |

Check the current list in Google's "Google Mobile Ads SDK" data disclosure
guidance when you submit; Google updates it. **Student, guardian, attendance,
payment and photo data are never collected or shared**: the app has no server
and passes none of it to the SDK. Data the tutor chooses to send through SMS,
WhatsApp or the share sheet is sent by those apps at the user's own action, and
is not collected by the developer.

## Security practices

- Data is encrypted in transit: not applicable (nothing in transit).
- Users can request data deletion: users delete their own data in the app, or by
  uninstalling.
- Optional app lock (PIN with salted slow hash, biometric), optional
  password-protected backup (AES-256-GCM).

## Other App content answers

| Item | Answer |
|---|---|
| Ads | **Yes**: contains ads (AdMob banner and occasional full-screen ad) |
| App access | All features available without login. Optionally lock with a PIN; reviewers need no credentials |
| Target audience | Adults (tutors and teachers). Not designed for children, so not in the Families program. Ad content limited to rating G in the SDK |
| Content rating (IARC) | Everyone: no violence, user-generated sharing, location or purchases |
| Government app | No |
| Financial features | Records fees the tutor receives; it does not move or process money, so it is not a payments or banking app |
| Health | No |
| Permissions declared | `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`, `USE_BIOMETRIC`, `INTERNET`, `ACCESS_NETWORK_STATE`, `com.google.android.gms.permission.AD_ID`. None needs a sensitive-permission declaration form. Advertising ID: declare "Yes, the app uses the advertising ID" for Advertising |
| Exact alarms | Not used (inexact alarms), so no exact-alarm declaration |
| Foreground services | None |
