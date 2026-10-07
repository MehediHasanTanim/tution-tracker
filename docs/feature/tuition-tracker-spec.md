# Tuition Tracker: Feature Specification

**Working name:** Tuition Khata (টিউশন খাতা)
**Platform:** Android first (iOS optional later)
**Architecture:** Fully offline, on-device storage, no backend server
**Primary audience:** Home tutors and small coaching centers in Bangladesh
**Primary language:** Bangla (with English toggle)
**Document status:** Draft v0.1

---

## 1. Product Overview

### 1.1 Problem
Private tuition is a huge informal economy in Bangladesh. Most home tutors and small coaching owners track students, attendance and fees in paper notebooks or memory. Common pain points:

- Forgetting which students have not paid this month
- Disputes over how many classes were actually held
- No clear view of monthly income
- Chasing parents for fees awkwardly and inconsistently
- Losing the notebook means losing all records

### 1.2 Solution
A simple, Bangla-first mobile app that works without internet or signup. The tutor records students, batches, attendance and fee payments in a few taps, and the app shows who owes what, sends reminders, and produces monthly summaries.

### 1.3 Goals
- Daily use takes under 30 seconds (mark attendance, record a payment)
- Zero setup friction: no account, no login, no internet
- Runs smoothly on low-end Android phones (2 GB RAM)
- Data is safe through export/import backup

### 1.4 Non-Goals (v1)
- Online payments or payment gateway integration
- Cloud sync or multi-device accounts
- Student/parent-facing app
- Video classes or any content delivery
- Multi-teacher coaching center management with roles

### 1.5 Target Users

| Persona | Description | Key need |
|---|---|---|
| Home tutor | University student or graduate, 3 to 15 students | Fee tracking, simple attendance |
| Batch tutor | Teaches groups at home or a rented room, 15 to 60 students | Batch management, bulk attendance |
| Small coaching owner | Runs a coaching center alone or with 1 to 2 helpers | Income overview, due list, reports |

---

## 2. Scope and Release Plan

| Release | Contents |
|---|---|
| **MVP (v1.0)** | Students, batches, attendance, fee ledger, due list, local reminders, monthly summary, backup/restore, Bangla UI |
| **v1.1** | Exam/marks tracking, SMS/WhatsApp message templates, PDF receipts, app lock |
| **v1.2** | Homework and syllabus tracker, income/expense, reports export, widgets |
| **Later** | Multiple tutor profiles, Google Drive auto-backup, iOS |

---

## 3. Functional Requirements

Priority key: **P0** = MVP must have, **P1** = should have, **P2** = nice to have.

### 3.1 Onboarding and Profile

| ID | Requirement | Priority |
|---|---|---|
| ON-1 | First launch shows language choice (বাংলা / English) | P0 |
| ON-2 | Optional tutor profile: name, phone, institution name (used on receipts) | P0 |
| ON-3 | No signup, login or permissions prompt beyond what a feature needs at the moment of use | P0 |
| ON-4 | Short 3-screen intro explaining students, attendance, fees; skippable | P1 |
| ON-5 | Option to load sample data to explore the app, removable in one tap | P2 |

### 3.2 Student Management

**Student fields**

| Field | Type | Required | Notes |
|---|---|---|---|
| Name | Text | Yes | Bangla or English |
| Class / grade | Picker | No | Class 1 to 12, HSC, Admission, Other |
| School / institution | Text | No | |
| Guardian name | Text | No | |
| Guardian phone | Phone | No | Used for call, SMS, WhatsApp |
| Student phone | Phone | No | |
| Address / area | Text | No | Helpful for home tutors |
| Photo | Image | No | Stored locally, compressed |
| Subjects | Multi-select | No | |
| Joining date | Date | Yes | Defaults to today |
| Monthly fee | Amount (BDT) | Yes | Can be per-student or inherited from batch |
| Fee due day | Number 1 to 31 | Yes | Day of month fee is expected |
| Class days | Weekday multi-select | No | Used to pre-generate schedule |
| Class time | Time | No | |
| Notes | Text | No | |
| Status | Enum | Yes | Active, Paused, Left |

