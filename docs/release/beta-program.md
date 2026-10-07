# Closed beta (S5-08)

Goal: find what real tutors trip over, and any data-loss bug, before release. The
beta is people and time, not code: this is the plan and the kit.

## Who and how long

- **10 to 20 tutors**, mixed: some with one-to-one students only, some with batches
  of 15+; some with very cheap 2 GB phones; at least two phone makers from
  Xiaomi/Oppo/Vivo/Realme/Samsung; at least three who prefer Bangla digits and one
  who prefers English.
- **7 days**, ideally spanning a month change (fees are generated on the 1st) or
  using a month-end for fee collection.
- Recruit through a WhatsApp group (one group, announcements only for you, replies
  welcome). Install with the direct APK (`install-apk.md`) or the Play internal /
  closed testing track.
- Ask every tester to load **their real students** (not the sample), take
  attendance for real classes, record real payments and send at least one real
  reminder.

## Message to send (Bangla)

> আসসালামু আলাইকুম। আমি “টিউশন খাতা” নামে প্রাইভেট শিক্ষকদের জন্য একটি অ্যাপ বানিয়েছি: শিক্ষার্থী, হাজিরা, ফি ও রসিদ, সব ফোনেই, ইন্টারনেট ছাড়া। ৭ দিন ব্যবহার করে আপনার মতামত দিলে খুব উপকার হবে।
> ১) এই ফাইলটি (APK) ইনস্টল করুন  ২) আপনার আসল শিক্ষার্থীদের যোগ করুন  ৩) ৭ দিন হাজিরা ও ফি এখানে রাখুন  ৪) **প্রথম দিনেই** সেটিংস › ব্যাকআপ নিন
> কিছু ভুল বা বিরক্তিকর লাগলে এই গ্রুপে লিখুন বা ফর্মটি পূরণ করুন: [ফর্মের লিংক]। ধন্যবাদ।

## Feedback form (a Google Form is enough)

1. Name and phone model, Android version (optional but valuable).
2. How many students and batches did you add?
3. Which did you use? (attendance, payments, receipts, guardian reminders,
   reports, backup, reminders, app lock)
4. Time to take attendance for your biggest class (seconds, roughly).
5. Did any number look **wrong**? What did you expect? (screenshot welcome)
6. Did you lose or have to re-enter anything?
7. Did class/fee reminders arrive on time? Did they arrive after restarting the phone?
8. What was confusing, slow or ugly? Any Bangla that reads wrong?
9. What is the one thing you missed most?
10. Would you use it for next month? Would you pay? (how much)
11. May we contact you?

## Severity and what happens

| Level | Meaning | Example | Action |
|---|---|---|---|
| **P0** | Data loss or wrong money | A payment disappears; due list disagrees with reports; restore loses data | Stop the beta for affected builds, fix first, **no release with an open P0** |
| **P1** | Feature broken or very hard to use | Reminders never arrive on a phone maker; crash on a screen | Fix before release |
| **P2** | Annoying or confusing | Wording, layout on a small phone | Fix if cheap, else known-issues |
| **P3** | Wish | New feature | Backlog for v1.1 |

## Daily triage (15 minutes)

1. Read the group and the form responses.
2. Log each distinct item in the tracker below (one row each, with who and phone).
3. Reproduce P0/P1 with the stress data or the tester's backup (ask for it: a
   tester's backup is the best bug report, and **must not leave your hands**:
   delete after use, never share).
4. Reply to the tester within a day, even just "seen".
5. Ship a fix build to the group when a P0/P1 is fixed; say what changed.

## Tracker (copy into a sheet)

| # | Date | Tester / phone | What happened | Level | Reproduced | Fixed in build | Verified by tester |
|---|---|---|---|---|---|---|---|

## Exit criteria

- Feedback logged and prioritised; every P0 and P1 fixed and verified, or
  consciously deferred with a note in `known-issues.md`.
- **No open data-loss bug.**
- At least 5 testers still using it on day 7.
- At least two testers restored a backup successfully (ask them to try it on day 6).
- Reminders confirmed working on at least two phone makers.
- Then S5-09: fix buffer, final regression (`flutter test`, the smoke test in
  `release-checklist.md`), release candidate approved by that checklist.
