# Tuition Tracker: Technical Design

**Companion to:** `tuition-tracker-spec.md`
**Platform:** Android first (Flutter, iOS-ready)
**Architecture:** Offline-first, on-device storage, no backend
**Document status:** Draft v0.1

---

## 1. Goals and Constraints

| Constraint | Design consequence |
|---|---|
| No backend, no accounts | All logic and storage live on the device; the backup file is the only portability mechanism |
| Low-end Android (2 GB RAM, Android 7+) | Small dependency set, lazy loading, paginated queries, no heavy animations |
| Money correctness | Integer arithmetic, derived balances, transactional writes, unit-tested fee engine |
| Bangla-first | Bundled Bangla font, ARB localization, Bangla digit formatting layer |
| Data-loss risk | Safe backup/restore, pre-destructive snapshots, schema migrations from day one |
| Solo-developer maintainability | Simple layered architecture, minimal code generation, clear module boundaries |

---

## 2. Technology Choices

| Concern | Choice | Rationale |
|---|---|---|
| Framework | Flutter (stable channel) | Strong Bengali text shaping, one codebase, good low-end performance |
| Language | Dart 3 | Sealed classes and records help model fee states and results |
| Database | Drift (SQLite) | Type-safe SQL, migrations, reactive streams, good for ledger-style joins and aggregates |
| State management | Riverpod | Testable, compile-safe, works well with Drift streams |
| Routing | go_router | Declarative, deep-link friendly for notification taps |
| Notifications | flutter_local_notifications + timezone | Scheduled local notifications, boot rescheduling |
| PDF / receipts | pdf + printing | Embeds Bangla fonts; renders to PDF or image |
| Share / open | share_plus, url_launcher | Share sheet, SMS and WhatsApp deep links |
| File access | path_provider, file_picker, archive | Backup export/import |
| Charts | fl_chart | Lightweight |
| Contacts (optional) | flutter_contacts | Import guardian numbers, requested only at point of use |
| Biometrics (optional) | local_auth | App lock |
| Secure storage | flutter_secure_storage | PIN hash, backup password salt |
| Testing | flutter_test, mocktail, integration_test | |

Keep the dependency list short. Every package adds APK size and upgrade burden.

---

## 3. High-Level Architecture

```
┌──────────────────────────────────────────────────────────┐
│                     Presentation                         │
│   Screens / Widgets / Controllers (Riverpod Notifiers)   │
└──────────────────────────┬───────────────────────────────┘
                           │ uses
┌──────────────────────────▼───────────────────────────────┐
│                      Domain layer                        │
│  Use cases / Services (pure Dart, no Flutter imports)    │
│  FeeEngine · AttendanceService · ReminderPlanner ·       │
│  BackupService · MessageComposer · ReceiptBuilder        │
└──────────────────────────┬───────────────────────────────┘
                           │ uses
┌──────────────────────────▼───────────────────────────────┐
│                       Data layer                         │
│  Repositories (interfaces) → Drift DAOs                  │
│  File store (photos, backups) · Settings store           │
└──────────────────────────┬───────────────────────────────┘
                           │
              ┌────────────▼─────────────┐
              │  SQLite file · App files │
              └──────────────────────────┘

Platform services (notifications, share, contacts, biometrics)
are wrapped behind small interfaces so the domain layer stays testable.
```

**Principles**
1. The domain layer is pure Dart and fully unit-testable (no BuildContext, no plugins).
2. Repositories expose `Stream`s for lists and dashboards so the UI updates reactively.
3. All multi-row writes (payment plus allocations plus receipt number) run in a single database transaction.
4. Platform plugins are wrapped in interfaces and injected through Riverpod, which makes mocking trivial.

---

## 4. Project Structure

Feature-first layout with shared core:

```
lib/
├── main.dart
├── app.dart                     # MaterialApp.router, theme, locale
├── core/
│   ├── db/
│   │   ├── app_database.dart    # Drift database, migrations
│   │   ├── tables/              # Table definitions
│   │   └── daos/
│   ├── money/                   # Money type, formatting, parsing
│   ├── dates/                   # LocalDate helpers, month math
│   ├── i18n/                    # Bangla digits, plural/format helpers
│   ├── platform/                # Interfaces + impls: notifier, sharer, launcher
│   ├── settings/                # Typed settings store
│   ├── theme/
│   └── utils/
├── features/
│   ├── students/   (data/ domain/ presentation/)
│   ├── batches/
│   ├── attendance/
│   ├── fees/
│   ├── reminders/
│   ├── dashboard/
│   ├── reports/
│   ├── backup/
│   ├── receipts/
│   └── settings/
├── l10n/
│   ├── app_bn.arb
│   └── app_en.arb
└── router.dart
assets/
├── fonts/                       # Noto Sans Bengali / Hind Siliguri (regular, medium, bold)
└── sample_data/
test/
├── fee_engine/
├── attendance/
├── backup/
└── migrations/
integration_test/
```

