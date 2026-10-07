# Tuition Tracker: Sprint-wise Implementation Plan

**Companions:** `tuition-tracker-spec.md`, `tuition-tracker-technical-design.md`
**Team assumption:** 1 developer, about 30 productive hours per week
**Cadence:** 2-week sprints, about 60 hours of planned work each
**Total duration:** 5 sprints (10 weeks) including closed beta and a buffer. The ideal-case estimate in the spec was 7 to 8 weeks; this plan keeps roughly 25 percent slack for real-world friction.
**Document status:** Draft v0.1

---

## 1. How to Read This Plan

- **ID format:** `S<sprint>-<nn>`, for example `S2-04`.
- **Est.:** estimated hours, including writing tests for that task.
- **Deps:** task IDs that must be done first.
- **Priority:** P0 = MVP-critical, P1 = should have, P2 = stretch. Priorities match the spec.
- **Acceptance:** the check that proves the task is done.
- Within each sprint, tasks are ordered in the sequence they should be built.

### Definition of Done (applies to every task)
1. Code merged to `main` through a pull request (even if solo, review your own diff).
2. `flutter analyze` and `dart format` clean; CI green.
3. Unit or DB tests written for domain logic (UI-only tasks need at least a manual test note).
4. Works in both Bangla and English; no hard-coded strings.
5. Verified on an emulator, plus the low-end test device at each sprint end.
6. No student data written to logs.

### Sprint Overview

| Sprint | Weeks | Theme | Exit demo |
|---|---|---|---|
| 1 | 1 to 2 | Foundations, students, batches | Add students and batches in Bangla, search, call/WhatsApp guardian |
| 2 | 3 to 4 | Fee engine and payments | Dues auto-generate; record partial, multi-month and advance payments; due list is correct |
| 3 | 5 to 6 | Attendance, dashboard, reports, receipts | Take attendance in under 20 seconds; month summary; share a receipt |
| 4 | 7 to 8 | Reminders, messaging, backup/restore, settings | Reminders fire; export then restore on a clean install reproduces all data |
| 5 | 9 to 10 | Hardening, app lock, onboarding, beta, release | Release candidate on Play internal track; beta feedback triaged |

### Release Milestones

| Milestone | End of | Description |
|---|---|---|
| M1: Records | Sprint 1 | Students and batches usable |
| M2: Money | Sprint 2 | Fee tracking correct and tested (the riskiest logic is done early) |
| M3: Daily use | Sprint 3 | Attendance plus dashboard; usable for a real month |
| M4: Safe | Sprint 4 | Reminders and backup/restore complete: feature-complete MVP |
| M5: Ship | Sprint 5 | Beta feedback applied; production release |

---

## Sprint 1 (Weeks 1 to 2): Foundations, Students, Batches

**Goal:** a running app skeleton with a solid data layer, plus working student and batch management.
**Planned effort:** 64 h

### Tasks

