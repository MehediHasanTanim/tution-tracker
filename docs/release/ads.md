# Ads (AdMob): setup and release

Plan: `docs/plan/admob-integration-plan.md`. Code: `lib/features/ads/`.

## What is built

- A banner above the bottom tabs on browsing screens (`AdPolicy` in
  `lib/features/ads/domain/ad_policy.dart` lists which). No banner on attendance,
  payment entry or edit, receipts, student and batch forms, PIN setup, backup and
  restore, the template editor, and while the lock, onboarding or date-warning
  covers the app. A route that nobody classified gets no ad; a test fails if the
  router gains an unclassified route.
- One full-screen ad after a **new** payment is saved and the receipt screen is
  declined ("Done"). At most 3 a day, 5 minutes apart, never in the first 3 days
  after install, never within 30 s of the lock screen. State is kept in the
  secure store, not the database, so backups and "Delete all data" do not reset it.
- Google's consent form (UMP) before any ad request, and Settings, "Ad privacy
  options" when Google says it is required.
- Requests carry no keywords, content URL or extras; content rating G; no child
  treatment (the user is an adult tutor).
- Nothing starts until after the first frame. With `ADS_MODE=off` (the default)
  the SDK is never started and the app is as it was without ads.

## Build modes

| Mode | How | Ads |
|---|---|---|
| `off` (default) | nothing to do | none |
| `test` | `--dart-define=ADS_MODE=test` | Google's sample ads (safe to tap); always uses Google's sample ids |
| `live` | `tool/release.sh` with the variables below | real ads |

`flutter run --dart-define=ADS_MODE=test --flavor dev -t lib/main_dev.dart` shows
test ads. The manifest carries Google's **sample app id** unless `-PADMOB_APP_ID`
is given, so a debug build can never serve real ads.

A `live` build with a missing, or Google-sample, id quietly shows nothing; it
does not fall back to test ads.

## One-time AdMob and Play setup (owner)

This needs your Google account, so it cannot be done from the repository.

1. **AdMob account.** Sign in at <https://admob.google.com>, accept the terms,
   choose country (Bangladesh) and time zone, and set up the **payments profile**
   (address, payee, and later the tax and payment details).
2. **Add the app.** Apps, Add app, Android. Choose "No" if the app is not yet on
   Google Play (link it after the first upload) or search for it once it is.
   Name: Tuition Khata. Note the **App ID**: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`.
3. **Ad units.** Add ad unit, **Banner**, name "Browse banner": note
   `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`. Add ad unit, **Interstitial**,
   name "After payment": note its id.
4. **Ad content.** AdMob, Blocking controls: block sensitive categories you do
   not want next to a school-records app (gambling, dating, alcohol, politics,
   and so on). Keep the app's maximum ad content rating at General (the app also
   requests G).
5. **Privacy and messaging.** AdMob, Privacy & messaging: create the **GDPR**
   message (EEA and UK) and, optionally, the US state-regulations message.
   Publish them for the app. This is what the consent form in the app shows.
   Add the **privacy policy URL** under App settings.
6. **app-ads.txt.** On the developer website (the domain on the Play listing),
   publish `https://yourdomain/app-ads.txt` containing the line AdMob shows
   under Apps, View apps, app-ads.txt (`google.com, pub-XXXXXXXXXXXXXXXX, DIRECT,
   f08c47fec0942fa0`). Without it, ad serving is limited.
7. **Test devices.** AdMob, Settings, Test devices: add every phone you use for
   QA. **Never tap live ads yourself**: it can suspend the account.
8. **Play Console.**
   - App content, **Ads**: "Yes, my app contains ads".
   - **Data safety** form: follow `data-safety.md` (advertising ID, device data).
   - **Advertising ID** declaration: Yes, for advertising.
   - **Target audience**: 18 and over, not for children. Re-answer the content
     rating questionnaire.
   - Privacy policy URL: the page built from `privacy-policy.md` and `.bn.md`.