---

## 5. Core Types

### 5.1 Money

Store whole taka as `int` (tutors rarely need paisa). If paisa is ever required, change the unit in one place.

```dart
extension type const Taka(int value) {
  Taka operator +(Taka o) => Taka(value + o.value);
  Taka operator -(Taka o) => Taka(value - o.value);
  bool get isZero => value == 0;
}
```

Never use `double` for money. Percentage discounts use integer math with explicit rounding:

```dart
int applyPercent(int amount, int percent) => (amount * percent / 100).round();
```

### 5.2 Dates

Date-only fields (due date, joined date, payment date) are stored as `TEXT` in `YYYY-MM-DD`. A `YearMonth` value type represents months:

```dart
class YearMonth implements Comparable<YearMonth> {
  final int year, month;
  const YearMonth(this.year, this.month);
  YearMonth next() => month == 12 ? YearMonth(year + 1, 1) : YearMonth(year, month + 1);
  String toKey() => '$year-${month.toString().padLeft(2, '0')}';
  // compareTo, ==, hashCode omitted
}
```

Timestamps (`created_at`, `updated_at`) are stored as UTC epoch milliseconds. Date-only values never pass through `DateTime` conversions that could shift them across midnight. Use a `LocalDate` helper that is constructed from year, month and day.

### 5.3 Identifiers
UUID v4 strings as primary keys. This keeps backups merge-friendly and leaves the door open to future sync.

---

## 6. Database Design

### 6.1 Drift Configuration
- Native SQLite via `drift` with `NativeDatabase` in a background isolate (`NativeDatabase.createInBackground`) so queries never block the UI thread.
- Enable `PRAGMA foreign_keys = ON` in `beforeOpen`.
- Enable WAL mode for better write concurrency and crash safety.
- Schema version stored via Drift's `schemaVersion`.

### 6.2 Table Definitions (SQL view)

