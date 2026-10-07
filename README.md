# Tuition Khata (tution-tracker)

Offline, Bangla-first tuition tracker for home tutors in Bangladesh. See `docs/` for the spec, technical design and implementation plan.

Application ID: `com.nextgenai.tution_tracker` (dev flavor: `.dev` suffix).

## Run

```
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart
```

## Checks

```
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug --flavor dev -t lib/main_dev.dart
```