| ID | Task | Est. | Deps | Pri | Acceptance |
|---|---|---|---|---|---|
| S1-01 | **Project scaffold.** Create the Flutter project with `dev`/`prod` flavors, lint rules, `.gitignore`, GitHub Actions CI (analyze, format, test, build APK) | 4 | none | P0 | CI runs green on a push; debug APK built as an artifact |
| S1-02 | **Theme, fonts, localization.** Add Noto Sans Bengali (400/500/700), light/dark themes, `gen-l10n` with `app_bn.arb` and `app_en.arb`, locale switch plumbing | 4 | S1-01 | P0 | Switching locale changes sample strings; conjunct-heavy Bangla text renders correctly on an Android 8 device |
| S1-03 | **Navigation and state shell.** Riverpod setup, `go_router`, bottom navigation (Home, Students, Fees, Reports, Settings) with placeholder screens | 3 | S1-01 | P0 | All five tabs navigate; state survives tab switching |
| S1-04 | **Core value types.** `Taka`, `LocalDate`, `YearMonth` (next, previous, compare, key parse), month-length helpers | 4 | S1-01 | P0 | Unit tests cover month rollover, leap years, due-day clamping (day 31 in February) |
| S1-05 | **Formatters and normalizers.** Bangla digit converter, taka formatter (Western and lakh grouping), month/date formatters, phone normalization (`01…`, `+8801…`, `8801…`) | 5 | S1-04 | P0 | Tests pass for digits, grouping (`১,২৫,০০০`), and all three phone formats |
| S1-06 | **Drift database v1.** All MVP tables from the technical design, indexes, partial unique indexes, `PRAGMA foreign_keys`, WAL, background isolate, in-memory test harness | 8 | S1-01 | P0 | Schema creates cleanly; constraint tests prove duplicate monthly due and duplicate attendance rows are rejected |
| S1-07 | **Migration scaffolding.** Schema version tracking, stepwise migration structure, schema export for `SchemaVerifier`, automatic DB snapshot before any migration | 3 | S1-06 | P0 | A dummy v1 to v2 migration test passes; snapshot file is created before migration |
| S1-08 | **Typed settings store.** Key/value table wrapper with typed getters (language, numerals, proration rule, default due day, reminder times, `next_receipt_no`) | 3 | S1-06 | P0 | Round-trip tests; defaults applied when keys are missing |
| S1-09 | **Student repository and DAO.** Create, update, archive, restore, search by name (case-insensitive, Bangla-safe), filter by status/class, reactive `watch` streams | 4 | S1-06 | P0 | DAO tests for search, filters and archive; stream emits on writes |
| S1-10 | **Student list screen.** Search box, filters (class, status, batch), empty state, archived toggle | 5 | S1-09, S1-03 | P0 | 500 seeded students scroll smoothly; search results update as you type |
| S1-11 | **Add/edit student form.** Quick-add mode (name, fee) and full form, validation, due-day picker, class days and time, subjects | 6 | S1-09, S1-05 | P0 | A student is added in under 20 seconds via quick-add; invalid phone numbers show an error |
| S1-12 | **Student profile shell and contact actions.** Profile header and tab placeholders; one-tap call, SMS, WhatsApp using normalized numbers | 4 | S1-10, S1-05 | P0 | WhatsApp opens the correct chat; SMS opens with the right number |
| S1-13 | **Student photo.** Pick from camera/gallery, compress to about 512 px JPEG, store in app storage, show in lists and profile | 3 | S1-11 | P1 | Stored image under about 80 KB; deleting a student removes the file |
| S1-14 | **Batch management.** Batch repository, create/edit/archive UI, schedule days and time, default fee, assign and remove members with join/leave dates, per-student fee override | 8 | S1-09, S1-03 | P0 | A student can be in several batches; batch detail lists members; fee override saved |

### Sprint 1 Exit Criteria
- App installs and runs on the low-end test device.
- Students and batches can be created, edited, searched and archived in Bangla and English.
- CI is green; DB constraint and formatter tests pass.

### Risks This Sprint
- Bangla font rendering quirks on old Android: test early in S1-02, not at the end.
- Over-polishing forms: ship quick-add first, refine later.

---

## Sprint 2 (Weeks 3 to 4): Fee Engine and Payments

**Goal:** correct, fully tested fee logic and the screens to use it. This is the highest-risk part of the product, so it is built before attendance.
**Planned effort:** 62 h

### Tasks

