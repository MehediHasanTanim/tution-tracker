# Edge cases (spec section 7): where each is handled and tested (S5-05)

| # | Edge case | Behaviour | Test or verification |
|---|---|---|---|
| 1 | Student joins mid-month | The joining month follows the proration setting (full, by days, from next month). The calculated amount is **shown before saving** in the add-student form (added in Sprint 5; it was missing) | `test/features/fees/due_generation_test.dart`, `due_service_test.dart`; `test/edge_cases/edge_cases_test.dart` (form preview for all three rules) |
| 2 | Fee increases mid-year | `fee_changes` with an effective month; past dues unchanged | `due_generation_test.dart` (fee changes), `fee_matrix_test.dart`, `student_fees_tab_test.dart` |
| 3 | Payment covers several months | Allocated oldest first; the breakdown is shown before and after saving | `allocation_test.dart`, `payment_repository_test.dart`, `record_payment_screen_test.dart` ("breakdown") |
| 4 | Overpayment | Surplus kept as advance credit and applied to the next generated due | `allocation_test.dart`, `payment_repository_test.dart` (credit), `due_service_test.dart` (credit applied) |
| 5 | Payment edited or deleted | Allocations recalculated, audit entry written, warning if a receipt was already shared | `payment_repository_test.dart` (edit, delete, audit), `record_payment_screen_test.dart` (receipt-shared warning), `consistency_checker_test.dart` |
| 6 | Pause then resume | No dues during the pause; resume sets the next due | `due_generation_test.dart` (pauses), `student_repository_test.dart` |
| 7 | Phone date changed | A full-screen **warning** when the date is more than a day behind the last time the app ran (added in Sprint 5; it was missing). Nothing is changed or deleted because of the date; acknowledging accepts the new date | `test/edge_cases/edge_cases_test.dart` (unit and UI, including that data survives and the warning does not repeat) |
| 8 | Phone formats `01XXXXXXXXX`, `+8801XXXXXXXXX`, `8801XXXXXXXXX` | Accepted, normalised for `tel:`, SMS and wa.me links | `test/core/phone_test.dart`, `contact_links_test.dart`, `messaging_ui_test.dart` (wa.me path) |
| 9 | Very long Bangla names | Wrap; never truncated without the full name elsewhere | `test/a11y/audit_test.dart` (70-character name at 1.3x on every screen); receipts: `receipt_screen_test.dart` |
| 10 | Backup restored on an older app | A newer schema or file format is refused with a clear message, nothing touched | `test/features/backup/backup_restore_test.dart` ("newer app version", "newer file format"), `backup_ui_test.dart` |
| 11 | OEM battery managers | One-time guide for Xiaomi, Oppo, Vivo, Realme, Samsung; reminder-health row | `test/features/reminders/reminders_ui_test.dart`. **Real-device behaviour is manual**: see the release checklist |
| 12 | Several classes the same day for a student | More than one session per date; the calendar shows the most telling status; counts include all | `attendance_repository_test.dart` ("classes at different times on one day are separate", "two classes in a day show the most telling status"), `schema_test.dart` |
| 13 | Month with five weeks / irregular classes | The fee is flat; attendance never changes it | `edge_cases_test.dart` (twelve months of dues all equal) |

## Gaps found and fixed in this pass

- Case 1: no preview of the first month's fee. Added, with a test per rule.
- Case 7: no warning at all. Added, tested, never destructive.
- Related finds elsewhere in Sprint 5: due generation cost at start (performance),
  onboarding overflow on a small screen at large font (accessibility), the version
  line using Western digits in Bangla mode.

## Manual verification still needed (cannot be automated here)

- Case 11 on real Xiaomi/Oppo/Vivo/Realme/Samsung phones: that the battery-settings
  deep link opens, and that a reminder set for 2 minutes ahead fires with the screen
  off, after a force-stop of the app, and after a restart.
- Case 7 on a real phone: set the date back 10 days in system settings, reopen the
  app, confirm the warning; set it right again, acknowledge, confirm no data changed.
