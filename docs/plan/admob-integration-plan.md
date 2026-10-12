# AdMob integration plan

Status: proposal, nothing implemented. Written 2026-10-12.

## 1. What changes, and what it breaks

Today the app is offline, ad-free and permission-light. Every one of those
promises is written down and tested, and AdMob contradicts several of them.
These have to be decided and fixed together with the code, not after it.

| Existing promise | Where it lives | What AdMob does to it |
|---|---|---|
| "No internet permission" | `docs/release/privacy-policy(.bn).md`, `play-listing.md`, `data-safety.md` | AdMob needs `INTERNET` and `ACCESS_NETWORK_STATE`, and an advertising ID. All three documents become wrong. |
| `tool/check_manifest.sh` fails the build on `INTERNET` / `ACCESS_NETWORK_STATE` | `tool/check_manifest.sh`, CI | It must be changed to allow exactly these two, not weakened to allow anything. |
| "No ads" in Play listing and Data safety "Ads: No" | `play-listing.md`, `data-safety.md` | Must become "Ads: Yes", with the advertising ID and device data declared. |
| "No analytics / no SDK" | `data-safety.md`, README | The Mobile Ads SDK collects device and ad data; it is a third-party SDK. |
| Spec NFR "No ads that require network in v1" and the monetisation note "Banner only on the Reports screen" (spec lines 433 and 482) | `docs/feature/tuition-tracker-spec.md` | Ads on all screens contradicts the spec's own limit. The spec needs a recorded decision. |
| Offline-first / works with no network | Spec, tests | Ads must fail silently and collapse. No screen may wait on, or shift because of, an ad. |
| Data privacy: records never leave the phone | Privacy policy | Ads must never receive student, guardian or payment data. No ad-targeting keywords, no content URL, no user ID. |
| Cold start under 2 s on a 2 GB phone | Spec, `performance.md` | SDK initialisation must be deferred until after first frame. |

## 2. Decisions needed before coding

1. **"All screens" literally, or all screens that make sense?** Recommendation: a
   persistent banner on every screen *except* the exclusions in section 3.
   Showing ads on the PIN pad, the payment form or the restore flow risks
   accidental taps on money screens, trips Google's accidental-click policy,
   and sits badly on screens showing private data.
2. **Keep an ad-free path?** Recommendation: yes. A one-time "Remove ads"
   purchase (Play Billing), or at least a hard "no ads while an
   attendance/payment is being recorded" rule. Decide before launch; adding it
   later is a second release.
3. **Formats.** Recommendation: adaptive banner everywhere (below content, above
   the bottom bar) plus **one** interstitial at most, at natural breaks
   (after saving a payment receipt, never after attendance). No app-open ads
   (they collide with the app lock), no rewarded ads in v1.
4. **Audience.** The user of the app is a tutor (adult), but the data is about
   children. Set the app's target audience to adults on Play Console and do not
   set child-directed treatment; never send student data to the SDK. Confirm
   with whoever owns the Play listing.
5. **AdMob account and units.** Needs the owner's AdMob account, one app id and
   at least two ad-unit ids (banner, interstitial) per platform. Until then use
   Google's public test ids; do not commit real ids to the repo history
   unreviewed (they are not secret, but they identify the account).

## 3. Placement design

The app already has one shell: `AppShell` (`lib/core/navigation/app_shell.dart`)
wraps the four tabs with a `NavigationBar`, and `AppGate` overlays
splash/onboarding/lock/date-jump. Nearly every screen is a route under the
shell, so **one banner in the shell covers all of them** instead of 30 per-screen
banners. This is the key design point.

```
Scaffold (AppShell)
 ├─ body: the routed screen (Expanded)
 ├─ AdBanner  (adaptive, collapses to 0 height when no ad)
 └─ NavigationBar
```

Details:

- The banner sits **above the bottom navigation bar**, so it is never under the
  system gesture area and never covers content (content shrinks, not overlaps).
- It reserves **no height until an ad has loaded** and animates in. Offline, in
  airplane mode, or on no-fill, the layout is exactly today's layout.
- Screens pushed *over* the shell (full-screen routes such as the attendance
  sheet, record-payment, student form) get the banner too only if they are
  rendered inside the shell's body; for routes outside it, add the same
  `AdBanner` as the `bottomNavigationBar` through a tiny `AdScaffoldSlot`
  wrapper. Audit the router for which are which (section 5, task A5).