| ID | Task | Est. | Deps | Pri | Acceptance |
|---|---|---|---|---|---|
| S2-01 | **Fee data layer.** DAOs for `fee_records`, `payments`, `payment_allocations`, `fee_changes`, `pauses`; create the `fee_balances` view | 4 | S1-06 | P0 | View returns paid, balance and payable per due; soft-deleted payments excluded |
| S2-02 | **Due generation (pure Dart).** `generateDues` with fee-change lookup, batch fee override, pause handling, active-in-month check, proration modes (`fullMonth`, `byDays`, `nextMonth`), due-date clamping | 8 | S1-04 | P0 | Test matrix: join on the 1st/15th/31st in every proration mode, fee change mid-year, pause and resume, Feb due day 31 |
| S2-03 | **Due generation orchestrator.** Run on app start, resume, student creation, fee change, unpause; `INSERT OR IGNORE`; wire to repositories | 4 | S2-01, S2-02 | P0 | Running twice yields no duplicates; adding a student immediately yields a due |
| S2-04 | **Allocation function (pure Dart).** `OldestFirst` and `SpecificMonths` targets, partial payments, overpayment becomes advance credit (`fee_record_id = NULL`) | 5 | S2-01 | P0 | Tests: exact, partial, multi-month, overpayment, targeted month with older dues open |
| S2-05 | **Record payment transaction.** One transaction: load open dues, allocate, increment receipt number, insert payment and allocations, write audit log | 5 | S2-04, S1-08 | P0 | Failure mid-way leaves no partial rows; receipt numbers are sequential with no gaps under rapid entry |
| S2-06 | **Edit and delete payment.** Delete = soft delete plus allocation removal; edit = reallocate in one transaction; audit entries; warning if a receipt was shared | 5 | S2-05 | P0 | Dues re-open after delete; balance consistent after editing the amount up and down; receipt number not reused |
| S2-07 | **Credit auto-apply.** When new dues are generated, convert advance credit into real allocations (oldest first) | 3 | S2-03, S2-04 | P0 | Advance payment for 3 future months settles those dues as they are generated |
| S2-08 | **Status derivation.** Paid, Partial, Due, Overdue, Waived computed at read time from balance and today | 2 | S2-01 | P0 | Unit tests around the due date boundary and waived rows |
| S2-09 | **Fees tab: due list.** Outstanding students sorted by overdue days or amount, filters (overdue, due this week, batch), totals header, quick actions (record payment, call) | 6 | S2-08, S1-12 | P0 | List matches the sum of balances; row to payment screen in one tap |
| S2-10 | **Record payment screen.** Amount prefilled with balance, month(s) picker, method chips, reference, date, note, confirmation showing allocation breakdown | 6 | S2-05 | P0 | Partial and multi-month flows complete in under 15 seconds; breakdown matches engine output |
| S2-11 | **Student fees tab and ledger.** Per-month status list, payment history, running balance, edit/delete payment entry points | 5 | S2-06, S1-12 | P0 | Ledger totals equal the due list for that student |
| S2-12 | **Fee adjustments UI.** Change monthly fee from a chosen month, waive or discount a month with a reason, pause and resume fees | 6 | S2-03 | P0 | Past dues unchanged after a fee change; pause stops new dues; waiver visible in ledger |
| S2-13 | **One-time fees.** Add admission, exam or book fee as a one-time due with a label | 3 | S2-01 | P1 | One-time due appears in the due list and accepts payment |
| S2-14 | **Consistency checker.** Developer-menu function validating allocations vs payments, no negative balances, one monthly due per student per month | 3 | S2-06 | P0 | Passes on seeded data; deliberately corrupted data is reported |

### Sprint 2 Exit Criteria
- Entire fee test matrix from the technical design (section 7.7) passes.
- A tutor can enter payments for a seeded set of 20 students and the due list is correct.
- Consistency checker reports clean after a randomized sequence of payments, edits and deletes.

### Risks This Sprint
- Edge cases in allocation edit/delete: write the tests before the UI.
- Product decision pending: payment against a waived month. Default to converting the amount to advance credit and revisit after beta.

---

## Sprint 3 (Weeks 5 to 6): Attendance, Dashboard, Reports, Receipts

**Goal:** the app becomes a daily-use tool: fast attendance, a useful home screen, month summaries, and shareable receipts.
**Planned effort:** 60 h

### Tasks

