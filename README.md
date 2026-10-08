# Tuition Khata (tution-tracker)

Offline, Bangla-first tuition tracker for home tutors in Bangladesh: students,
batches, attendance, fees and payments, receipts, guardian reminders, reports,
class and fee reminders, backup and restore, optional app lock. No account, no
network permission, all data on the phone.

See `docs/` for the spec (`docs/feature`), technical design (`docs/design`) and
implementation plan (`docs/plan`). Release material is in `docs/release/`.

Application ID: `com.nextgenai.tution_tracker` (dev flavor: `.dev` suffix).

## Run

```
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart
```

The first launch shows the language choice, intro and the offer of sample data.

## Checks (what CI runs)

```
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test                      # unit, DB, widget, flows, accessibility, performance
flutter build apk --debug --flavor dev -t lib/main_dev.dart
flutter test integration_test --flavor dev     # on an emulator or phone
```

Test areas: `test/features/*` per feature, `test/flows/` the spec's flows A to E,
`test/a11y/` accessibility and Bangla-digit audit, `test/perf/` the 500-student
stress dataset and timings, `test/edge_cases/` spec section 7, `integration_test/`
the real app on a device.

## Release

```
cp android/key.properties.example android/key.properties   # then fill in
SUPPORT_WHATSAPP=8801XXXXXXXXX PRIVACY_URL=https://... tool/release.sh
tool/check_manifest.sh build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk
```

Produces an app bundle for Google Play and one APK per CPU type, obfuscated, with
symbols in `build_symbols/`, and checks every APK is under 25 MB. Read
`docs/release/signing.md` first: keep the keystore backed up. The checklist of
what is and is not yet verified is `docs/release/release-checklist.md`.

## Layout

```
lib/core        shared: database, settings, i18n, platform wrappers, security
lib/features    students, batches, attendance, fees, receipts, reports, reminders,
                messaging, backup, lock, onboarding, settings
test, integration_test, tool, docs
```

Platform plugins sit behind small interfaces (`lib/core/platform/`), so everything
above them is testable without a phone.