- **No ads on:** splash, onboarding, lock screen and PIN setup, biometric prompt,
  backup/restore/delete-all flows (including the password and typed-confirmation
  dialogs), receipt preview/share, any screen while a dialog or bottom sheet is
  open, and the date-jump overlay. These are exactly the screens where a stray
  tap or a cached ad frame is a trust problem. Implement as an allow/deny list of
  route names in one place, not as per-screen flags.
- **Payment and attendance entry** (record-payment, attendance sheet): recommended
  *no ads* during entry, because the bottom of those screens holds the save
  button and the counters. Ads appear on the screens around them (due list, home,
  profile). If the owner insists on literally every screen, the banner can sit
  above the save button on these two, but that is the accidental-tap risk the
  deny list exists to avoid. Record the decision in A1.
- **Interstitial:** after a payment is saved and the receipt screen is closed
  (frequency cap: at most once per 5 minutes and at most 3 per day, never
  within the first 3 days after install, never on the first launch of a session).
  Hidden when the app lock is enabled and the lock screen was shown in the last
  30 seconds.
- **Lock interaction:** the app lock hides everything behind `AppGate`. Ads must
  be disposed or hidden when the cover is shown and `FLAG_SECURE` stays on, so a
  banner never shows over, or gets captured behind, the lock. Show again only
  after unlock.
- **Language/theme:** ad frame follows the app's theme background; "বিজ্ঞাপন /
  Ad" label is Google's. No custom labels, no styling that disguises the ad.

## 4. Architecture

Follow the project's existing pattern: platform plugins behind an interface,
fakes in tests (`UrlLauncherService`, `NotificationService` etc.).

```
lib/features/ads/
  domain/
    ad_policy.dart          # pure Dart: which routes may show ads, interstitial caps
    ad_consent.dart         # consent state enum
  data/
    ad_service.dart         # interface: initialize(), loadBanner(width), loadInterstitial(), show...
    google_ad_service.dart  # google_mobile_ads implementation
    fake_ad_service.dart    # test double (in test/support)
    ad_providers.dart       # Riverpod: adServiceProvider, adsEnabledProvider, adConsentProvider
  presentation/
    ad_banner.dart          # widget: adaptive banner, collapses, disposes properly
    ad_scaffold_slot.dart   # wrapper for routes outside the shell
```

- **Dependency:** `google_mobile_ads` (current stable at implementation time; pin
  an exact version, check release date is at least two weeks old, as for other
  dependencies). Min Android SDK for the plugin is 23, the app uses 24: fine.
- **`AdPolicy` (pure Dart, fully unit-tested):** given route, lock state, dialog
  state, install date, last interstitial time, session count → may a banner /
  interstitial show. Keeps all the rules testable without a device.
- **Settings keys** (add to `SettingKeys`): `ads_removed` (bool, for the
  ad-free path), `ads_last_interstitial_at`, `ads_interstitial_count_today`,
  `install_date`. No ad state goes into the backup file (restoring on a new
  phone must not carry "ads removed" without a purchase check, and backups must
  stay free of anything but tutoring data). Add the keys to the backup
  exclusion list and test it.
- **Initialisation:** call `MobileAds.instance.initialize()` from a post-first-frame
  callback (not `main()`), only after consent is resolved (section 6). Measure
  cold start before/after on the stress/perf harness; budget: no regression
  over 100 ms on the host proxy.
- **Lifecycle:** one `BannerAd` per visible banner slot, created for the
  measured adaptive width, disposed on route change or when hidden. Reload
  every 60 s while visible (AdMob default refresh; do not reload more often).
  Handle `onAdFailedToLoad` by collapsing and retrying with backoff (30 s, 1 min,
  2 min, cap 5 min) while the network is available.
- **Test mode:** a `--dart-define=ADS_MODE=test|off|live`. `off` is the
  default for `flutter test` and for the dev flavor. `test` uses Google's sample
  ids. `live` is accepted only in the release build, via the release script,
  which refuses to build `live` with test ids and vice versa.
- **Ad unit ids** through `--dart-define` (`ADMOB_BANNER_ID`,
  `ADMOB_INTERSTITIAL_ID`) and the AdMob app id through `manifestPlaceholders`
  in `android/app/build.gradle.kts` (the app id must be in the manifest as
  `com.google.android.gms.ads.APPLICATION_ID`; a missing id crashes at start).
  Never hard-code the live app id in source; inject it in `tool/release.sh`.

## 5. Task list

Sizes are person-days. Order matters; A is the foundation and can ship dark.