| ID | Requirement | Priority |
|---|---|---|
| ST-1 | Add, edit, and archive students | P0 |
| ST-2 | Quick-add mode: name + monthly fee only, fill the rest later | P0 |
| ST-3 | Student list with search (Bangla and English), filter by class, batch, status | P0 |
| ST-4 | Student profile page showing attendance summary, fee status, and notes | P0 |
| ST-5 | One-tap call, SMS, and WhatsApp to guardian | P0 |
| ST-6 | Archive instead of delete; permanent delete requires confirmation and warns that history is lost | P0 |
| ST-7 | Import students from phone contacts | P1 |
| ST-8 | Import students from CSV | P2 |
| ST-9 | Siblings grouping (shared guardian, optional sibling discount) | P2 |

### 3.3 Batch / Group Management

| ID | Requirement | Priority |
|---|---|---|
| BT-1 | Create batches with name, subject, class, schedule (days and time), default monthly fee | P0 |
| BT-2 | Assign students to one or more batches | P0 |
| BT-3 | Batch view lists students, attendance rate, and fee collection status for the month | P0 |
| BT-4 | Per-student fee override within a batch (scholarship, discount) | P1 |
| BT-5 | Batch capacity and seat count | P2 |
| BT-6 | Duplicate batch for the next session | P2 |

Students may exist without any batch (typical for one-to-one home tutoring).

### 3.4 Attendance

| ID | Requirement | Priority |
|---|---|---|
| AT-1 | Today screen lists scheduled classes; tap to open attendance | P0 |
| AT-2 | Mark Present / Absent / Late per student; default all Present with one-tap flip for absentees | P0 |
| AT-3 | Add an extra (unscheduled) class on any date | P0 |
| AT-4 | Mark a class as Cancelled or Holiday with optional reason | P0 |
| AT-5 | Edit past attendance with a date picker | P0 |
| AT-6 | Calendar view per student with color-coded days | P0 |
| AT-7 | Monthly attendance summary: classes held, attended, absent, percentage | P0 |
| AT-8 | Excused absence status that does not count against attendance | P1 |
| AT-9 | Per-class note (topic covered) | P1 |
| AT-10 | Share monthly attendance summary with a guardian as text or image | P1 |
| AT-11 | Make-up class linked to a missed one | P2 |

**Rules**
- Scheduled class entries are generated on demand from the batch or student schedule, not stored far into the future.
- Attendance for a date can be saved even if the schedule did not include that day.
- Changing a schedule affects only future dates, never past records.

### 3.5 Fee Management

Fees are the core of the app, so the model needs to be precise.

**Fee model**
- Each student has a monthly fee amount, due day, and start date.
- The app generates one **fee record per student per month** (a "due") when the month begins or on first open of that month.
- Payments are recorded against dues. A payment can be partial, full, or cover multiple months.

**Payment fields**

| Field | Notes |
|---|---|
| Amount (BDT) | Required |
| Date received | Defaults to today |
| Applied to month(s) | Defaults to the oldest unpaid month |
| Method | Cash, bKash, Nagad, Rocket, Bank, Other (label only; no integration) |
| Transaction ID / reference | Optional, useful for mobile banking |
| Note | Optional |

| ID | Requirement | Priority |
|---|---|---|
| FE-1 | Record a payment from the student profile or from the Due list in two taps | P0 |
| FE-2 | Support partial payments with the remaining balance carried visibly | P0 |
| FE-3 | Advance payments applied to future months automatically | P0 |
| FE-4 | Due list showing all students with outstanding balance, sorted by overdue days or amount | P0 |
| FE-5 | Fee status per student per month: Paid, Partial, Due, Overdue, Waived | P0 |
| FE-6 | Waive or discount a month's fee with a reason | P0 |
| FE-7 | Change a student's monthly fee effective from a chosen month without rewriting history | P0 |
| FE-8 | Edit or delete a payment with confirmation; deletions are logged | P0 |
| FE-9 | Receipt generation as shareable image or PDF with tutor name, student, amount, month, date, receipt number | P1 |
| FE-10 | Sequential receipt numbering that survives backup/restore | P1 |
| FE-11 | Pause fees while a student is on break (no dues generated) | P1 |
| FE-12 | One-time fees (admission, exam fee, book fee) | P1 |
| FE-13 | Late-fee rules (optional) | P2 |
| FE-14 | Sibling or batch-wide discount rules | P2 |

