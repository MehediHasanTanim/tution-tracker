# Known issues and limits (1.0)

Honest list for release notes and for the people triaging beta feedback.

## Not verified on real devices

The automated suite runs on a build server. These have not run on a phone yet:
reminders after a restart and under each phone maker's battery manager, the
fingerprint prompt, the screen-capture block, the share sheet and WhatsApp hand-off,
cold-start time and scroll smoothness on a 2 GB phone, APK size, the Android build
itself with the newest plugins. See `release-checklist.md`.

## By design

- **No cloud, no sync.** One phone is the only copy until the tutor backs up. A lost
  phone with no backup means lost records. The app nags (banner, reminder) but
  cannot back up by itself in this version (auto-backup to a folder is planned).
- **Forgot the app-lock PIN** means erasing all data, then restoring from a backup
  (`app-lock.md`).
- **Backups without a password are readable by anyone holding the file.**
- Switching between the Play version and a directly installed APK needs an
  uninstall (different signing keys): back up first (`install-apk.md`).
- Inexact alarms: a reminder can arrive a few minutes late.
- Reminders are planned two weeks ahead; opening the app tops them up. A phone left
  unopened for over two weeks stops reminding until opened (a final notification
  says so).
- Reminder times are Bangladesh time (Asia/Dhaka) whatever the phone's zone.

## Limits

- Sample data names are fixed examples.
- The receipt and attendance summary use the app language at the time.
- One currency (taka), whole taka only.
- Exams, homework, per-class billing, CSV import and widgets are later versions.
- Only Gregorian dates.

## Test-harness limits (not product bugs)

- Widget tests that write `students` rows while screens that watch them are on
  screen can stall under fake time; those tests close the app first.
- Backup UI tests use a file-level restore service; the live database swap is covered
  by `test/features/backup/restore_wiring_test.dart` and the service tests.

## Open items to decide before release

- Native-speaker review of strings; a second review of the Bangla privacy policy.
- Launcher icon, feature graphic.