### A. Foundation (ads compiled in, off by default)
| ID | Task | Size | Done when |
|---|---|---|---|
| A1 | Record decisions from section 2 in the spec (new "Monetisation" decision, supersedes line 433/482 for v1.1). | 0.5 | Spec and this plan agree. |
| A2 | Add `google_mobile_ads`; Android manifest: `INTERNET`, `ACCESS_NETWORK_STATE`, AdMob app id meta-data via placeholder; Gradle/R8 keep rules if needed; verify desugaring/minSdk still build. | 1 | Debug and release APK build; app starts with ads `off`. |
| A3 | `AdService` interface, `GoogleAdService`, `FakeAdService`, providers, `ADS_MODE` define. | 1 | Compiles; fake used in every existing widget test by default. |
| A4 | `AdPolicy` pure-Dart rules + unit tests (route allow/deny list, caps, install-date and lock rules). | 1 | 100% of rules covered. |
| A5 | Audit `lib/router.dart`: list every route as in-shell or outside-shell; decide allow/deny per route; write the table into this doc. | 0.5 | Table committed; test iterates all routes and fails if a new route has no entry. |

### B. Consent and privacy
| ID | Task | Size | Done when |
|---|---|---|---|
| B1 | Google UMP consent: request consent info at start, show form when required, "Privacy options" entry in Settings (required where consent is mandatory). Ads load only after `canRequestAds()`. | 1.5 | Consent flow works with a test device and `DebugGeography` EEA / not-EEA. |
| B2 | Set request configuration: max ad content rating `G`, `tagForUnderAgeOfConsent` false, no child-directed flag, no personalised keywords, no content URL. Document why. | 0.5 | Config unit-tested via the service. |
| B3 | Rewrite privacy policy (EN+BN), Data safety, play-listing, in-app privacy note, README, `known-issues.md`: internet permission, advertising ID, device and ad-interaction data shared with Google, no tutoring data ever sent. Update `tool/check_manifest.sh` to allow exactly `INTERNET` and `ACCESS_NETWORK_STATE` and still fail on everything else. | 1.5 | Docs consistent; manifest check passes; policy reviewed by the owner (legal text is theirs to approve). |
| B4 | Android 13+ and Play "Advertising ID" declaration; add `com.google.android.gms.permission.AD_ID` (needed on API 33+ targets) and declare it in Play Console. | 0.25 | Console form matches manifest. |