| ID | Task | Est. | Deps | Pri | Acceptance |
|---|---|---|---|---|---|
| S3-01 | **Expected sessions (pure Dart).** Compute scheduled classes for a date from batch schedules and one-to-one class days; merge with existing session rows for state | 4 | S1-14 | P0 | Tests for multiple classes per day, archived batches excluded, weekday mapping |
| S3-02 | **Session and attendance data layer.** DAOs, enrolled-students-on-date query (respecting join/leave dates), save-in-one-transaction with upsert for re-edits | 5 | S1-06 | P0 | Re-saving the same session updates, never duplicates; a student who left before the date is not listed |
| S3-03 | **Home / Today screen.** Today's classes with state (not taken, taken, cancelled), quick open to attendance, upcoming fee dues this week | 5 | S3-01, S2-09 | P0 | Correct list for a seeded week; state updates immediately after saving attendance |
| S3-04 | **Attendance sheet.** All students default Present, tap to toggle Present/Absent/Late/Excused, save, optional topic note | 6 | S3-02 | P0 | 15 students recorded in under 20 seconds; unsaved changes prompt on back |
| S3-05 | **Cancel, holiday, extra class.** Mark a scheduled class cancelled or holiday with reason; add an unscheduled class on any date | 4 | S3-02 | P0 | Cancelled classes excluded from attendance percentage; extra class appears in history |
| S3-06 | **Edit past attendance.** Date picker, load existing record, edit and save | 3 | S3-04 | P0 | Editing last week's session updates monthly totals |
| S3-07 | **Attendance aggregation queries.** Present/absent/late/excused counts, percentage per student and per batch per month | 3 | S3-02 | P0 | Tests verify percentage rules: `(present + late) / (held - excused)` |
| S3-08 | **Student attendance calendar and monthly summary.** Color-coded month calendar, summary chips, in the student profile | 6 | S3-07 | P0 | Calendar matches saved data; month navigation works; handles months with no classes |
| S3-09 | **Dashboard numbers.** Month expected, collected, outstanding; overdue count; reactive streams | 5 | S2-01 | P0 | Numbers equal the sum of ledger values; update live after recording a payment |
| S3-10 | **Monthly report screen.** Expected vs collected vs outstanding, per-batch breakdown, collection rate | 5 | S3-09, S3-07 | P1 | Totals reconcile with the dashboard and due list |
| S3-11 | **12-month income chart.** Collected per month using `fl_chart` | 3 | S3-09 | P1 | Chart handles empty months and long Bangla month labels |
| S3-12 | **Receipt builder.** PDF and image receipt with tutor/institution name, student, amount, month(s), method, date, receipt number; embedded Bangla font; share sheet | 8 | S2-05, S1-02 | P1 | Receipt renders conjuncts and long names correctly; shared file opens on another phone |
| S3-13 | **Share attendance summary.** Monthly attendance text/image for a guardian | 3 | S3-08 | P1 | Shared text is correct in Bangla and English |

### Sprint 3 Exit Criteria
- A tutor can use the app for a full real month: attendance, payments, dues, summary.
- Dashboard, due list and monthly report all reconcile to the same totals.
- Receipt sharing works end to end on a real phone.

### Risks This Sprint
- Receipts and charts are P1; if Sprint 3 slips, move S3-11 and S3-13 to Sprint 5 first, then S3-12 (see the cut line in section 9).

---

## Sprint 4 (Weeks 7 to 8): Reminders, Messaging, Backup and Restore, Settings

**Goal:** a feature-complete, safe MVP: reliable reminders, one-tap guardian messaging, and trustworthy backup/restore.
**Planned effort:** 60 h

### Tasks

