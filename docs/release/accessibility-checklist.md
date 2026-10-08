# Accessibility and Bangla audit (S5-04)

Sign-off needs a person with the low-end phone for the items marked **device**.
Everything else is checked by tests that run in CI.

## Automated (`test/a11y/audit_test.dart`)

With the sample data plus a student whose name and guardian are a 70-character
Bangla string with conjuncts, at **1.3x font scale**, in Bangla with Bangla digits,
for each of these screens: Home, Students, student profile (Overview, Attendance,
Fees), new student, attendance sheet, Fees, Record payment, bulk reminders, Reports,
Settings, Reminders, Message templates, Backup, App lock settings:

- [x] no layout overflow or exception
- [x] every tap target at least 48 x 48 dp (`androidTapTargetGuideline`)
- [x] every tap target has a label (`labeledTapTargetGuideline`)
- [x] text contrast meets the guideline (`textContrastGuideline`)
- [x] **no ASCII digit** appears anywhere on screen in Bangla-digit mode, except
      phone numbers and the one label that shows what English digits look like
- [x] first-run screens and the lock screen on a 5-inch (360 x 640 dp) screen at 1.3x:
      no overflow, tap targets fine (this found a real overflow in the onboarding
      screen, now scrollable)
- [x] a check that the guideline harness really fails a 20 dp target

## Bangla digit consistency: where it is decided

`NumeralStyle` (Settings, Digits) drives `formatCount`, `formatTaka`, `formatDate`,
`formatMonth` and `applyNumerals`. The audit found one miss, the version line in
Settings, now fixed. New screens must format every number through those functions;
the audit will fail otherwise.

## Long names

List rows wrap to two lines then ellipsise; the full name is on the student's
profile header and on forms. Receipts wrap. Covered by the audit above and by the
receipt tests.

## Manual, on the low-end phone (device)

- [ ] System font size set to the largest: Home, Attendance sheet, Record payment
- [ ] In-app text size (Settings → Text size) set to "Extra large", alone and together with a larger system size: same screens, nothing cut off
- [ ] Settings → Calendar → "Also show Bangla dates": Home header, Fees, Student profile and Record payment show e.g. "15 Mar 2026 (১ চৈত্র ১৪৩২)"
      still usable without horizontal scrolling
- [ ] TalkBack on: attendance sheet reads each student with the chosen status; the
      calendar days read the date and status ("১৫, উপস্থিত")
- [ ] Dark theme: no unreadable text, chart bars visible
- [ ] Bangla conjuncts render correctly everywhere (ক্ষ, জ্ঞ, শ্র, দ্ধ, ঙ্গ) in lists,
      PDF receipts (the receipt is drawn as an image so shaping is the app's own
      font), notifications (system font) and shared messages
- [ ] One-handed use on a 5-inch screen: bottom navigation reachable, primary
      buttons at the bottom
- [ ] Sunlight readability of status chips (colours are never the only signal: the
      calendar adds a glyph, chips a label)

Record the phone model, Android version and the date next to each box when signing.
