# Performance (S5-03)

Budgets from the spec: cold start under 2 s on a 2 GB phone, lists at 60 fps with
500 students, reports under 1 s.

## What is measured automatically

`test/perf/` seeds the **stress dataset** (`test/support/stress_data.dart`):
500 students in 25 batches, 7,000 fee records, **6,000 payments** with allocations,
**20,000 attendance marks**, 1,000 sessions, the receipt counter. It checks that
the dataset is consistent, then times each screen's queries. The thresholds are a
fraction of the real budget because a CI machine is much faster than a 2 GB phone;
crossing them would be felt on the phone.

Measured on a development machine (milliseconds):

| What | Time | Limit in test |
|---|---|---|
| Due list (Fees tab) | ~95 | 150 |
| Student list / search | 15 / 6 | 150 |
| Home: month summary, owing, upcoming dues | 4, 11, 6 | 100 |
| Monthly report: batch breakdown | ~46 | 300 |
| 12-month income | 5 | 150 |
| A student's attendance month, calendar | 2, 4 | 100 |
| Today's classes (rules + sessions) | 8 | 100 |
| Generating dues at app start (steady state) | **4** (was ~1000) | 100 |
| Consistency check | ~20 | 1500 |
| Cold start: open the file DB, Home queries | 8, 50 | 200, 400 |

Also checked: every hot query uses an index (`EXPLAIN QUERY PLAN` shows no full scan
of `fee_records`, `payments`, `class_sessions`, `attendance` for per-student,
per-day, per-date-range and per-session lookups), and the Students and Fees lists
build only the rows on screen (500 students, fewer than 40 tiles built). No index
was missing, so there was no schema change.

## What the pass found and fixed

- **App start was slow with many students.** Due generation ran several queries per
  student at every start and resume (about 1 s for 500 students on a fast machine,
  likely 10 s or more on a phone, contending with the first screens for the
  database). It now asks one query which students could need dues (no due yet for
  this month, or advance credit to apply) and only works on those: 4 ms.
- The time-zone database for reminders was loading every zone; it now loads the
  smaller 10-year set (which includes Asia/Dhaka).

## Still to do on real hardware (cannot be done from a build server)

Run on a 2 GB Android phone (a Redmi 9A / Realme C-series class device is typical):

1. `flutter run --profile --flavor prod -t lib/main_prod.dart`, then in DevTools
   Performance: scroll the Students list and the Fees list with the stress data
   (load it with the debug seeding or restore a backup of it); frames should stay
   under 16 ms. Note the worst frame.
2. Cold start: `adb shell am start -W -n com.nextgenai.tution_tracker/.MainActivity`
   after `adb shell am force-stop`; `TotalTime` under 2000 ms on a release build.
3. Open Reports with the stress data: under 1 s to a drawn chart.
4. Record the numbers and the device in the release checklist.
