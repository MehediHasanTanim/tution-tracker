# Release checklist (plan section 8)

Status as of the end of Sprint 5 work in the repository. **[x]** = verified by a
test or check that runs in CI or here; **[ ] device** = needs a person with a
phone; **[ ] publisher** = needs the publisher's account, keys or decisions.
Nothing is ticked on trust.

## Quality

- [x] All unit, DB, migration, widget and flow tests green (`flutter test`; the
      count is in the CI log). `dart format` and `flutter analyze` clean.
- [x] Fee engine matrix and randomized payment test passing
      (`test/features/fees/fee_matrix_test.dart`, `payment_repository_test.dart`)
- [x] Consistency checker clean on the stress dataset (500 students, 6,000
      payments, 20,000 attendance rows): `test/perf/stress_test.dart`
- [ ] Consistency checker clean after *random operations* on the stress dataset.
      The randomized fee test covers a single student; a randomized run across the
      whole stress dataset was not written. Do it in the beta (Settings, developer
      menu, Consistency check, on a real tutor's data after a month).
- [x] Backup; restore on a clean install; restore-failure rollback at every stage:
      `test/features/backup/`, `test/flows/flows_test.dart` flow E
- [x] Flows A to E from the spec automated: `test/flows/flows_test.dart` (host)
      and `integration_test/app_flows_test.dart` (emulator, run by the `integration`
      job in `.github/workflows/ci.yml`)
- [ ] **device** Emulator job in CI green at least once (it has been written but
      could not be run where this was built)
- [ ] **device** Device checklist on a 2 GB phone and at least two OEM brands:
      accessibility (`accessibility-checklist.md`), performance (`performance.md`),
      reminders with screen off / force-stop / restart (`edge-cases.md` case 11),
      date change (case 7)

## Product

- [ ] **publisher** Bangla and English strings reviewed by a native speaker
      (`lib/l10n/app_bn.arb`, `app_en.arb`; the English was written alongside the
      Bangla and has not been read by a second person)
- [ ] **publisher** Default message templates reviewed by a few tutors (beta)
- [x] Privacy note visible in-app (onboarding, Settings, Backup)
- [ ] **publisher** Privacy policy hosted at a URL (`privacy-policy.md`, `.bn.md`
      are drafted with bracketed items to fill in)
- [x] Backup reminder default is 7 days (`SettingKeys.backupReminderDays`), as the
      plan asks; the tutor can change it (7, 14, 30 or 60)

## Release

- [x] Release build configured: R8 shrinking, obfuscation with symbols, per-ABI
      APKs and an app bundle (`tool/release.sh`), signing from
      `android/key.properties`
- [ ] **publisher** Build it and run `tool/check_size.sh`: every APK under 25 MB
      (not measured: no Android SDK where this was written; expect about 15 to 20 MB
      per ABI for a Flutter app with these plugins, but measure)
- [ ] **publisher** `tool/check_manifest.sh` on the built APK: no INTERNET, no
      storage, contacts, location or camera permissions
- [ ] **publisher** Keystore generated and backed up in two offline places
      (`signing.md`)
- [ ] **publisher** Play listing in Bangla and English (`play-listing.md`),
      screenshots captured, feature graphic and icon designed (the default launcher
      icon is still in use)
- [x] Data safety answers drafted (`data-safety.md`: no data collected)
- [ ] **publisher** Data safety form completed in Play Console
- [ ] **publisher** Play Console vitals confirmed receiving; symbol files uploaded
- [x] Direct APK install instructions (`install-apk.md`)
- [ ] **publisher** Support contact: set `SUPPORT_WHATSAPP` / `SUPPORT_EMAIL` /
      `PRIVACY_URL` at build time so Settings shows them; list the same on the store
      page
- [ ] **publisher** Internal-track build installs and passes the smoke test below

## Smoke test for the internal track (10 minutes, release build)

1. Fresh install: language screen, skip intros, load sample data. Home shows classes.
2. Take attendance for a class, save. Reopen: marks are there.
3. Record a payment from the Fees tab; share the receipt to WhatsApp.
4. Remind a guardian: WhatsApp opens with the Bangla message.
5. Turn reminders on (allow notifications); send the test notification.
6. Settings, Backup now; share to yourself. Delete all data. Restore from the file.
   Everything is back.
7. Turn on the app lock; background the app for the timeout; it asks for the PIN.
8. Remove the sample data from the Home banner.
9. Airplane mode: repeat 2 and 3. They work.
10. Force-stop, restart the phone, wait for a scheduled reminder.
