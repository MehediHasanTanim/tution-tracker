// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tuition Khata';

  @override
  String get navHome => 'Home';

  @override
  String get navStudents => 'Students';

  @override
  String get navFees => 'Fees';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get sampleConjuncts => 'Sample text';

  @override
  String get studentsSearchHint => 'Search by name, guardian or phone';

  @override
  String get studentsClearSearch => 'Clear';

  @override
  String get studentsFilterClass => 'Class';

  @override
  String get studentsAllClasses => 'All classes';

  @override
  String get studentsFilterBatch => 'Batch';

  @override
  String get studentsAllBatches => 'All batches';

  @override
  String get statusActive => 'Active';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusArchived => 'Archived';

  @override
  String studentsCount(String count) {
    return 'Students: $count';
  }

  @override
  String get studentsEmptyTitle => 'No students yet';

  @override
  String get studentsEmptyBody => 'Add your first student';

  @override
  String get studentsNoMatch => 'No students match';

  @override
  String get studentsClearFilters => 'Clear filters';

  @override
  String get studentsAdd => 'Add student';

  @override
  String get studentProfileTitle => 'Student profile';

  @override
  String studentFeePerMonth(String amount) {
    return '$amount / month';
  }

  @override
  String get studentEditTitle => 'Edit student';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldMonthlyFee => 'Monthly fee (৳)';

  @override
  String get feeLockedHint => 'To change the fee, use fee adjustments';

  @override
  String get moreDetails => 'Add more details';

  @override
  String get fewerDetails => 'Show fewer details';

  @override
  String get fieldDueDay => 'Fee due day (day of month)';

  @override
  String get fieldClassLevel => 'Class';

  @override
  String get fieldSchool => 'School / institution';

  @override
  String get fieldGuardianName => 'Guardian name';

  @override
  String get fieldGuardianPhone => 'Guardian phone';

  @override
  String get fieldStudentPhone => 'Student phone';

  @override
  String get fieldAddress => 'Address / area';

  @override
  String get fieldSubjects => 'Subjects';

  @override
  String get fieldOtherSubject => 'Add another subject';

  @override
  String get fieldJoinedOn => 'Joining date';

  @override
  String get fieldClassDays => 'Class days';

  @override
  String get fieldClassTime => 'Class time';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get actionSave => 'Save';

  @override
  String get actionClear => 'Clear';

  @override
  String get errorNameRequired => 'Enter a name';

  @override
  String get errorFeeRequired => 'Enter the monthly fee';

  @override
  String get errorPhoneInvalid =>
      'Enter a valid mobile number (e.g. 01712345678)';

  @override
  String get studentSaved => 'Student saved';

  @override
  String get none => 'None';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabAttendance => 'Attendance';

  @override
  String get tabFees => 'Fees';

  @override
  String get tabNotes => 'Notes';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get actionCall => 'Call';

  @override
  String get actionSms => 'SMS';

  @override
  String get actionWhatsapp => 'WhatsApp';

  @override
  String get noPhoneNumber => 'No phone number';

  @override
  String get contactLaunchFailed => 'Could not open it. Is the app installed?';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionArchive => 'Archive';

  @override
  String get actionRestore => 'Restore';

  @override
  String get actionDelete => 'Delete permanently';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get deleteStudentTitle => 'Delete student?';

  @override
  String get deleteStudentBody =>
      'All of this student\'s records (fees, payments, attendance) will be erased for good. This cannot be undone. To keep the records, archive instead.';

  @override
  String get studentDeleted => 'Student deleted';

  @override
  String get studentArchived => 'Student archived';

  @override
  String get studentRestored => 'Student restored';

  @override
  String get profileMonthlyFee => 'Monthly fee';

  @override
  String get profileDueDay => 'Fee due day';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get photoChange => 'Change photo';

  @override
  String get photoTake => 'Take photo';

  @override
  String get photoChoose => 'Choose from gallery';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get photoFailed => 'Could not use that photo';

  @override
  String get tabAllStudents => 'All students';

  @override
  String get tabBatches => 'Batches';

  @override
  String get batchesAdd => 'Add batch';

  @override
  String get batchEditTitle => 'Edit batch';

  @override
  String get batchesEmptyTitle => 'No batches yet';

  @override
  String get batchesEmptyBody => 'Create your first batch';

  @override
  String get batchShowArchived => 'Show archived';

  @override
  String get batchFieldName => 'Batch name';

  @override
  String get batchFieldSubject => 'Subject';

  @override
  String get batchFieldDuration => 'Duration (minutes)';

  @override
  String get batchFieldDefaultFee => 'Default monthly fee (৳)';

  @override
  String get errorScheduleRequired => 'Pick at least one day';

  @override
  String get errorDurationInvalid => 'Enter a valid duration';

  @override
  String get batchSaved => 'Batch saved';

  @override
  String batchMemberCount(String count) {
    return 'Members: $count';
  }

  @override
  String get batchMembersTitle => 'Members';

  @override
  String get batchNoMembers => 'No students in this batch yet';

  @override
  String get batchAddMembers => 'Add students';

  @override
  String get batchNoAddable => 'No more students to add';

  @override
  String batchAddSelected(String count) {
    return 'Add $count';
  }

  @override
  String get batchMembersAdded => 'Students added';

  @override
  String batchMemberFee(String amount) {
    return 'Fee: $amount';
  }

  @override
  String get batchMemberCustomFee => 'Custom fee';

  @override
  String get batchSetCustomFee => 'Set custom fee';

  @override
  String get batchCustomFeeLabel => 'Custom monthly fee (৳)';

  @override
  String get batchCustomFeeHint => 'Leave empty to use the batch default fee';

  @override
  String get batchRemoveMember => 'Remove from batch';

  @override
  String get batchMemberRemoved => 'Student removed from the batch';

  @override
  String get batchArchived => 'Batch archived';

  @override
  String get batchRestored => 'Batch restored';

  @override
  String get batchDefaultFee => 'Default fee';

  @override
  String get profileBatches => 'Batches';

  @override
  String get feesOutstanding => 'Total outstanding';

  @override
  String feesStudentsOwing(String count) {
    return '$count owing';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterDueWeek => 'Due this week';

  @override
  String get sortByOverdue => 'By overdue days';

  @override
  String get sortByAmount => 'By amount';

  @override
  String get feesEmptyTitle => 'Nobody owes anything';

  @override
  String get feesEmptyBody => 'All fees are collected';

  @override
  String feesOpenMonths(String count) {
    return '$count open';
  }

  @override
  String feesOverdueDays(String days) {
    return '$days days overdue';
  }

  @override
  String feesDueOn(String date) {
    return 'Due $date';
  }

  @override
  String get actionRecordPayment => 'Record payment';

  @override
  String get payEditTitle => 'Edit payment';

  @override
  String get payAmount => 'Amount (৳)';

  @override
  String payOutstanding(String amount) {
    return 'Outstanding: $amount';
  }

  @override
  String payCredit(String amount) {
    return 'Advance credit: $amount';
  }

  @override
  String get payMonths => 'Pay for month';

  @override
  String get payMonthsHint => 'Leave empty to pay the oldest month first';

  @override
  String get payMethod => 'Method';

  @override
  String get methodCash => 'Cash';

  @override
  String get methodBkash => 'bKash';

  @override
  String get methodNagad => 'Nagad';

  @override
  String get methodRocket => 'Rocket';

  @override
  String get methodBank => 'Bank';

  @override
  String get methodOther => 'Other';

  @override
  String get payReference => 'Transaction ID / reference';

  @override
  String get payDate => 'Date';

  @override
  String get payBreakdown => 'How it will be applied';

  @override
  String get payCreditLine => 'Advance credit';

  @override
  String get payAmountRequired => 'Enter an amount';

  @override
  String get paySaved => 'Payment saved';

  @override
  String payReceiptNo(String no) {
    return 'Receipt no. $no';
  }

  @override
  String get payDone => 'Done';

  @override
  String get tabFeesCredit => 'Advance credit';

  @override
  String get ledgerTitle => 'Monthly ledger';

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get noPayments => 'No payments yet';

  @override
  String get noDues => 'No fees yet';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPartial => 'Partial';

  @override
  String get statusDue => 'Due';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusWaived => 'Waived';

  @override
  String ledgerAmounts(String payable, String paid, String balance) {
    return 'Fee $payable · paid $paid · left $balance';
  }

  @override
  String ledgerRunning(String amount) {
    return 'Owed so far $amount';
  }

  @override
  String get actionAdjust => 'Fee adjustments';

  @override
  String get adjChangeFee => 'Change monthly fee';

  @override
  String get adjEffectiveMonth => 'Effective from';

  @override
  String get adjNewFee => 'New monthly fee (৳)';

  @override
  String get adjFeeChanged => 'Fee changed';

  @override
  String get adjPause => 'Pause fees';

  @override
  String get adjResume => 'Resume fees';

  @override
  String get adjPauseFrom => 'Pause from';

  @override
  String get adjResumeFrom => 'Resume from';

  @override
  String get adjPaused => 'Fees paused';

  @override
  String get adjResumed => 'Fees resumed';

  @override
  String get adjOneTime => 'Add one-time fee';

  @override
  String get adjOneTimeLabel => 'Label (e.g. Admission fee)';

  @override
  String get adjOneTimeAmount => 'Amount (৳)';

  @override
  String get adjOneTimeAdded => 'One-time fee added';

  @override
  String get adjWaive => 'Waive';

  @override
  String get adjUnwaive => 'Undo waiver';

  @override
  String get adjDiscount => 'Give discount';

  @override
  String get adjReason => 'Reason';

  @override
  String get adjReasonRequired => 'Enter a reason';

  @override
  String get adjDiscountAmount => 'Discount amount (৳)';

  @override
  String get adjDone => 'Saved';

  @override
  String get payDelete => 'Delete payment';

  @override
  String get payDeleteTitle => 'Delete this payment?';

  @override
  String payDeleteBody(String no) {
    return 'Deleting receipt no. $no makes its months owe again. The receipt number will not be used again.';
  }

  @override
  String get payReceiptSharedWarning =>
      'A receipt for this payment was shared before. Changing it will not match the copy the guardian has.';

  @override
  String get payDeleted => 'Payment deleted';

  @override
  String get devSection => 'Developer';

  @override
  String get devConsistency => 'Run consistency check';

  @override
  String get devConsistencyOk => 'No problems found';

  @override
  String devConsistencyIssues(String count) {
    return '$count problems found';
  }

  @override
  String get genericError => 'Something went wrong';

  @override
  String get attStatusPresent => 'Present';

  @override
  String get attStatusAbsent => 'Absent';

  @override
  String get attStatusLate => 'Late';

  @override
  String get attStatusExcused => 'Excused';

  @override
  String get attMarkAllPresent => 'Mark all present';

  @override
  String get attTopic => 'Topic covered (optional)';

  @override
  String get attSaved => 'Attendance saved';

  @override
  String get attDiscardTitle => 'Save your changes?';

  @override
  String get attDiscardBody =>
      'You changed the attendance and have not saved it yet.';

  @override
  String get attDiscard => 'Discard';

  @override
  String get attNoStudents => 'No students in this class';

  @override
  String get attCancelClass => 'Cancel class';

  @override
  String get attHoliday => 'Mark as holiday';

  @override
  String get attReason => 'Reason (optional)';

  @override
  String get attRestore => 'Restore class';

  @override
  String get attCancelledBanner => 'This class was cancelled';

  @override
  String get attHolidayBanner => 'This day was marked a holiday';

  @override
  String attMarked(String done, String total) {
    return 'Marked $done/$total';
  }

  @override
  String get homeToday => 'Today';

  @override
  String get homeClasses => 'Classes';

  @override
  String get homeNoClasses => 'No classes this day';

  @override
  String get classNotTaken => 'Not taken';

  @override
  String get classTaken => 'Taken';

  @override
  String get classCancelled => 'Cancelled';

  @override
  String get classHoliday => 'Holiday';

  @override
  String classAttended(String attended, String total) {
    return '$attended of $total present';
  }

  @override
  String get classExtra => 'Extra';

  @override
  String get homePrevDay => 'Previous day';

  @override
  String get homeNextDay => 'Next day';

  @override
  String get homePickDate => 'Pick a date';

  @override
  String get homeAddExtra => 'Extra class';

  @override
  String get homeExtraTitle => 'Add an extra class';

  @override
  String get homeExtraBatches => 'Batches';

  @override
  String get homeExtraStudents => 'One-to-one';

  @override
  String get homeExtraNone => 'Nothing found';

  @override
  String get homeExtraTime => 'Start time (optional)';

  @override
  String get homeMonthTitle => 'This month';

  @override
  String get homeExpected => 'Expected';

  @override
  String get homeCollected => 'Collected';

  @override
  String get homeOutstanding => 'Outstanding';

  @override
  String homeOverdueStudents(String count) {
    return '$count overdue';
  }

  @override
  String homeTotalOwed(String amount) {
    return 'Owed across all months: $amount';
  }

  @override
  String get homeUpcoming => 'Fees due this week';

  @override
  String get homeUpcomingNone => 'No fees fall due this week';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get attClassesCount => 'Classes';

  @override
  String get attRate => 'Rate';

  @override
  String get attNoClasses => 'No classes recorded this month';

  @override
  String get calPrevMonth => 'Previous month';

  @override
  String get calNextMonth => 'Next month';

  @override
  String get attShare => 'Share with guardian';

  @override
  String shareAttTitle(String name, String month) {
    return '$name — attendance for $month';
  }

  @override
  String shareAttClasses(String count) {
    return 'Classes: $count';
  }

  @override
  String shareAttBreakdown(
    String present,
    String late,
    String absent,
    String excused,
  ) {
    return 'Present $present · Late $late · Absent $absent · Excused $excused';
  }

  @override
  String shareAttRate(String percent) {
    return 'Attendance rate: $percent';
  }

  @override
  String get shareAttNone => 'No classes were held this month';

  @override
  String shareFooter(String name) {
    return '— $name';
  }

  @override
  String get reportCollectionRate => 'Collection rate';

  @override
  String get reportCash => 'Cash received this month';

  @override
  String get reportBatches => 'By batch';

  @override
  String get reportNoBatch => 'No batch';

  @override
  String reportStudents(String count) {
    return 'Students: $count';
  }

  @override
  String reportAttendance(String percent) {
    return 'Attendance $percent';
  }

  @override
  String get reportNote =>
      'A student in several batches is counted in the one they joined first.';

  @override
  String get reportIncomeTitle => 'Income by month (last 12 months)';

  @override
  String get reportNoData => 'No data for this month';

  @override
  String get receiptTitle => 'Receipt';

  @override
  String get receiptAction => 'Receipt';

  @override
  String get receiptShareAction => 'Share receipt';

  @override
  String get receiptStudent => 'Student';

  @override
  String get receiptGuardian => 'Guardian';

  @override
  String get receiptFor => 'For';

  @override
  String get receiptTotal => 'Total received';

  @override
  String get receiptThanks => 'Thank you';

  @override
  String get receiptShareImage => 'Share as image';

  @override
  String get receiptSharePdf => 'Share as PDF';

  @override
  String get receiptShareFailed => 'Could not share';

  @override
  String get tutorSection => 'Tutor profile';

  @override
  String get tutorSectionHint => 'Shown on receipts and shared messages';

  @override
  String get tutorName => 'Your name';

  @override
  String get tutorInstitution => 'Institution name';

  @override
  String get tutorPhone => 'Phone number';

  @override
  String get chClasses => 'Class reminders';

  @override
  String get chClassesAbout => 'Reminds you before a class starts';

  @override
  String get chFees => 'Fee reminders';

  @override
  String get chFeesAbout => 'On days when fees fall due';

  @override
  String get chSummary => 'Weekly summary';

  @override
  String get chSummaryAbout => 'Weekly total of what is still owed';

  @override
  String get chBackup => 'Backup reminders';

  @override
  String get chBackupAbout => 'Reminds you to back up your data';

  @override
  String remClassTitle(String name) {
    return 'Class: $name';
  }

  @override
  String remClassBody(String time) {
    return 'Starts at $time';
  }

  @override
  String remFeesTitle(String count) {
    return '$count students have fees due today';
  }

  @override
  String remFeesBody(String amount) {
    return 'Total due $amount';
  }

  @override
  String get remWeeklyTitle => 'Weekly dues summary';

  @override
  String remWeeklyBody(String count, String amount) {
    return '$count students owe $amount in total';
  }

  @override
  String get remBackupTitle => 'Time for a backup';

  @override
  String get remBackupBody => 'Export a backup to keep your data safe';

  @override
  String get remKeepOnTitle => 'Keep reminders on';

  @override
  String get remKeepOnBody =>
      'Open the app once to schedule the next two weeks';

  @override
  String get remTestTitle => 'Test notification';

  @override
  String get remTestBody => 'Reminders are working';

  @override
  String get remPermTitle => 'Turn on reminders';

  @override
  String get remPermWhy =>
      'To remind you before classes and on fee days, the app needs permission to show notifications. Your data never leaves this phone.';

  @override
  String get remPermAllow => 'Allow notifications';

  @override
  String get remPermNotNow => 'Not now';

  @override
  String get remPermDenied =>
      'Notifications are blocked, so reminders cannot be sent. Allow them in phone settings to get reminders.';

  @override
  String get remPermOpenSettings => 'Open settings';

  @override
  String get remPermGranted => 'Reminders are on';

  @override
  String get remTestSend => 'Send a test notification';

  @override
  String get oemTitle => 'Battery settings';

  @override
  String get oemIntro =>
      'Some phones close apps to save battery, and then reminders do not arrive. Follow the steps below once.';

  @override
  String oemDetected(String maker) {
    return 'Your phone: $maker';
  }

  @override
  String get oemMakerXiaomi => 'Xiaomi / Redmi / POCO';

  @override
  String get oemMakerOppo => 'Oppo / OnePlus';

  @override
  String get oemMakerVivo => 'Vivo / iQOO';

  @override
  String get oemMakerRealme => 'Realme';

  @override
  String get oemMakerSamsung => 'Samsung';

  @override
  String get oemMakerOther => 'Other phones';

  @override
  String get oemStepsXiaomi =>
      'Open Settings › Apps › Manage apps › Tuition Khata\nTurn on “Autostart”\nUnder “Battery saver” choose “No restrictions”';

  @override
  String get oemStepsOppo =>
      'Open Settings › Battery › App battery management › Tuition Khata\nAllow “Background activity”\nTurn on “Auto-launch”';

  @override
  String get oemStepsVivo =>
      'Open Settings › Battery › Background power consumption › Tuition Khata\nAllow “High background power consumption”\nTurn on “Autostart”';

  @override
  String get oemStepsRealme =>
      'Open Settings › Battery › App battery management › Tuition Khata\nAllow “Background activity”\nTurn on “Auto-launch”';

  @override
  String get oemStepsSamsung =>
      'Open Settings › Battery › Background usage limits\nAdd Tuition Khata to “Never sleeping apps”';

  @override
  String get oemStepsOther =>
      'Open Settings › Apps › Tuition Khata › Battery\nChoose “Unrestricted” or “Don’t optimise”';

  @override
  String get oemOpenBattery => 'Open battery settings';

  @override
  String get oemDone => 'Got it';

  @override
  String get remHealth => 'Reminder health';

  @override
  String get remHealthOff => 'Off';

  @override
  String get remHealthBlocked => 'Notifications are blocked';

  @override
  String remHealthOk(String count) {
    return 'OK — $count reminders scheduled';
  }

  @override
  String get remHealthNone => 'Nothing is scheduled right now';

  @override
  String get remHealthGuide => 'See the battery guide';

  @override
  String get remHealthTapEnable => 'Tap to turn on';

  @override
  String get remSettingsTitle => 'Reminders';

  @override
  String get remMasterTitle => 'Reminders';

  @override
  String get remMasterHint => 'Class, fee and backup reminders';

  @override
  String get remClassOn => 'Before each class';

  @override
  String remMinutes(String minutes) {
    return '$minutes min before';
  }

  @override
  String get remFeeOn => 'On fee due days';

  @override
  String remAt(String time) {
    return 'At $time';
  }

  @override
  String get remWeeklyOn => 'Weekly dues summary';

  @override
  String remWeeklyWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get remBackupOn => 'Backup reminder';

  @override
  String remBackupAfter(String days) {
    return 'When the last backup is older than $days days';
  }

  @override
  String get remTestSent => 'Test notification sent';

  @override
  String get tplTitle => 'Message templates';

  @override
  String get tplFeeReminder => 'Fee reminder';

  @override
  String get tplPreview => 'Preview';

  @override
  String get tplVariables => 'Variables (tap to insert)';

  @override
  String get tplReset => 'Reset to default';

  @override
  String get tplSaved => 'Template saved';

  @override
  String get tplEmpty => 'The template cannot be empty';

  @override
  String get tplBodyLabel => 'Message text';

  @override
  String get tplSampleStudent => 'Rahim';

  @override
  String get tplVarStudent => 'Student name';

  @override
  String get tplVarGuardian => 'Guardian name';

  @override
  String get tplVarMonth => 'Month';

  @override
  String get tplVarAmount => 'Amount owed';

  @override
  String get tplVarDue => 'Due date';

  @override
  String get tplVarMonths => 'Months owed';

  @override
  String get tplVarTutor => 'Your name';

  @override
  String get tplVarInstitution => 'Institution';

  @override
  String get tplVarSignature => 'Signature (— your name)';

  @override
  String get remindGuardian => 'Remind guardian';

  @override
  String get remindSms => 'SMS';

  @override
  String get remindWhatsApp => 'WhatsApp';

  @override
  String get remindNoPhone => 'This student has no phone number';

  @override
  String get remindEditHint => 'You can edit the text before sending';

  @override
  String get remindEditTemplate => 'Edit template';

  @override
  String get remindBulkTitle => 'Remind everyone';

  @override
  String remindBulkProgress(String done, String total) {
    return '$done of $total done';
  }

  @override
  String get remindMarkDone => 'Mark as reminded';

  @override
  String get remindSkip => 'Skip';

  @override
  String get remindUndo => 'Undo';

  @override
  String get remindMarked => 'Marked as reminded';

  @override
  String get remindDoneAll => 'Everyone has been reminded';

  @override
  String get remindNothing => 'Nobody is overdue';

  @override
  String remindLast(String date) {
    return 'Last reminded: $date';
  }

  @override
  String get remindReminded => 'Reminded';

  @override
  String get remindClear => 'Clear marks and start again';

  @override
  String get remindNext => 'Next';

  @override
  String get remindPrevious => 'Previous';

  @override
  String get remindAwaiting =>
      'Tap “Mark as reminded” once the message is sent';

  @override
  String get bkTitle => 'Backup & restore';

  @override
  String bkLast(String when) {
    return 'Last backup: $when';
  }

  @override
  String get bkNever => 'No backup has been made yet';

  @override
  String get bkPrivacy =>
      'Your data stays on this phone. Back it up regularly.';

  @override
  String get bkNow => 'Back up now';

  @override
  String get bkEncrypt => 'Protect with a password';

  @override
  String get bkEncryptHint =>
      'A backup holds student and guardian details. If you forget the password the file cannot be opened.';

  @override
  String get bkPassword => 'Password';

  @override
  String get bkPasswordConfirm => 'Repeat the password';

  @override
  String get bkPasswordMismatch => 'The passwords do not match';

  @override
  String get bkPasswordShort => 'Use at least 6 characters';

  @override
  String get bkWorking => 'Making the backup…';

  @override
  String get bkFailed => 'The backup could not be made';

  @override
  String get bkSavedHint =>
      'Send the file somewhere safe (Google Drive, email or another phone)';

  @override
  String get bkRestore => 'Restore from a backup';

  @override
  String get bkRestoreHint => 'All current data will be replaced by the backup';

  @override
  String get rsEnterPassword => 'Enter the backup password';

  @override
  String get rsChecking => 'Checking the file…';

  @override
  String get rsPreviewTitle => 'Restore this backup?';

  @override
  String rsPreviewStudents(String count) {
    return 'Students: $count';
  }

  @override
  String rsPreviewPayments(String count) {
    return 'Payments: $count';
  }

  @override
  String rsPreviewLatest(String date) {
    return 'Latest payment: $date';
  }

  @override
  String rsPreviewDate(String date) {
    return 'Backup made: $date';
  }

  @override
  String get rsPreviewNoPayments => 'No payments yet';

  @override
  String get rsWarn =>
      'Everything on this phone will be replaced by the backup. A safety copy is kept first.';

  @override
  String get rsConfirm => 'Restore';

  @override
  String get rsWorking => 'Restoring… do not close the app';

  @override
  String get rsDone => 'Restore complete';

  @override
  String get bkErrNotABackup => 'This is not a Tuition Khata backup file';

  @override
  String get bkErrDamaged => 'This backup file is damaged or incomplete';

  @override
  String get bkErrNewer =>
      'This backup was made by a newer version of the app. Update the app first';

  @override
  String get bkErrChecksum =>
      'A file inside the backup has changed or is corrupted';

  @override
  String get bkErrIntegrity => 'The database in the backup is corrupted';

  @override
  String get bkErrPasswordRequired => 'This backup needs a password';

  @override
  String get bkErrWrongPassword => 'Wrong password, or the file is damaged';

  @override
  String get bkErrRolledBack =>
      'The restore failed. Your previous data has been put back as it was';

  @override
  String get bkErrNoRollback =>
      'The restore failed and your previous data could not be put back automatically. Close and reopen the app; a safety copy is still on the phone';

  @override
  String get bkBannerNever => 'You have not backed up yet';

  @override
  String bkBannerOld(String days) {
    return 'Your last backup was $days days ago';
  }

  @override
  String get bkBannerAction => 'Back up';

  @override
  String get bkReminderEvery => 'Backup reminder after';

  @override
  String bkReminderDays(String days) {
    return '$days days';
  }

  @override
  String get rstTitle => 'Delete all data';

  @override
  String get rstHint =>
      'Students, batches, payments, attendance and settings: all gone';

  @override
  String get rstFirstTitle => 'Delete all data?';

  @override
  String get rstFirstBody =>
      'Everything on this phone will be deleted. Unless you have a backup it cannot be brought back. A safety copy is kept on the phone first.';

  @override
  String get rstContinue => 'Continue';

  @override
  String get rstSecondTitle => 'Confirm one last time';

  @override
  String rstSecondBody(String word) {
    return 'To confirm, type “$word” below';
  }

  @override
  String get rstWord => 'DELETE';

  @override
  String get rstDelete => 'Delete everything';

  @override
  String get rstDone => 'All data has been deleted';

  @override
  String get rstWorking => 'Deleting…';
}