| ID | Task | Est. | Deps | Pri | Acceptance |
|---|---|---|---|---|---|
| S4-01 | **Notification wrapper.** Interface plus `flutter_local_notifications` implementation, timezone init (`Asia/Dhaka`), Android 13 permission flow with rationale screen, channels | 5 | S1-03 | P0 | Test notification fires; denial handled with a clear in-app explanation |
| S4-02 | **ReminderPlanner (pure Dart).** Compute 14 days of class reminders, grouped daily fee-due notifications, weekly dues summary; stable IDs; cancel-and-reschedule | 8 | S3-01, S2-08 | P0 | Tests: correct set for a seeded schedule; no duplicates after re-plan; grouped fee notification counts correct |
| S4-03 | **Refresh triggers.** Re-plan on app start, resume, and data/settings changes; boot receiver configured | 4 | S4-01, S4-02 | P0 | Reminders survive a device reboot on a real phone |
| S4-04 | **Notification tap routing.** Payload to route via `go_router`, including cold start from a notification | 3 | S4-01 | P0 | Tapping a class reminder opens that day's attendance sheet |
| S4-05 | **OEM battery guide.** One-time screen with steps and deep links for Xiaomi, Oppo, Vivo, Realme, Samsung; "reminder health" indicator | 3 | S4-01 | P1 | Guide shown once after enabling reminders; reachable later from Settings |
| S4-06 | **Message templates and composer.** Default Bangla and English templates, variable substitution, template editor with live preview | 6 | S1-05 | P1 | Variables replaced correctly; Bangla digits option respected |
| S4-07 | **Guardian reminders and bulk flow.** SMS and WhatsApp deep links with prefilled text; step-through flow over overdue students, marking each as reminded | 6 | S4-06, S2-09 | P0 | Single send works; bulk flow resumes where it left off after leaving the app |
| S4-08 | **Backup export.** `VACUUM INTO` snapshot, photo copy, `manifest.json` with counts and SHA-256, zip in an isolate, share sheet, record `last_backup_at` | 8 | S1-06 | P0 | Export of a 500-student dataset completes without UI jank; manifest counts match |
| S4-09 | **Backup restore.** File picker, validation (format, schema version, checksum, `integrity_check`), preview screen, safety snapshot, DB swap, photo restore, post-restore tasks (re-plan reminders, regenerate dues), automatic rollback on failure | 9 | S4-08, S1-07 | P0 | Round trip on a fresh install reproduces identical data; corrupted or newer-schema files are rejected with a clear message; forced failure rolls back |
| S4-10 | **Backup reminders and optional encryption.** Banner when last backup is older than N days; optional password-protected backup (AES-GCM, derived key) | 5 | S4-08 | P0 / P1 | Banner appears on schedule; wrong password fails gracefully; encrypted file restores with the right one |
| S4-11 | **Settings screens.** Language, numeral style, theme, default due day, proration rule, reminder times, template editor entry, delete all data (double confirm) | 5 | S1-08 | P0 | All settings persist and take effect immediately |
| S4-12 | **Receipt number continuity after restore.** Set `next_receipt_no` to `MAX(receipt_no) + 1` on restore | 1 | S4-09 | P1 | Receipt numbers never go backward after restore |

### Sprint 4 Exit Criteria
- Feature-complete MVP per the spec's P0 list.
- Backup, factory reset, restore on a clean install: identical data verified.
- Reminders verified on at least two different OEM devices.

### Risks This Sprint
- OEM battery managers can suppress reminders: test on real hardware, not only emulators.
- Restore is the most dangerous code path; keep the safety snapshot and rollback tests mandatory.

---

## Sprint 5 (Weeks 9 to 10): Hardening, Onboarding, Beta, Release

**Goal:** turn a feature-complete MVP into a shippable product, driven by real tutor feedback.
**Planned effort:** 60 h

### Tasks

| ID | Task | Est. | Deps | Pri | Acceptance |
|---|---|---|---|---|---|
| S5-01 | **App lock.** PIN stored as salted hash in secure storage, optional biometric via `local_auth`, auto-lock timeout, optional screen-capture protection | 6 | S4-11 | P1 | Lock engages after timeout; wrong PIN attempts handled; reset path documented (loses data only after confirmation) |
| S5-02 | **Onboarding and sample data.** Language pick, three skippable intro screens, optional sample data load and one-tap removal | 5 | S1-02 | P1 | Fresh install flows to the Home screen in under 30 seconds; sample data removal leaves no residue |
| S5-03 | **Performance pass.** Seed stress data (500 students, 20k attendance rows, 6k payments); profile on a 2 GB device; fix jank, add missing indexes, trim startup | 6 | all | P0 | Cold start under 2 s; lists at 60 fps; reports load under 1 s |
| S5-04 | **Accessibility and Bangla audit.** Font scale 1.3x, tap targets of at least 48 dp, contrast, long-name wrapping, Bangla digit consistency across every screen | 5 | all | P0 | Checklist signed off on the low-end device |
| S5-05 | **Edge-case pass.** Walk through each item in spec section 7 (mid-month join, date change, phone formats, newer-schema backup, and so on) and fix gaps | 8 | all | P0 | Each edge case has a test or a documented manual verification |
| S5-06 | **Integration tests.** Automated flows A to E from the spec (attendance, payment, chase dues, backup, migrate to a new phone) | 8 | all | P0 | Suite green in CI on an emulator |
| S5-07 | **Release engineering.** Signed release build, ABI splits, obfuscation with symbols, size check (under 25 MB), Play listing in Bangla and English, privacy policy, data safety form, screenshots | 6 | all | P0 | Internal track build installs and passes smoke tests |
| S5-08 | **Closed beta.** Recruit 10 to 20 tutors (WhatsApp group works well), 7-day trial, simple feedback form, daily triage | 8 | S5-07 | P0 | Feedback logged and prioritized; no critical data-loss bug open |
| S5-09 | **Fix buffer.** Beta fixes, polish, final regression run | 8 | S5-08 | P0 | Release candidate approved by the checklist in section 8 |