### C. Banner
| ID | Task | Size | Done when |
|---|---|---|---|
| C1 | `AdBanner` widget: anchored adaptive size, collapse when empty, animate in, dispose on hide, refresh timer, safe-area padding. | 1.5 | Widget tests with the fake service for load, no-fill, offline, dispose. |
| C2 | Put it in `AppShell` above the `NavigationBar`, wired to `AdPolicy` and the current route. Hide while a dialog/sheet is up and while `AppGate` covers the app. | 1 | Banner visible on home, students, fees, reports, settings, profile screens; absent on the deny list. |
| C3 | `AdScaffoldSlot` for routes outside the shell that are allowed. | 0.5 | Covered by the route-table test. |
| C4 | Layout safety: every screen at 1.0×, 1.3×, and the new "extra large" text step with and without a banner, on the 5-inch small screen. Extend `test/a11y/audit_test.dart` with a fake banner of 50 dp. | 1 | No overflow; tap targets still ≥ 48 dp; lists scroll to the last item above the banner. |
| C5 | TalkBack: banner is not focus-trapping; decide if it is excluded from the semantic traversal (Google's ad view exposes its own semantics). | 0.5 | Manual checklist item added and passed. |

### D. Interstitial (optional, last)
| ID | Task | Size | Done when |
|---|---|---|---|
| D1 | Preload and show logic, caps from `AdPolicy`, shown after receipt close only. | 1 | Fake-service tests for each cap; never during entry flows. |
| D2 | "Remove ads" path if chosen in section 2 (Play Billing, `in_app_purchase`, restore purchases, offline grace). | 3 | Purchase flow tested with Play test tracks; ads disappear immediately and stay off after reinstall + restore purchases. |

### E. Release engineering
| ID | Task | Size | Done when |
|---|---|---|---|
| E1 | `tool/release.sh`: require live ids, refuse test ids in a release build, fail if `ADS_MODE != live`. CI builds with `off`/test only. | 0.5 | Script tested against both mistakes. |
| E2 | Update `tool/check_size.sh` budget (SDK adds ~2–4 MB per ABI). Re-measure against the 25 MB target. | 0.5 | Number recorded in `docs/release/performance.md`. |
| E3 | `app-ads.txt` on the developer website (AdMob requirement for revenue), AdMob app registered and linked to the Play listing, payments profile. | owner | AdMob dashboard shows the app "Ready". |
| E4 | Play Console: Data safety, ads declaration ("contains ads"), target audience, content rating questionnaire re-done. | owner | Console forms match B3. |
| E5 | Release checklist additions: test on a real device with test ads, then live ids on an internal track; click-test yourself **only with test ads** (clicking your own live ads suspends the account). | 0.5 | Items added to `release-checklist.md`. |
| E6 | Beta: one cycle on 5+ tutors' phones on slow mobile data and on no data. | owner | Feedback on layout, speed and annoyance logged. |

Total engineering: about 15 person-days with the interstitial and the
"Remove ads" purchase, about 9 for banner-only with consent and docs.

## 6. Policy and compliance checklist (Google AdMob / Play)

- Consent (UMP) before any ad request where required; a working "Privacy options"
  entry in Settings.
- Never place ads so that they can be tapped by accident: not next to or over
  the primary buttons, not on screens that appear right after a tap target
  (the reason for the deny list), not in dialogs.
- Never click your own live ads. Use test ids / registered test devices
  (`RequestConfiguration.testDeviceIds`) on every dev and QA phone.
- Never label or style the banner to look like app content. Keep Google's
  "Ad" label. Don't incentivise taps.
- Disclose ads and data collection accurately in Play Data safety, the privacy
  policy, and the store listing. The current text ("no ads, no internet") must
  not ship with AdMob.
- Do not pass any student, guardian, payment, phone-number or location data
  into ad requests (keywords, content URLs, extras).
- Respect the Families / audience decision in section 2.4.

## 7. Testing

- **Unit:** `AdPolicy` rules; settings keys exclusion from backups; `ADS_MODE`
  parsing; backoff schedule.
- **Widget (fake service):** banner appears only on allowed routes; collapses on
  failure; layout identical to today when `off`; hidden under lock cover and
  dialogs; interstitial caps; route-table completeness test.
- **Existing suites:** all current 885 tests must pass with the fake service
  injected by default (`appTestWidgets` / `pumpApp` override), and with
  `ADS_MODE=off`. No test may hit the network.
- **Perf:** cold start and screen-load budgets unchanged (SDK init deferred).
- **Device (cannot be run in this cloud environment):** test ads on a real
  phone, offline behaviour (airplane mode), rotation, split-screen, low-RAM
  phone, consent forms, lock + background/foreground, interstitial timing,
  manifest check on the built APK, APK size.

## 8. Risks

| Risk | Mitigation |
|---|---|
| Privacy promise broken for existing users on update | Say so in the release notes and the first-run-after-update screen; this is a trust change, not a silent one. |
| Ad shown over private data (screenshots, recents) | `FLAG_SECURE` already set while locked; hide banner when the lock cover shows; no ads on money/backup screens. |
| Accidental clicks near save buttons → policy strike | Deny list; ad above the nav bar only; adaptive size only. |
| Slow low-end phones | Deferred init, one banner instance, dispose on hide, measure on a 2 GB device. |
| Revenue small in the target market (low eCPM in Bangladesh) | Check AdMob's reported eCPM in beta before investing in D2. |
| Account suspension | Test ids in dev, registered test devices, no self-clicks, correct `app-ads.txt`. |
| Layout regressions across 30 screens | Single banner slot in the shell, plus the all-screens a11y audit with a fake banner. |
| Offline promise | Ads fail silently and collapse; no screen waits on the SDK; add an explicit offline test. |

## 9. Suggested order of delivery

1. A1–A5 (decisions, plumbing, policy, route table), shipped with ads off.
2. B1–B4 (consent, config, docs, manifest) before any real ad request.
3. C1–C5 (banner in shell) behind `ADS_MODE`, test ads on device.
4. E1–E6 (release scripts, console, beta).
5. D1/D2 (interstitial, remove-ads) only if beta data supports it.

## 10. What I need from you

- Confirm the placement rule in 2.1 (all screens except the deny list) or tell me
  to go literal.
- Yes/no on the "Remove ads" purchase and the interstitial.
- AdMob app id and ad unit ids (or approval to start with Google's test ids).
- Who approves the rewritten privacy policy and the Play forms.
