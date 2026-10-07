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
}