### Sprint 5 Exit Criteria
- Production release submitted to Google Play; direct APK available as a fallback.
- No open P0 bugs; known issues documented.

---

## 2. Dependency Map (Critical Path)

```
S1-01 → S1-06 (DB) → S1-09 (students) → S1-14 (batches) ─┐
S1-04 (types) → S2-02 (dues) → S2-03 → S2-07              │
S1-06 → S2-01 → S2-04 (allocate) → S2-05 → S2-06          ├→ S3-01 → S4-02 (planner)
S2-08 (status) → S2-09 (due list) → S4-07 (bulk remind)   │
S3-02 (attendance data) → S3-04 → S3-08                   │
S1-06 → S4-08 (export) → S4-09 (restore) → S5-06 (tests) ─┘
```

**Critical path:** DB schema, then fee engine, then payments, then due list, then reminders and backup/restore, then integration tests, then release. Any slip in the fee engine or restore flow directly moves the release date.

---

## 3. Testing Plan by Sprint

| Sprint | Tests added |
|---|---|
| 1 | Value types, formatters, phone normalization, DB constraints, settings, student DAO, migration scaffold |
| 2 | Due generation matrix, allocation matrix, payment edit/delete, status derivation, consistency checker, randomized payment sequences |
| 3 | Expected sessions, attendance aggregation rules, dashboard totals reconciliation, receipt rendering smoke tests |
| 4 | Reminder planner, message composer, backup round trip, restore failure/rollback, corrupted and newer-schema files |
| 5 | Integration flows A to E, performance benchmarks, accessibility checklist, full regression |

### Standing Manual Device Checklist (run at the end of every sprint)
- [ ] Fresh install, no crash, Bangla renders correctly
- [ ] Add 3 students, record a payment, take attendance
- [ ] Kill the app mid-save; no corrupted data on relaunch
- [ ] Airplane mode: every feature works
- [ ] Reboot the phone; reminders still fire (from Sprint 4)
- [ ] Export, uninstall, reinstall, restore (from Sprint 4)

---

## 4. Environments and Tooling

| Item | Setup |
|---|---|
| Devices | At least one 2 GB RAM Android 8/9 phone, one mid-range current phone; an emulator for Android 7 and 14 |
| Source control | Trunk-based with short-lived branches; PR per task or small group of tasks |
| CI | GitHub Actions: analyze, format, test, build APK on push |
| Task tracking | One board column per sprint; IDs from this document as card titles |
| Test data | A seed script generating small (10), medium (100) and stress (500) datasets, with Bangla names |
| Secrets | None required in v1 (no backend); keystore stored offline with a backup |

---

## 5. Working Agreements (Solo Developer)

1. **Tests first for money logic.** No fee-engine code is merged without its matrix tests.
2. **Vertical slices.** Prefer finishing one screen end-to-end (DB, domain, UI, test) over building layers in isolation.
3. **Demo at every sprint end.** Record a short screen capture of the exit demo; it doubles as progress evidence and beta material.
4. **Timebox polish.** Cap UI polish per task at 20 percent of its estimate; log the rest as backlog.
5. **Real data early.** Give a real tutor a Sprint 2 build to enter their actual students; this surfaces model flaws long before beta.
6. **Daily rhythm suggestion:** 1 hour of planning and test writing, 3 to 4 hours of building, 30 minutes of device testing and commit notes.

### Using AI Coding Assistants Effectively
- Give the assistant the spec and technical design files as context for each task.
- Ask for pure-Dart domain code and its tests first, then UI.
- Paste the task row (ID, acceptance) into the prompt; ask the assistant to write tests that prove each acceptance line.
- Review generated SQL and money arithmetic yourself; those are the highest-risk areas.

---

## 6. Risk Register (Schedule-Focused)