```sql
CREATE TABLE students (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  class_level   TEXT,
  school        TEXT,
  guardian_name TEXT,
  guardian_phone TEXT,
  student_phone TEXT,
  address       TEXT,
  photo_path    TEXT,
  subjects      TEXT,                      -- JSON array
  joined_on     TEXT NOT NULL,             -- YYYY-MM-DD
  status        TEXT NOT NULL DEFAULT 'active',  -- active|paused|left
  monthly_fee   INTEGER NOT NULL,          -- taka
  fee_due_day   INTEGER NOT NULL DEFAULT 10,
  notes         TEXT,
  created_at    INTEGER NOT NULL,
  updated_at    INTEGER NOT NULL
);
CREATE INDEX idx_students_status ON students(status);
CREATE INDEX idx_students_name   ON students(name COLLATE NOCASE);

CREATE TABLE batches (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  subject       TEXT,
  class_level   TEXT,
  schedule_days TEXT NOT NULL,             -- JSON [1,3,5] ISO weekdays
  start_time    TEXT,                      -- HH:mm
  duration_min  INTEGER,
  default_fee   INTEGER NOT NULL DEFAULT 0,
  status        TEXT NOT NULL DEFAULT 'active',
  created_at    INTEGER NOT NULL,
  updated_at    INTEGER NOT NULL
);

CREATE TABLE batch_members (
  id           TEXT PRIMARY KEY,
  batch_id     TEXT NOT NULL REFERENCES batches(id),
  student_id   TEXT NOT NULL REFERENCES students(id),
  fee_override INTEGER,
  joined_on    TEXT NOT NULL,
  left_on      TEXT,
  UNIQUE (batch_id, student_id)
);

CREATE TABLE class_sessions (
  id          TEXT PRIMARY KEY,
  batch_id    TEXT REFERENCES batches(id),
  student_id  TEXT REFERENCES students(id),   -- one-to-one classes
  date        TEXT NOT NULL,
  start_time  TEXT,
  status      TEXT NOT NULL DEFAULT 'held',   -- held|cancelled|holiday
  topic       TEXT,
  note        TEXT,
  CHECK (batch_id IS NOT NULL OR student_id IS NOT NULL)
);
CREATE INDEX idx_sessions_date ON class_sessions(date);
CREATE UNIQUE INDEX uq_session_batch_day
  ON class_sessions(batch_id, date, start_time) WHERE batch_id IS NOT NULL;
CREATE UNIQUE INDEX uq_session_student_day
  ON class_sessions(student_id, date, start_time) WHERE student_id IS NOT NULL;

CREATE TABLE attendance (
  id          TEXT PRIMARY KEY,
  session_id  TEXT NOT NULL REFERENCES class_sessions(id) ON DELETE CASCADE,
  student_id  TEXT NOT NULL REFERENCES students(id),
  status      TEXT NOT NULL,                 -- present|absent|late|excused
  UNIQUE (session_id, student_id)
);
CREATE INDEX idx_att_student ON attendance(student_id);

CREATE TABLE fee_records (
  id          TEXT PRIMARY KEY,
  student_id  TEXT NOT NULL REFERENCES students(id),
  month       TEXT NOT NULL,                 -- YYYY-MM
  kind        TEXT NOT NULL DEFAULT 'monthly',  -- monthly|one_time
  label       TEXT,                          -- for one_time fees
  amount_due  INTEGER NOT NULL,
  discount    INTEGER NOT NULL DEFAULT 0,
  waived      INTEGER NOT NULL DEFAULT 0,
  due_date    TEXT NOT NULL,
  created_at  INTEGER NOT NULL
);
CREATE UNIQUE INDEX uq_fee_monthly
  ON fee_records(student_id, month) WHERE kind = 'monthly';
CREATE INDEX idx_fee_month ON fee_records(month);

CREATE TABLE payments (
  id          TEXT PRIMARY KEY,
  student_id  TEXT NOT NULL REFERENCES students(id),
  amount      INTEGER NOT NULL CHECK (amount > 0),
  received_on TEXT NOT NULL,
  method      TEXT NOT NULL DEFAULT 'cash',
  reference   TEXT,
  receipt_no  INTEGER NOT NULL UNIQUE,
  note        TEXT,
  created_at  INTEGER NOT NULL,
  deleted_at  INTEGER
);
CREATE INDEX idx_pay_student ON payments(student_id);
CREATE INDEX idx_pay_date    ON payments(received_on);

CREATE TABLE payment_allocations (
  id            TEXT PRIMARY KEY,
  payment_id    TEXT NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  fee_record_id TEXT REFERENCES fee_records(id),   -- NULL = unapplied advance credit
  student_id    TEXT NOT NULL REFERENCES students(id),
  amount        INTEGER NOT NULL CHECK (amount > 0)
);
CREATE INDEX idx_alloc_fee ON payment_allocations(fee_record_id);

CREATE TABLE fee_changes (
  id              TEXT PRIMARY KEY,
  student_id      TEXT NOT NULL REFERENCES students(id),
  effective_month TEXT NOT NULL,
  new_amount      INTEGER NOT NULL,
  UNIQUE (student_id, effective_month)
);

CREATE TABLE pauses (
  id          TEXT PRIMARY KEY,
  student_id  TEXT NOT NULL REFERENCES students(id),
  from_month  TEXT NOT NULL,
  to_month    TEXT                              -- NULL = open-ended
);

CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);

CREATE TABLE message_templates (
  id TEXT PRIMARY KEY, kind TEXT NOT NULL, language TEXT NOT NULL, body TEXT NOT NULL
);

CREATE TABLE audit_log (
  id TEXT PRIMARY KEY, entity TEXT NOT NULL, entity_id TEXT NOT NULL,
  action TEXT NOT NULL, details TEXT, at INTEGER NOT NULL
);
```

**Notes**
- Partial unique indexes enforce "one monthly due per student per month" and make due generation idempotent.
- `payments.deleted_at` provides soft delete so the receipt number sequence and the audit trail stay intact.
- `fee_record_id = NULL` in an allocation represents unapplied advance credit. See section 7.3.
- Exams, results, homework and syllabus tables are added by migration in later releases.

### 6.3 Derived Balance Queries

```sql
-- Outstanding per fee record
SELECT f.id, f.student_id, f.month,
       (f.amount_due - f.discount) AS payable,
       COALESCE(SUM(a.amount), 0)  AS paid,
       CASE WHEN f.waived = 1 THEN 0
            ELSE (f.amount_due - f.discount) - COALESCE(SUM(a.amount), 0) END AS balance
FROM fee_records f
LEFT JOIN payment_allocations a ON a.fee_record_id = f.id
LEFT JOIN payments p ON p.id = a.payment_id AND p.deleted_at IS NULL
GROUP BY f.id;
```

(The implementation must filter allocations of soft-deleted payments consistently; see section 7.5.)

Expose this as a Drift view (`CREATE VIEW fee_balances`) so every screen reads from one definition. Due list, student profile and reports all query the view.