**Business rules**
1. A due is generated for a month only if the student is Active (or was Active for part of it) and joined on or before that month.
2. Pro-rating for mid-month joins is a setting: full month, pro-rated by days, or from the next month. Default is full month.
3. Overdue means today is later than the due date and the balance is greater than zero.
4. Payments are applied oldest due first unless the tutor picks a specific month.
5. Amounts are stored as integers in paisa (or whole taka) to avoid floating point errors.

### 3.6 Reminders and Communication

All reminders run on-device through local notifications. No server involved.

| ID | Requirement | Priority |
|---|---|---|
| RM-1 | Daily class reminder at a configurable time (for example 30 minutes before class) | P0 |
| RM-2 | Fee due reminder to the tutor on the morning of a student's due day | P0 |
| RM-3 | Weekly summary notification of total outstanding dues | P1 |
| RM-4 | One-tap "send fee reminder" to the guardian via SMS or WhatsApp using a prefilled template | P0 |
| RM-5 | Editable message templates in Bangla and English with variables: `{student}`, `{month}`, `{amount}`, `{due}` | P1 |
| RM-6 | Bulk reminder flow: step through all overdue students and send one by one | P1 |
| RM-7 | Reminders still fire after device reboot and respect battery optimization guidance | P0 |
| RM-8 | Do-not-disturb hours setting | P2 |

**Technical note:** the app opens the SMS or WhatsApp compose screen with text prefilled. The user taps send. Silent background SMS is out of scope because it needs sensitive permissions and risks store rejection.

### 3.7 Dashboard and Reports

**Home dashboard**
- Today's classes (with quick attendance entry)
- This month: collected, expected, outstanding (BDT)
- Overdue students count with a link to the Due list
- Upcoming fee due dates this week

| ID | Requirement | Priority |
|---|---|---|
| RP-1 | Monthly income summary: expected vs collected vs outstanding | P0 |
| RP-2 | Income by month chart for the last 12 months | P1 |
| RP-3 | Per-batch collection and attendance summary | P1 |
| RP-4 | Student ledger: complete payment history for one student | P0 |
| RP-5 | Export report as PDF or CSV and share | P1 |
| RP-6 | Year summary useful for personal income tracking | P2 |

### 3.8 Exams and Progress (v1.1)

| ID | Requirement | Priority |
|---|---|---|
| EX-1 | Create an exam or test with date, subject, total marks, batch | P1 |
| EX-2 | Enter marks per student quickly with a numeric keypad flow | P1 |
| EX-3 | Student progress chart across exams | P1 |
| EX-4 | Share a result summary with a guardian | P1 |
| EX-5 | Class average, highest, lowest | P2 |

### 3.9 Homework and Syllabus (v1.2)

| ID | Requirement | Priority |
|---|---|---|
| HW-1 | Assign homework per class with due date | P2 |
| HW-2 | Mark submitted / not submitted per student | P2 |
| HW-3 | Syllabus checklist per batch with chapters and completion state | P2 |

### 3.10 Backup, Restore, and Data Safety

This is a critical area because there is no server.

| ID | Requirement | Priority |
|---|---|---|
| BK-1 | Manual export of all data to a single backup file (JSON or SQLite dump, optionally zipped with photos) | P0 |
| BK-2 | Share the backup through the system share sheet (WhatsApp, Drive, email, Bluetooth, files) | P0 |
| BK-3 | Restore from a backup file with preview (student count, last payment date) and a clear warning that it replaces current data | P0 |
| BK-4 | Backup version number so older backups can migrate to newer schemas | P0 |
| BK-5 | Reminder to back up if the last backup is older than 7 days (configurable) | P0 |
| BK-6 | Auto-backup to a user-chosen local folder on a schedule | P1 |
| BK-7 | Optional password protection of the backup file | P1 |
| BK-8 | Optional Google Drive backup through the user's own Drive (no developer server) | P2 |
| BK-9 | Automatic local snapshot before any destructive action or restore, with undo | P1 |