| Risk | Likelihood | Impact | Trigger | Response |
|---|---|---|---|---|
| Fee edge cases take longer than planned | Medium | High | S2 test matrix still failing at day 7 | Cut one-time fees (S2-13) and credit auto-apply polish; keep core allocation |
| Notification reliability across OEMs | High | Medium | Reminders missing on Xiaomi/Oppo test phones | Ship rolling window and battery guide; document limitation; do not block release |
| Restore bugs | Medium | Very high | Any data mismatch in round-trip tests | Hold the release; this blocks everything else |
| Bangla PDF rendering issues | Medium | Medium | Broken conjuncts in receipts | Fall back to rendering the receipt as an image from a Flutter widget instead of a PDF |
| Beta reveals a model flaw | Medium | High | Tutors request per-class billing or different fee rules | Log for v1.1; only fix if it breaks core flows |
| Developer availability dips | Medium | Medium | Less than 20 hours in a week | Apply the cut line below |
| Play Store review delay | Low | Medium | Rejection or long review | Submit to the internal track by the end of Sprint 4; distribute APK directly if needed |

---

## 7. Scope Management

### Cut Line (drop in this order if behind schedule)
1. S3-13 Share attendance summary
2. S3-11 12-month income chart
3. S5-02 Sample data (keep a minimal onboarding)
4. S4-10 Backup encryption (keep reminders)
5. S4-05 OEM battery guide screen (replace with a help text)
6. S3-12 Receipt builder (ship in v1.1)
7. S5-01 App lock (ship in v1.1)

### Never Cut
- Fee engine, payment edit/delete with audit, due list
- Attendance sheet and monthly summary
- Backup export and restore with safety snapshot and rollback
- Local reminders for classes and fee dues
- Bangla UI and correct font rendering

### Deferred to v1.1 and Later
Exams and marks, homework and syllabus, per-class billing, auto-backup to a folder, Drive backup, SQLCipher, CSV import, sibling discounts, late fees, widgets.

---

## 8. Release Checklist

**Quality**
- [ ] All unit, DB, migration and integration tests green in CI
- [ ] Fee engine matrix and randomized payment test passing
- [ ] Consistency checker clean on stress dataset after random operations
- [ ] Backup, restore on a clean install, restore failure rollback verified
- [ ] Device checklist passed on a 2 GB phone and on at least two OEM brands

**Product**
- [ ] Bangla and English strings reviewed by a native speaker
- [ ] Default message templates reviewed by a few tutors
- [ ] Privacy note visible in-app; privacy policy URL ready for Play
- [ ] Backup reminder defaults sensible (7 days)

**Release**
- [ ] APK size under 25 MB per ABI
- [ ] Keystore and upload key backed up offline
- [ ] Play listing assets in Bangla and English; data safety form completed (no data collected)
- [ ] Crash reporting through Play Console vitals confirmed
- [ ] Direct APK and install instructions prepared for non-Play users
- [ ] Support contact (WhatsApp or email) listed in the app and the store page

---

## 9. After Release: First 30 Days

| Week | Focus |
|---|---|
| 1 | Watch Play Console vitals and reviews daily; hotfix any data-integrity bug immediately |
| 2 | Collect feature requests; interview 3 to 5 active users about their month-end flow |
| 3 | Prioritize v1.1 (receipts polish, exams, app lock, auto-backup) based on actual requests |
| 4 | Plan Sprint 6 and 7 using the same task format as this document |

### Suggested v1.1 Sprint Preview
- Exams and marks with progress charts (spec section 3.8)
- Auto-backup to a user-chosen folder
- SQLCipher option and backup encryption polish
- Per-class billing mode if beta demand confirms it
- Search transliteration (English input finding Bangla names)

---

## 10. Effort Summary

| Sprint | Planned hours | P0 share | Notes |
|---|---|---|---|
| 1 | 64 | High | Foundations; Bangla rendering checks early |
| 2 | 62 | Very high | Fee engine; the riskiest sprint |
| 3 | 60 | Medium | Receipts and charts are P1 and flex |
| 4 | 60 | High | Restore is the most delicate task |
| 5 | 60 | High | Includes 8 h beta and 8 h fix buffer |
| **Total** | **306** | | About 10 weeks at 30 h/week |