### 6.4 Migrations
- Increment `schemaVersion` for every change; write a step-by-step `onUpgrade` using Drift's `Migrator` and stepwise migration helpers.
- Keep migration tests: open a database fixture from each previous version and verify upgrade results (`drift_dev schema` export and `SchemaVerifier`).
- Take an automatic file-level snapshot of the database before running a migration, and keep it until the next successful launch.

---

## 7. Fee Engine (Core Domain Logic)

The fee engine is pure Dart, with no database or Flutter imports. The repository layer feeds it data and persists its output.

### 7.1 Due Generation

**Trigger points:** app start, app resume after a date change, student creation, fee change, unpausing. Generation is **lazy and idempotent**, not scheduled in the background.

```dart
List<FeeRecordDraft> generateDues({
  required Student student,
  required List<FeeChange> changes,
  required List<Pause> pauses,
  required Set<YearMonth> existing,
  required YearMonth upTo,           // usually the current month
  required ProrationRule rule,
}) {
  final drafts = <FeeRecordDraft>[];
  var m = YearMonth.from(student.joinedOn);
  while (m <= upTo) {
    if (!existing.contains(m) && !isPaused(m, pauses) && student.activeIn(m)) {
      final base = feeFor(m, student, changes);          // latest change effective <= m
      final amount = (m == YearMonth.from(student.joinedOn))
          ? prorate(base, student.joinedOn, rule)
          : base;
      drafts.add(FeeRecordDraft(
        studentId: student.id,
        month: m,
        amountDue: amount,
        dueDate: dueDateFor(m, student.feeDueDay),       // clamp to month length
      ));
    }
    m = m.next();
  }
  return drafts;
}
```

Rules:
- `feeFor` picks the `FeeChange` with the greatest `effective_month <= m`; if none, uses the student's original fee. (Store the initial fee as the first `fee_changes` row to keep this uniform.)
- If the batch membership has a `fee_override`, it takes precedence over the student's base fee for that batch.
- `dueDateFor` clamps day 31 to the last day of shorter months.
- `student.activeIn(m)`: false for months after the student's `left` month.
- Insert with `INSERT OR IGNORE` so concurrent triggers cannot create duplicates.

### 7.2 Proration
Three modes (setting):
1. `fullMonth` (default): charge the full fee.
2. `byDays`: `round(base * remainingDays / daysInMonth)`, where `remainingDays` includes the joining day.
3. `nextMonth`: no due for the joining month.

### 7.3 Payment Allocation

Allocation turns "a payment of X taka" into a list of `(fee_record, amount)` pairs.

```dart
sealed class AllocationTarget {}
class OldestFirst extends AllocationTarget {}
class SpecificMonths extends AllocationTarget { final List<YearMonth> months; ... }

List<AllocationLine> allocate({
  required int paymentAmount,
  required List<OpenDue> openDues,     // sorted by month ascending, balance > 0
  required AllocationTarget target,
}) {
  final lines = <AllocationLine>[];
  var remaining = paymentAmount;
  final ordered = switch (target) {
    OldestFirst() => openDues,
    SpecificMonths(:final months) =>
        [...openDues.where((d) => months.contains(d.month)),
         ...openDues.where((d) => !months.contains(d.month))],
  };
  for (final due in ordered) {
    if (remaining == 0) break;
    final applied = min(remaining, due.balance);
    lines.add(AllocationLine(feeRecordId: due.id, amount: applied));
    remaining -= applied;
  }
  if (remaining > 0) {
    lines.add(AllocationLine(feeRecordId: null, amount: remaining)); // advance credit
  }
  return lines;
}
```

**Advance credit:** allocations with `fee_record_id = NULL` represent unapplied credit. When new dues are generated for a student, a post-step `applyCredit(studentId)` converts credit into allocations against the new dues (oldest first), preserving the original payment link. Credit balance = sum of NULL-target allocations on non-deleted payments, minus the amounts later converted.

To keep this simple and auditable, implement credit conversion as: *delete the NULL allocation row and insert real allocation rows for the same payment*, inside one transaction.

### 7.4 Recording a Payment (Transaction)

```dart
Future<Payment> recordPayment(PaymentInput input) {
  return db.transaction(() async {
    final dues = await feeDao.openDuesFor(input.studentId);
    final lines = allocate(
      paymentAmount: input.amount,
      openDues: dues,
      target: input.target,
    );
    final receiptNo = await settings.nextReceiptNumber();   // read+increment inside tx
    final payment = await paymentDao.insert(input, receiptNo);
    await allocationDao.insertAll(payment.id, input.studentId, lines);
    await auditDao.log('payment', payment.id, 'create');
    return payment;
  });
}
```