### 3.11 Settings

| ID | Requirement | Priority |
|---|---|---|
| SE-1 | Language: Bangla / English | P0 |
| SE-2 | Numeral style: Bangla digits or English digits | P0 |
| SE-3 | Currency format: ৳ with Bangla or Western digit grouping | P0 |
| SE-4 | Theme: light / dark / system | P1 |
| SE-5 | Default fee due day, pro-rating rule, default reminder times | P0 |
| SE-6 | App lock with PIN or biometric | P1 |
| SE-7 | Calendar preference: Gregorian only, or show Bangla calendar dates | P2 |
| SE-8 | Font size scaling | P1 |
| SE-9 | Message templates editor | P1 |
| SE-10 | Delete all data (double confirmation) | P0 |

---

## 4. Screens and Navigation

### 4.1 Bottom Navigation
1. **Home** (dashboard, today's classes)
2. **Students** (list, batches tab)
3. **Fees** (due list, payments, month view)
4. **Reports**
5. **Settings** (or under a menu icon if space is tight)

### 4.2 Screen Inventory

| Screen | Purpose |
|---|---|
| Home / Today | Today's classes, key numbers, quick actions |
| Student list | Search, filter, add |
| Student profile | Tabs: Overview, Attendance, Fees, Notes |
| Add/Edit student | Form with quick-add variant |
| Batch list / detail | Students, schedule, collection |
| Attendance sheet | Mark attendance for a class |
| Attendance calendar | Month view per student |
| Due list | Outstanding balances with call/remind actions |
| Record payment | Amount, month(s), method, note |
| Payment history | Ledger per student, global list |
| Receipt preview | Render and share |
| Monthly report | Collected vs expected, charts |
| Exam list / marks entry | v1.1 |
| Backup & restore | Export, import, auto-backup settings |
| Settings | Preferences |

### 4.3 Key User Flows

**Flow A: Daily attendance (target under 20 seconds)**
Home, tap today's class, all students default to Present, tap absentees, Save.

**Flow B: Record a fee payment (target under 15 seconds)**
Fees tab, tap student in Due list, amount prefilled with balance, adjust if partial, choose method, Save, optional Share Receipt.

**Flow C: Chase overdue fees**
Fees tab, Overdue filter, tap the reminder icon on a student, WhatsApp opens with prefilled message, send, return to the app.

**Flow D: Back up data**
Settings, Backup, Export, share sheet opens, send to WhatsApp or save to Drive.

**Flow E: New phone migration**
Install the app on the new phone, Settings, Restore, pick the backup file, preview, confirm.

---

## 5. Data Model (Local Storage)

Recommended storage: SQLite (via Drift, Room, or sqflite) or Isar. A relational store fits this domain best because of ledger-style queries.

### 5.1 Entities

```
Student
  id (uuid)
  name
  class_level
  school
  guardian_name
  guardian_phone
  student_phone
  address
  photo_path
  subjects (json)
  joined_on (date)
  status (active | paused | left)
  monthly_fee (int)
  fee_due_day (int)
  notes
  created_at, updated_at

Batch
  id (uuid)
  name
  subject
  class_level
  schedule_days (json)
  start_time
  duration_min
  default_fee (int)
  status
  created_at, updated_at

BatchMember
  id
  batch_id -> Batch
  student_id -> Student
  fee_override (int, nullable)
  joined_on (date)
  left_on (date, nullable)

ClassSession
  id (uuid)
  batch_id (nullable) -> Batch
  student_id (nullable) -> Student   // for one-to-one classes
  date
  start_time
  status (held | cancelled | holiday)
  topic
  note

Attendance
  id
  session_id -> ClassSession
  student_id -> Student
  status (present | absent | late | excused)

FeeRecord                         // one "due" per student per month
  id
  student_id -> Student
  month (YYYY-MM)
  amount_due (int)
  discount (int)
  waived (bool)
  due_date (date)

Payment
  id
  student_id -> Student
  amount (int)
  received_on (date)
  method (cash | bkash | nagad | rocket | bank | other)
  reference
  receipt_no (int)
  note
  created_at

PaymentAllocation                 // links a payment to the dues it covers
  id
  payment_id -> Payment
  fee_record_id -> FeeRecord
  amount (int)

FeeChange                         // history of monthly fee changes
  id
  student_id -> Student
  effective_month (YYYY-MM)
  new_amount (int)

Exam, ExamResult                  // v1.1
Setting (key, value)
MessageTemplate (id, kind, language, body)
AuditLog (id, entity, entity_id, action, at)   // payment edits/deletes
```

### 5.2 Design Notes
- Money stored as integers; never floats.
- Dates stored as ISO strings in local time (Asia/Dhaka). Avoid timezone drift by storing date-only fields as dates, not timestamps.
- Use UUIDs for ids so backups and future sync/merge stay possible.
- Balance is derived: sum of dues minus sum of allocations. Do not store it, so it cannot go out of sync.
- Soft-delete (status or `deleted_at`) for students, batches and payments.
- Keep a schema version and write forward-only migrations from day one.

---

## 6. Non-Functional Requirements

| Area | Requirement |
|---|---|
| **Offline** | 100% of features work with no network. No analytics or ads that require network in v1 |
| **Performance** | Cold start under 2 seconds on a 2 GB RAM device; list scrolling at 60 fps with 500 students |
| **App size** | Target APK under 25 MB |
| **Device support** | Android 7.0+ (API 24+), small screens down to 5 inches |
| **Localization** | Full Bangla UI, Bangla numerals option, proper Bangla font rendering (for example Noto Sans Bengali or Hind Siliguri), including conjuncts and long names |
| **Accessibility** | Tap targets at least 48 dp, adjustable font size, sufficient contrast |
| **Reliability** | Writes are transactional; app never loses data on crash or force-close |
| **Privacy** | Student data stays on the device; no data leaves unless the user exports or shares it. A short in-app privacy note explains this |
| **Security** | Optional app lock; encrypted database optional (SQLCipher) for v1.1 |
| **Battery** | Notification scheduling uses the OS alarm APIs; no persistent background service |
| **Testing** | Unit tests for fee calculation and allocation logic are mandatory; test on low-end devices and Bangla locale |

---

## 7. Edge Cases to Handle

1. **Student joins mid-month:** apply the pro-rating setting; show the calculated amount before saving.
2. **Fee increases mid-year:** use `FeeChange` with an effective month; past dues stay unchanged.
3. **Payment covers several months:** allocate across dues oldest first, show the breakdown in the confirmation.
4. **Overpayment:** keep the surplus as advance credit applied to the next generated due.
5. **Payment edited or deleted:** recalculate allocations; write an audit log entry; warn if a receipt was already issued.
6. **Student pauses then resumes:** no dues during the pause; resume date sets the next due.
7. **Device date changed manually:** warn if the system date jumps backward significantly; never auto-delete data based on date.
8. **Phone number formats:** accept `01XXXXXXXXX`, `+8801XXXXXXXXX` and `8801XXXXXXXXX`; normalize for WhatsApp links.
9. **Very long Bangla names:** wrap text; avoid truncating in lists without a tooltip or detail view.
10. **Backup restored on an older app version:** detect a newer schema version and refuse with a clear message.
11. **Notifications blocked by OEM battery managers** (Xiaomi, Oppo, Vivo, Realme, Samsung): show a one-time guide to whitelist the app.
12. **Multiple classes the same day for the same student:** support more than one session per date.
13. **Month with five weeks or irregular classes:** the fee is monthly and flat, so attendance counts do not change the fee unless a per-class fee mode is added later.

---

## 8. Optional Fee Mode: Per-Class Billing (v1.2)

Some tutors charge per class instead of a flat monthly fee. If supported:
- Student-level setting: `fee_mode = monthly | per_class`
- Monthly due = number of classes held and attended × per-class rate
- Excused absences and make-up classes follow a configurable rule
- Dues are finalized at month end, not at month start

---

## 9. Monetization Options (No Server)

| Option | Notes |
|---|---|
| Free with limits | For example up to 10 students free; unlimited on unlock |
| One-time unlock | Paid via Play Store billing, which needs no backend of your own |
| Manual unlock via bKash/Nagad | Offline-verifiable license key generated by you; more friction and support work, but reaches users without cards |
| Light ads | Banner only on the Reports screen; must work offline when no ad is available |

Recommendation: free tier up to 10 students with a one-time unlock through Play Store billing. Add a manual license key path only if user demand justifies it.

---

## 10. Success Metrics (Measured Without a Server)

Without analytics, rely on:
- Play Console installs, retention, crash reports (ANR and Android vitals)
- Play Store ratings and written reviews
- Optional in-app feedback button that opens the user's email or WhatsApp to the developer
- Optional local-only "usage streak" shown to the user as motivation, not collected

Target indicators: day-30 retention above 30 percent, crash-free sessions above 99 percent, average rating above 4.3.

---

## 11. Suggested Tech Stack

| Layer | Suggestion |
|---|---|
| Framework | Flutter (strong Bangla text rendering, single codebase, good for low-end devices) |
| Local database | Drift (SQLite) or Isar |
| State management | Riverpod or Bloc |
| Notifications | `flutter_local_notifications` with exact alarm handling |
| PDF / receipt | `pdf` and `printing` packages with an embedded Bangla font |
| Sharing | `share_plus` |
| Backup | JSON export zipped with photos, or raw SQLite file copy with a version header |
| Charts | `fl_chart` |
| Localization | `flutter_localizations` with ARB files for `bn` and `en` |

---

## 12. Milestones (Indicative)

| Phase | Duration | Deliverable |
|---|---|---|
| 1. Foundations | 1 week | Project setup, DB schema, localization, theme, navigation shell |
| 2. Students and batches | 1 week | CRUD, search, profile |
| 3. Attendance | 1 week | Today screen, sheet, calendar, summaries |
| 4. Fees | 1.5 weeks | Dues generation, payments, allocation, due list |
| 5. Reminders and dashboard | 1 week | Local notifications, message templates, home dashboard |
| 6. Backup and polish | 1 week | Export/import, edge cases, low-end device testing |
| 7. Beta and release | 1 week | Closed beta with 10 to 20 real tutors, fixes, Play Store listing |

Approximate total: 7 to 8 weeks for one developer.

---

## 13. Open Questions

1. Should the MVP include one-to-one home tutoring only, or batch-based coaching from day one?
2. Is pro-rating mid-month joins needed in v1, or is "full month" enough?
3. Should receipts be in the MVP or deferred to v1.1?
4. Is per-class billing common enough among the target tutors to move earlier?
5. Will the app be Android only at launch?
6. Which monetization model fits the target users best?
7. Should Bangla calendar dates (Bangabda) be displayed alongside Gregorian dates?

---

## 14. Acceptance Criteria Summary (MVP)

- [ ] A tutor can add 10 students in under 3 minutes using quick-add
- [ ] Attendance for a batch of 15 can be recorded in under 20 seconds
- [ ] A payment, including partial and multi-month, can be recorded in under 15 seconds
- [ ] The Due list always matches the sum of dues minus allocations
- [ ] Fee reminders open SMS/WhatsApp with a correct prefilled Bangla message
- [ ] Class and fee notifications fire reliably, including after reboot
- [ ] Export, then restore on a fresh install, reproduces all data exactly
- [ ] The entire UI is usable in Bangla with correct rendering
- [ ] The app works with airplane mode enabled and no account created
- [ ] Cold start under 2 seconds on a 2 GB RAM device