9. After the first Play upload, link the Play listing in AdMob (Apps, App
   settings, App store details).

## Building a release with ads

```
ADS_MODE=live \
ADMOB_APP_ID=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY \
ADMOB_BANNER_ID=ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ \
ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXXXXXXXXXXXXXX/WWWWWWWWWW \
PRIVACY_URL=https://... tool/release.sh
```

### Values for Tuition Khata (set up 12 October 2026)

The ids are not secret: they are compiled into every release.

| Item | Value |
|---|---|
| AdMob app (Android, "Tuition Khata") | `ca-app-pub-3379896207398236~9911381044` |
| Banner "Browse banner" | `ca-app-pub-3379896207398236/2877225523` |
| Interstitial "After payment" | `ca-app-pub-3379896207398236/2671930130` |
| Privacy policy URL | <https://mehedihasantanim.github.io/tuition-khata/privacy/> |
| app-ads.txt line | `google.com, pub-3379896207398236, DIRECT, f08c47fec0942fa0` |

```
ADS_MODE=live \
ADMOB_APP_ID=ca-app-pub-3379896207398236~9911381044 \
ADMOB_BANNER_ID=ca-app-pub-3379896207398236/2877225523 \
ADMOB_INTERSTITIAL_ID=ca-app-pub-3379896207398236/2671930130 \
PRIVACY_URL=https://mehedihasantanim.github.io/tuition-khata/privacy/ \
tool/release.sh
```

Done in AdMob: app and both ad units created; eight sensitive categories
blocked at app level (Dating, Drugs & Supplements, Get Rich Quick, Politics,
References to Sex, Sensationalism, Sexual & Reproductive Health, Social Casino
Games); maximum content rating General (G), set per app; European regulations
(GDPR) message published for this app, with Do not consent on. Still to do:
publish `app-ads.txt` on the developer domain, add test devices, the Play
Console steps, and link the Play listing after the first upload.

The privacy page is hosted from GitHub Pages: repository
`MehediHasanTanim/tuition-khata`, file `privacy/index.html` (English and
Bangla). When `privacy-policy.md` or the ad setup changes, update that file and
its "Last updated" date.

`tool/release.sh` refuses `live` without all three ids, and refuses Google's
sample ids (they contain `3940256099942544`). Without `ADS_MODE`, a release has
no ads (the manifest still lists the three ad permissions).

Then: `tool/check_size.sh` (the SDK adds a few MB per ABI: re-check the 25 MB
target) and `tool/check_manifest.sh <apk>` (allows only `INTERNET`,
`ACCESS_NETWORK_STATE` and `AD_ID` from the network group).

## Test on a device before release

1. Debug build with `ADS_MODE=test`: banner appears on Home, Students, Fees,
   Reports, Settings; student profile and batch detail; not on Backup, Lock, Fees
   pay and receipt, attendance sheet, student form, templates.
2. Airplane mode: no banner, no gap above the tab bar, no error, app speed
   unchanged. Back online: the banner appears within a minute.
3. App lock on: lock the app and return: no banner shows behind or over the lock.
4. Record a payment and tap Done on a phone installed more than 3 days ago (or
   shift the stored install date): one test interstitial; a second payment within
   5 minutes shows none.
5. Fresh install with a VPN set to Germany (or the UMP debug geography): the
   consent form appears once; Settings shows "Ad privacy options".
6. 2 GB phone: cold start, tab switching, scrolling a long Students list with the
   banner showing.
7. Largest text (system 1.3 + in-app Extra large) on a 5-inch screen: nothing cut off.

## Known limits

- Banner height uses Google's standard anchored adaptive size (the SDK marks the
  call deprecated in favour of a taller "large" size; revisit if it is removed).
- "Remove ads" in-app purchase is not built (plan D2); needs Play Billing and a
  decision on price.
- AdMob revenue in Bangladesh may be low; check the AdMob dashboard during the beta.