### 7.5 Editing and Deleting Payments
- **Delete:** set `deleted_at`, then delete that payment's allocation rows (so balances revert). Log to `audit_log`. Receipt number is never reused.
- **Edit:** implemented as *delete allocations, update payment fields, re-run allocation* within one transaction. If the amount shrinks, dues re-open; if it grows, the extra goes to the next dues or advance credit.
- Show a warning if a receipt for this payment was previously shared.
- Because balances derive from allocations, no balance column ever needs "fixing".

### 7.6 Status Derivation

```dart
FeeStatus statusOf(FeeRecordView r, LocalDate today) {
  if (r.waived) return FeeStatus.waived;
  if (r.balance == 0) return FeeStatus.paid;
  if (r.paid > 0 && today <= r.dueDate) return FeeStatus.partial;
  return today > r.dueDate ? FeeStatus.overdue : FeeStatus.due;
}
```

Status is always computed at read time from balance and today's date; it is never stored.

### 7.7 Fee Engine Test Matrix (must pass before release)

| Case | Expectation |
|---|---|
| Join on the 1st, 15th, 31st with each proration mode | Correct amount |
| Fee change mid-year | Old dues unchanged, new dues use new fee |
| Fee change effective in the past | Existing dues untouched; only missing dues use the new fee |
| Payment exact, partial, multi-month, over-payment | Correct allocations and credit |
| Payment targeted at a specific month while older dues exist | Targeted first, remainder to oldest |
| Edit payment amount up and down | Balances consistent |
| Delete payment | Dues re-open; receipt number not reused |
| Pause and resume | No dues during pause |
| Due day 31 in February | Clamped to 28/29 |
| Running generation twice | No duplicates |
| Advance credit then new due generated | Credit auto-applied |
| Waived month with a payment | Payment becomes credit or is rejected, per product rule |

---

## 8. Attendance Design

### 8.1 Session Materialization
Sessions are **not** pre-generated far into the future. Instead:

- The Today screen computes "expected sessions" for a date from batch schedules and student class days.
- A `class_sessions` row is created only when the tutor opens attendance for that class, or marks it cancelled or holiday.
- Past dates with no row are treated as "not recorded" in reports (distinct from "absent").

```dart
List<ExpectedSession> expectedFor(LocalDate date) {
  final weekday = date.isoWeekday;
  return [
    ...batches.where((b) => b.status.isActive && b.scheduleDays.contains(weekday)),
    ...oneToOneStudents.where((s) => s.classDays.contains(weekday)),
  ].map(ExpectedSession.from).toList();
}
```

Join expected sessions with existing rows to show state: Not taken, Taken, Cancelled.

### 8.2 Marking Flow
- Default all enrolled students to Present in the UI; persist only on Save.
- Save writes the session row plus one attendance row per student in one transaction (`INSERT ... ON CONFLICT DO UPDATE` for re-edits).
- Enrolled students for a past session are those whose `batch_members` interval covers the date.

### 8.3 Aggregations
Monthly percentage = `(present + late) / (held sessions - excused)` for that student, computed in SQL with grouped counts. Index on `attendance(student_id)` and `class_sessions(date)` keeps this fast.

---

## 9. Reminders and Notifications

### 9.1 Notification Types

| Type | Schedule | Content |
|---|---|---|
| Class reminder | N minutes before each scheduled class | "Class: Math, Class 9 (5:00 PM)" |
| Fee due (tutor-facing) | Morning of each student's due day, grouped | "3 students have fees due today" |
| Weekly dues summary | Weekly at chosen time | Total outstanding |
| Backup reminder | When last backup is older than N days | Prompt to export |

### 9.2 Scheduling Strategy
Android limits pending alarms and repeating exact alarms behave poorly across OEMs. Use a **rolling window**:

1. A `ReminderPlanner` computes all notifications for the next **14 days** from current data.
2. It cancels all previously scheduled app notifications and schedules the new set (stable ID scheme: hash of type + target + date).
3. It re-runs on: app start, app resume, any change to students, batches, schedules or settings, and after boot.
4. Because the window is rolling, a user who rarely opens the app still gets up to two weeks of reminders. Add a "last refreshed" safeguard: if the window is nearly empty, a final notification says "Open the app to keep reminders on".

Daily "fee due" notifications are grouped into one per day to avoid spam.

### 9.3 Android Specifics

- Use the `timezone` package with `Asia/Dhaka` as the default location (set via `tz.setLocalLocation`).
- Android 13+: request `POST_NOTIFICATIONS` at the point the user enables reminders, with a rationale screen first.
- Android 12+: exact alarms require `SCHEDULE_EXACT_ALARM` (user-granted) or `USE_EXACT_ALARM` (for calendar-like apps, subject to Play policy). For this app, prefer **inexact** alarms (`AndroidScheduleMode.inexactAllowWhileIdle`) as the default, since a few minutes of drift is acceptable, and offer exact mode as a settings option.
- Declare `RECEIVE_BOOT_COMPLETED` and register the plugin's boot receiver so notifications are restored after reboot.
- Show a one-time guide for OEM battery restrictions (Xiaomi, Oppo, Vivo, Realme, Samsung) with deep links to the relevant settings screens where possible.
- Notification tap payload encodes a route (for example `/attendance/today?batch=<id>`); `go_router` resolves it on launch.

### 9.4 Message Composer (Guardian Reminders)

```dart
String composeFeeReminder({
  required MessageTemplate template,
  required Student student,
  required YearMonth month,
  required int balance,
  required Locale locale,
}) {
  return template.body
      .replaceAll('{student}', student.name)
      .replaceAll('{month}', formatMonth(month, locale))
      .replaceAll('{amount}', formatTaka(balance, locale))
      .replaceAll('{due}', formatDate(dueDate, locale));
}
```

Sending:
- **SMS:** `sms:<number>?body=<urlencoded>` through `url_launcher` (Android uses `?body=`).
- **WhatsApp:** `https://wa.me/<E164 number without +>?text=<urlencoded>`. Normalize numbers: strip spaces and dashes, convert `01XXXXXXXXX` to `8801XXXXXXXXX`.
- The app only opens the compose screen; the user taps send. No SMS permission needed.

---

## 10. Backup and Restore

### 10.1 Backup File Format

A single `.tkbackup` file (a renamed ZIP):

```
backup_2026-10-06_1630.tkbackup
├── manifest.json
├── data.db            # consistent SQLite snapshot
└── photos/
    ├── <studentId>.jpg
    └── ...
```

`manifest.json`:
```json
{
  "format": "tuition-khata-backup",
  "format_version": 1,
  "schema_version": 3,
  "app_version": "1.0.0",
  "created_at": "2026-10-06T16:30:00+06:00",
  "counts": { "students": 42, "payments": 311, "sessions": 1180 },
  "db_sha256": "…",
  "encrypted": false
}
```

### 10.2 Export Procedure
1. Run `VACUUM INTO '<tmp>/data.db'` to produce a consistent snapshot without stopping the app.
2. Copy referenced photos.
3. Write `manifest.json` with counts and SHA-256 of the DB.
4. Zip with the `archive` package in an isolate (avoid UI jank).
5. Optionally encrypt (AES-GCM via `cryptography` package; key derived from a user password with PBKDF2 or Argon2; salt and nonce stored in the file header).
6. Hand the file to the share sheet; record `last_backup_at` in settings.

### 10.3 Restore Procedure
1. User picks a file (`file_picker`).
2. Unzip to a temp directory; read `manifest.json`.
3. Validate: format name, `schema_version <= app's schemaVersion` (reject newer), checksum matches.
4. Open the snapshot read-only; run `PRAGMA integrity_check` and compute preview counts.
5. Show a preview: students, payments, latest payment date, backup date. Warn that current data will be replaced.
6. **Safety snapshot:** copy the current database to `pre_restore_<timestamp>.db` in app storage.
7. Close the active database, replace the DB file, copy photos, reopen the database (Drift runs migrations if the snapshot is older).
8. Rebuild reminders, regenerate dues up to the current month, and refresh providers.
9. If anything fails, restore the safety snapshot automatically and show a clear error.

### 10.4 Auto-Backup (v1.1)
- User picks a folder via the Android Storage Access Framework (persisted URI permission).
- A backup is written on app open if the interval has elapsed, keeping the last N files.
- Avoid background workers in v1; opportunistic backup on open is simple and reliable.

### 10.5 Receipt Number Continuity
`next_receipt_no` is stored in `settings` and also derived as `MAX(receipt_no) + 1` on restore, so numbering never goes backward after a restore.

---

## 11. Localization and Bangla Support

- ARB files: `app_bn.arb` (primary) and `app_en.arb`. Use `flutter gen-l10n`.
- Bundle **Noto Sans Bengali** (or Hind Siliguri) in 400/500/700 weights; subset if APK size matters. Do not rely on system fonts, because many low-end devices render conjuncts poorly.
- A `NumberFormatter` layer converts digits to Bangla (০১২৩৪৫৬৭৮৯) based on a user setting. Use it for money, dates, counts and phone display.
- Taka formatting: `৳ ১২,৫০০` or `৳ 12,500`. Bangladesh commonly groups digits in lakh/crore style (`১,২৫,০০০`); make the grouping style a formatter option.
- Search must handle both scripts: normalize input (NFC) and match case-insensitively; consider a simple transliteration index (optional, v1.1) so English-typed names find Bangla entries.
- Sorting names uses a locale-aware collator (`bn`) for Bangla strings.
- Month and weekday names come from `intl` with `bn` locale data; verify glyph rendering on Android 7 devices.
- PDF receipts must embed the same Bangla font and be tested with long names and conjunct-heavy text.
- Avoid hard-coded strings in code; keep all UI text in ARB files from the first screen.

---

## 12. State Management Patterns

- **Providers:** `databaseProvider`, repository providers, service providers (fee engine, planner), platform-wrapper providers.
- **Lists and dashboards** use `StreamProvider` backed by Drift `watch()` queries, so the UI updates on any write.
- **Commands** (record payment, save attendance) live in `Notifier` classes that call use cases and surface `AsyncValue` state for loading and error UI.
- **Form state** is local to the screen (hooks or `Notifier.autoDispose`) and validated by pure functions that are unit-tested.
- **App-level state:** locale, theme, app lock status, "needs backup" banner.
- Keep widgets dumb; business rules belong in the domain layer.

Example dashboard query (reactive):

```dart
final monthSummaryProvider = StreamProvider.family<MonthSummary, YearMonth>((ref, m) {
  return ref.watch(feeRepositoryProvider).watchMonthSummary(m);
});
```

---

## 13. Performance Plan

| Area | Approach |
|---|---|
| Startup | Initialize the DB lazily, defer plugin setup (notifications, contacts) until after first frame; target under 2 s cold start on 2 GB devices |
| Lists | `ListView.builder`, fixed item extents where possible, pagination at around 50 rows for payment history |
| DB | Index every foreign key and filter column; use views for balances; run queries in the Drift background isolate |
| Images | Compress photos on import (max about 512 px, JPEG quality about 75); use `cacheWidth` when rendering |
| Rebuilds | Fine-grained providers with `select`; `const` widgets |
| Isolates | Backup zipping, PDF rendering, CSV export |
| APK size | Build with `--split-per-abi` and `--obfuscate`/`--split-debug-info`; subset fonts; avoid large asset bundles; target under 25 MB |
| Animations | Minimal; respect the system "reduce animations" setting |

Profile on a real low-end device (for example 2 GB RAM, Android 8 or 9) using Flutter DevTools before each release. Seed a stress dataset (500 students, 20,000 attendance rows, 6,000 payments) to verify list and report performance.

---

## 14. Security and Privacy

| Topic | Design |
|---|---|
| Data location | App-private storage; not accessible to other apps |
| Network | App requests no `INTERNET` permission in v1 (strong privacy statement, and rules out accidental data leakage). Add it only when a feature needs it |
| App lock | PIN (hashed with salt in secure storage) and optional biometric via `local_auth`; auto-lock after a timeout; blur app content in the recents screen using `FLAG_SECURE` as an option |
| Database encryption | Optional SQLCipher build (v1.1); weigh the APK size and complexity cost against the benefit |
| Backups | Optional password encryption; warn users that unencrypted backups contain student and guardian data |
| Permissions | Request contacts, notifications and storage only when the feature is used; handle denial gracefully |
| Logging | No student data in logs; strip debug logging in release builds |
| Crash reporting | Play Console vitals only; no third-party SDKs that transmit data in v1 |
| Photos | Stored inside app storage, excluded from the device gallery |

Provide an in-app privacy note: "Your data stays on this phone. Back it up regularly."

---

## 15. Error Handling and Data Integrity

- All writes through repositories inside transactions; no partial updates.
- Domain functions return typed results (sealed `Result`/error classes) for expected failures such as validation errors or insufficient data; exceptions are for programming errors.
- Global error handler (`FlutterError.onError`, `PlatformDispatcher.onError`) writes to a local rotating log file, viewable in Settings, shareable by the user when reporting bugs.
- Database `CHECK` and `UNIQUE` constraints act as a second line of defense against logic bugs.
- A **consistency checker** (developer setting, also run after restore) verifies: every allocation points to an existing non-deleted payment; allocation sums per payment equal the payment amount; no negative balances; one monthly due per student per month.
- Destructive actions (delete student, delete payment, delete all data, restore) always create a safety snapshot first and show an undo window where practical.

---

## 16. Testing Strategy

| Level | Scope | Tooling |
|---|---|---|
| Unit | Fee engine, proration, allocation, status derivation, month math, phone normalization, message composer, Bangla number formatting | `flutter_test` |
| DAO / DB | Queries, views, unique constraints, transactions, using in-memory Drift | `drift` test utilities |
| Migration | Upgrade from each historical schema version with realistic data | Drift `SchemaVerifier` |
| Backup | Export then restore round trip equals original; corrupted file; newer schema; wrong password | Unit plus integration |
| Widget | Key screens (attendance sheet, record payment, due list) in Bangla and English, large font scale | `flutter_test` golden tests (selective) |
| Integration | Core flows A to E from the spec on an emulator | `integration_test` |
| Device | Low-end phones, Android 7 to 14, OEM battery managers, notification delivery after reboot | Manual checklist |
| Property-based (optional) | Random payment sequences: balances never negative, allocations always sum to payment amount | `glados` or custom generator |

**Release gate:** all fee-engine and migration tests green; backup round-trip test green; manual run of the device checklist.

---

## 17. Build, Release and Operations

- **Flavors:** `dev` (sample-data tools, debug menu) and `prod`.
- **CI (GitHub Actions):** analyze, format check, unit and DB tests, build an APK artifact on every push to main.
- **Signing:** keep the upload key and keystore backed up offline; enable Play App Signing.
- **Versioning:** semantic version plus build number; keep the database schema version and backup format version in a documented table.
- **Distribution:** Play Store internal testing, then closed beta with 10 to 20 real tutors, then production. Also publish a direct APK for users without Play access (sign with the same key).
- **Crash and quality signals:** Play Console Android vitals; in-app "Send feedback" opening WhatsApp or email with an optional diagnostic log attached by the user.
- **Update safety:** the first launch after an update runs migrations behind a snapshot; if migration fails, restore the snapshot and show a recovery screen with an export-raw-database option.

---

## 18. Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Users lose their phone and have no backup | Total data loss | Prominent backup reminders, auto-backup to a folder, simple share-to-WhatsApp flow |
| Notifications silently suppressed by OEM battery managers | Missed reminders, loss of trust | Rolling window scheduling, one-time OEM guide, in-app "reminder health" check |
| Fee logic bugs corrupt balances | Financial disputes | Derived balances, constraints, consistency checker, extensive tests, audit log |
| Bangla rendering issues on old devices | Poor first impression | Bundle fonts, test on Android 7 to 9 devices |
| Schema changes break old backups | Failed restores | Versioned backup format, forward migrations, restore preview and safety snapshot |
| Unencrypted backups shared over WhatsApp | Privacy exposure | Optional password protection, clear warning text |
| Play policy on exact alarms and permissions | Rejection | Default to inexact alarms, request permissions contextually, no SMS or call-log permissions |
| Scope creep (exams, homework, per-class billing) | Delay | Strict MVP boundary from the spec; later releases add tables through migrations |

---

## 19. Implementation Order (Suggested)

1. Project scaffold, theme, localization, Bangla font, router, Riverpod setup.
2. Drift schema v1, DAOs, in-memory test harness, migration scaffolding.
3. Core types: money, dates, year-month, phone normalization, Bangla formatters (with tests).
4. Students and batches (CRUD, search, profile).
5. Fee engine: due generation, allocation, status (tests first), then payment screens and due list.
6. Attendance: expected sessions, marking sheet, calendar, summaries.
7. Dashboard and monthly report.
8. Reminder planner and notifications, message composer, SMS and WhatsApp launch.
9. Backup and restore with safety snapshots, consistency checker.
10. Settings, app lock, polish, accessibility pass, low-end device profiling.
11. Closed beta, fixes, release.

Building the fee engine and its tests before the payment UI gives the riskiest logic the longest time to be exercised.

---

## 20. Open Technical Decisions

1. **Drift vs Isar:** this design assumes Drift for relational queries and views. Choose Isar only if you prefer an object-store model and are willing to hand-write aggregates.
2. **Whole taka vs paisa:** whole taka is simpler; switch only if fractional fees are a real requirement.
3. **Inexact vs exact alarms:** inexact is the default here; confirm that a few minutes of drift is acceptable for class reminders.
4. **Database encryption in v1 or v1.1:** SQLCipher adds size and build complexity; decide based on how sensitive early users consider the data.
5. **INTERNET permission:** omitted in v1 for privacy; revisit if you add Drive backup or any remote feature.
6. **Credit handling for waived months:** reject the payment, or convert the amount to credit? Needs a product decision (see the fee test matrix).
7. **Search transliteration:** include in v1 or defer.
