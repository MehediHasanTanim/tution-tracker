// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'টিউশন খাতা';

  @override
  String get navHome => 'হোম';

  @override
  String get navStudents => 'শিক্ষার্থী';

  @override
  String get navFees => 'ফি';

  @override
  String get navReports => 'রিপোর্ট';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get language => 'ভাষা';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get sampleConjuncts => 'ক্ষমতা, বিজ্ঞান, সংখ্যা, শ্রদ্ধা, দুর্গাপুর';

  @override
  String get studentsSearchHint => 'নাম, অভিভাবক বা ফোন দিয়ে খুঁজুন';

  @override
  String get studentsClearSearch => 'মুছুন';

  @override
  String get studentsFilterClass => 'শ্রেণি';

  @override
  String get studentsAllClasses => 'সব শ্রেণি';

  @override
  String get studentsFilterBatch => 'ব্যাচ';

  @override
  String get studentsAllBatches => 'সব ব্যাচ';

  @override
  String get statusActive => 'সক্রিয়';

  @override
  String get statusPaused => 'বিরতিতে';

  @override
  String get statusArchived => 'আর্কাইভ';

  @override
  String studentsCount(String count) {
    return 'শিক্ষার্থী: $count';
  }

  @override
  String get studentsEmptyTitle => 'এখনও কোনো শিক্ষার্থী নেই';

  @override
  String get studentsEmptyBody => 'প্রথম শিক্ষার্থী যোগ করুন';

  @override
  String get studentsNoMatch => 'কোনো শিক্ষার্থী মেলেনি';

  @override
  String get studentsClearFilters => 'ফিল্টার মুছুন';

  @override
  String get studentsAdd => 'শিক্ষার্থী যোগ করুন';

  @override
  String get studentProfileTitle => 'শিক্ষার্থীর প্রোফাইল';

  @override
  String studentFeePerMonth(String amount) {
    return '$amount / মাস';
  }

  @override
  String get studentEditTitle => 'শিক্ষার্থী সম্পাদনা';

  @override
  String get fieldName => 'নাম';

  @override
  String get fieldMonthlyFee => 'মাসিক ফি (৳)';

  @override
  String get feeLockedHint => 'ফি পরিবর্তন করতে ফি সমন্বয় ব্যবহার করুন';

  @override
  String get moreDetails => 'আরও তথ্য যোগ করুন';

  @override
  String get fewerDetails => 'কম তথ্য দেখান';

  @override
  String get fieldDueDay => 'ফি দেওয়ার দিন (মাসের তারিখ)';

  @override
  String get fieldClassLevel => 'শ্রেণি';

  @override
  String get fieldSchool => 'স্কুল / প্রতিষ্ঠান';

  @override
  String get fieldGuardianName => 'অভিভাবকের নাম';

  @override
  String get fieldGuardianPhone => 'অভিভাবকের ফোন';

  @override
  String get fieldStudentPhone => 'শিক্ষার্থীর ফোন';

  @override
  String get fieldAddress => 'ঠিকানা / এলাকা';

  @override
  String get fieldSubjects => 'বিষয়';

  @override
  String get fieldOtherSubject => 'অন্য বিষয় যোগ করুন';

  @override
  String get fieldJoinedOn => 'ভর্তির তারিখ';

  @override
  String get fieldClassDays => 'ক্লাসের দিন';

  @override
  String get fieldClassTime => 'ক্লাসের সময়';

  @override
  String get fieldNotes => 'নোট';

  @override
  String get actionSave => 'সংরক্ষণ করুন';

  @override
  String get actionClear => 'মুছুন';

  @override
  String get errorNameRequired => 'নাম লিখুন';

  @override
  String get errorFeeRequired => 'মাসিক ফি লিখুন';

  @override
  String get errorPhoneInvalid => 'সঠিক মোবাইল নম্বর দিন (যেমন ০১৭১২৩৪৫৬৭৮)';

  @override
  String get studentSaved => 'শিক্ষার্থী সংরক্ষিত হয়েছে';

  @override
  String get none => 'নেই';

  @override
  String get tabOverview => 'সারসংক্ষেপ';

  @override
  String get tabAttendance => 'উপস্থিতি';

  @override
  String get tabFees => 'ফি';

  @override
  String get tabNotes => 'নোট';

  @override
  String get comingSoon => 'শীঘ্রই আসছে';

  @override
  String get actionCall => 'কল';

  @override
  String get actionSms => 'এসএমএস';

  @override
  String get actionWhatsapp => 'হোয়াটসঅ্যাপ';

  @override
  String get noPhoneNumber => 'ফোন নম্বর নেই';

  @override
  String get contactLaunchFailed => 'খুলতে পারেনি। অ্যাপটি ইনস্টল করা আছে কি?';

  @override
  String get actionEdit => 'সম্পাদনা';

  @override
  String get actionArchive => 'আর্কাইভ করুন';

  @override
  String get actionRestore => 'পুনরুদ্ধার করুন';

  @override
  String get actionDelete => 'স্থায়ীভাবে মুছুন';

  @override
  String get actionCancel => 'বাতিল';

  @override
  String get deleteStudentTitle => 'শিক্ষার্থী মুছবেন?';

  @override
  String get deleteStudentBody =>
      'এই শিক্ষার্থীর সব হিসাব (ফি, পেমেন্ট, উপস্থিতি) চিরতরে মুছে যাবে। এটি ফেরানো যাবে না। হিসাব রাখতে চাইলে আর্কাইভ করুন।';

  @override
  String get studentDeleted => 'শিক্ষার্থী মুছে ফেলা হয়েছে';

  @override
  String get studentArchived => 'শিক্ষার্থী আর্কাইভ করা হয়েছে';

  @override
  String get studentRestored => 'শিক্ষার্থী পুনরুদ্ধার করা হয়েছে';

  @override
  String get profileMonthlyFee => 'মাসিক ফি';

  @override
  String get profileDueDay => 'ফি দেওয়ার দিন';

  @override
  String get photoAdd => 'ছবি যোগ করুন';

  @override
  String get photoChange => 'ছবি পরিবর্তন করুন';

  @override
  String get photoTake => 'ছবি তুলুন';

  @override
  String get photoChoose => 'গ্যালারি থেকে বাছাই করুন';

  @override
  String get photoRemove => 'ছবি সরান';

  @override
  String get photoFailed => 'ছবিটি ব্যবহার করা গেল না';

  @override
  String get tabAllStudents => 'সব শিক্ষার্থী';

  @override
  String get tabBatches => 'ব্যাচসমূহ';

  @override
  String get batchesAdd => 'ব্যাচ যোগ করুন';

  @override
  String get batchEditTitle => 'ব্যাচ সম্পাদনা';

  @override
  String get batchesEmptyTitle => 'এখনও কোনো ব্যাচ নেই';

  @override
  String get batchesEmptyBody => 'প্রথম ব্যাচ তৈরি করুন';

  @override
  String get batchShowArchived => 'আর্কাইভ দেখান';

  @override
  String get batchFieldName => 'ব্যাচের নাম';

  @override
  String get batchFieldSubject => 'বিষয়';

  @override
  String get batchFieldDuration => 'সময়কাল (মিনিট)';

  @override
  String get batchFieldDefaultFee => 'ডিফল্ট মাসিক ফি (৳)';

  @override
  String get errorScheduleRequired => 'অন্তত একটি দিন বাছাই করুন';

  @override
  String get errorDurationInvalid => 'সঠিক সময়কাল দিন';

  @override
  String get batchSaved => 'ব্যাচ সংরক্ষিত হয়েছে';

  @override
  String batchMemberCount(String count) {
    return 'সদস্য: $count';
  }

  @override
  String get batchMembersTitle => 'সদস্য';

  @override
  String get batchNoMembers => 'এই ব্যাচে এখনও কেউ নেই';

  @override
  String get batchAddMembers => 'শিক্ষার্থী যোগ করুন';

  @override
  String get batchNoAddable => 'যোগ করার মতো আর কোনো শিক্ষার্থী নেই';

  @override
  String batchAddSelected(String count) {
    return '$count জনকে যোগ করুন';
  }

  @override
  String get batchMembersAdded => 'শিক্ষার্থী যোগ করা হয়েছে';

  @override
  String batchMemberFee(String amount) {
    return 'ফি: $amount';
  }

  @override
  String get batchMemberCustomFee => 'আলাদা ফি';

  @override
  String get batchSetCustomFee => 'আলাদা ফি নির্ধারণ';

  @override
  String get batchCustomFeeLabel => 'আলাদা মাসিক ফি (৳)';

  @override
  String get batchCustomFeeHint => 'ফাঁকা রাখলে ব্যাচের ডিফল্ট ফি প্রযোজ্য';

  @override
  String get batchRemoveMember => 'ব্যাচ থেকে সরান';

  @override
  String get batchMemberRemoved => 'শিক্ষার্থীকে ব্যাচ থেকে সরানো হয়েছে';

  @override
  String get batchArchived => 'ব্যাচ আর্কাইভ করা হয়েছে';

  @override
  String get batchRestored => 'ব্যাচ পুনরুদ্ধার করা হয়েছে';

  @override
  String get batchDefaultFee => 'ডিফল্ট ফি';

  @override
  String get profileBatches => 'ব্যাচ';

  @override
  String get feesOutstanding => 'মোট বাকি';

  @override
  String feesStudentsOwing(String count) {
    return '$count জন বাকি';
  }

  @override
  String get filterAll => 'সব';

  @override
  String get filterOverdue => 'বিলম্বিত';

  @override
  String get filterDueWeek => 'এই সপ্তাহে';

  @override
  String get sortByOverdue => 'বিলম্ব অনুযায়ী';

  @override
  String get sortByAmount => 'পরিমাণ অনুযায়ী';

  @override
  String get feesEmptyTitle => 'কারও কোনো বাকি নেই';

  @override
  String get feesEmptyBody => 'সব ফি আদায় হয়েছে';

  @override
  String feesOpenMonths(String count) {
    return '$count মাস বাকি';
  }

  @override
  String feesOverdueDays(String days) {
    return '$days দিন বিলম্ব';
  }

  @override
  String feesDueOn(String date) {
    return 'শেষ তারিখ $date';
  }

  @override
  String get actionRecordPayment => 'পেমেন্ট নিন';

  @override
  String get payEditTitle => 'পেমেন্ট সম্পাদনা';

  @override
  String get payAmount => 'পরিমাণ (৳)';

  @override
  String payOutstanding(String amount) {
    return 'মোট বাকি: $amount';
  }

  @override
  String payCredit(String amount) {
    return 'অগ্রিম জমা: $amount';
  }

  @override
  String get payMonths => 'কোন মাসের জন্য';

  @override
  String get payMonthsHint => 'না বাছলে পুরোনো মাস আগে পরিশোধ হবে';

  @override
  String get payMethod => 'মাধ্যম';

  @override
  String get methodCash => 'ক্যাশ';

  @override
  String get methodBkash => 'বিকাশ';

  @override
  String get methodNagad => 'নগদ';

  @override
  String get methodRocket => 'রকেট';

  @override
  String get methodBank => 'ব্যাংক';

  @override
  String get methodOther => 'অন্যান্য';

  @override
  String get payReference => 'ট্রানজ্যাকশন আইডি / রেফারেন্স';

  @override
  String get payDate => 'তারিখ';

  @override
  String get payBreakdown => 'যেভাবে প্রয়োগ হবে';

  @override
  String get payCreditLine => 'অগ্রিম জমা';

  @override
  String get payAmountRequired => 'পরিমাণ লিখুন';

  @override
  String get paySaved => 'পেমেন্ট সংরক্ষিত হয়েছে';

  @override
  String payReceiptNo(String no) {
    return 'রসিদ নং $no';
  }

  @override
  String get payDone => 'ঠিক আছে';

  @override
  String get tabFeesCredit => 'অগ্রিম জমা';

  @override
  String get ledgerTitle => 'মাসওয়ারি হিসাব';

  @override
  String get paymentsTitle => 'পেমেন্টের ইতিহাস';

  @override
  String get noPayments => 'কোনো পেমেন্ট নেই';

  @override
  String get noDues => 'এখনও কোনো ফি তৈরি হয়নি';

  @override
  String get statusPaid => 'পরিশোধিত';

  @override
  String get statusPartial => 'আংশিক';

  @override
  String get statusDue => 'বাকি';

  @override
  String get statusOverdue => 'বিলম্বিত';

  @override
  String get statusWaived => 'মওকুফ';

  @override
  String ledgerAmounts(String payable, String paid, String balance) {
    return 'ফি $payable · জমা $paid · বাকি $balance';
  }

  @override
  String ledgerRunning(String amount) {
    return 'এ পর্যন্ত মোট বাকি $amount';
  }

  @override
  String get actionAdjust => 'ফি সমন্বয়';

  @override
  String get adjChangeFee => 'মাসিক ফি পরিবর্তন';

  @override
  String get adjEffectiveMonth => 'যে মাস থেকে কার্যকর';

  @override
  String get adjNewFee => 'নতুন মাসিক ফি (৳)';

  @override
  String get adjFeeChanged => 'ফি পরিবর্তন করা হয়েছে';

  @override
  String get adjPause => 'ফি বন্ধ রাখুন';

  @override
  String get adjResume => 'ফি আবার চালু করুন';

  @override
  String get adjPauseFrom => 'যে মাস থেকে বন্ধ';

  @override
  String get adjResumeFrom => 'যে মাস থেকে চালু';

  @override
  String get adjPaused => 'ফি বন্ধ করা হয়েছে';

  @override
  String get adjResumed => 'ফি চালু করা হয়েছে';

  @override
  String get adjOneTime => 'এককালীন ফি যোগ করুন';

  @override
  String get adjOneTimeLabel => 'বিবরণ (যেমন ভর্তি ফি)';

  @override
  String get adjOneTimeAmount => 'পরিমাণ (৳)';

  @override
  String get adjOneTimeAdded => 'এককালীন ফি যোগ করা হয়েছে';

  @override
  String get adjWaive => 'মওকুফ করুন';

  @override
  String get adjUnwaive => 'মওকুফ বাতিল করুন';

  @override
  String get adjDiscount => 'ছাড় দিন';

  @override
  String get adjReason => 'কারণ';

  @override
  String get adjReasonRequired => 'কারণ লিখুন';

  @override
  String get adjDiscountAmount => 'ছাড়ের পরিমাণ (৳)';

  @override
  String get adjDone => 'সংরক্ষিত হয়েছে';

  @override
  String get payDelete => 'পেমেন্ট মুছুন';

  @override
  String get payDeleteTitle => 'পেমেন্ট মুছবেন?';

  @override
  String payDeleteBody(String no) {
    return 'রসিদ নং $no মুছে ফেললে সংশ্লিষ্ট মাসগুলো আবার বাকি হবে। রসিদ নম্বরটি আর ব্যবহার হবে না।';
  }

  @override
  String get payReceiptSharedWarning =>
      'এই পেমেন্টের রসিদ আগে শেয়ার করা হয়েছে। পরিবর্তন করলে অভিভাবকের কাছে থাকা রসিদের সাথে মিলবে না।';

  @override
  String get payDeleted => 'পেমেন্ট মুছে ফেলা হয়েছে';

  @override
  String get devSection => 'ডেভেলপার';

  @override
  String get devConsistency => 'হিসাব যাচাই চালান';

  @override
  String get devConsistencyOk => 'কোনো সমস্যা পাওয়া যায়নি';

  @override
  String devConsistencyIssues(String count) {
    return '$countটি সমস্যা পাওয়া গেছে';
  }

  @override
  String get genericError => 'কিছু ভুল হয়েছে';

  @override
  String get attStatusPresent => 'উপস্থিত';

  @override
  String get attStatusAbsent => 'অনুপস্থিত';

  @override
  String get attStatusLate => 'দেরি';

  @override
  String get attStatusExcused => 'ছুটি';

  @override
  String get attMarkAllPresent => 'সবাইকে উপস্থিত করুন';

  @override
  String get attTopic => 'আজকের পাঠ (ঐচ্ছিক)';

  @override
  String get attSaved => 'উপস্থিতি সংরক্ষিত হয়েছে';

  @override
  String get attDiscardTitle => 'পরিবর্তন সংরক্ষণ করবেন?';

  @override
  String get attDiscardBody =>
      'আপনি উপস্থিতিতে পরিবর্তন করেছেন যা এখনও সংরক্ষিত হয়নি।';

  @override
  String get attDiscard => 'বাদ দিন';

  @override
  String get attNoStudents => 'এই ক্লাসে কোনো শিক্ষার্থী নেই';

  @override
  String get attCancelClass => 'ক্লাস বাতিল করুন';

  @override
  String get attHoliday => 'ছুটির দিন হিসেবে চিহ্নিত করুন';

  @override
  String get attReason => 'কারণ (ঐচ্ছিক)';

  @override
  String get attRestore => 'ক্লাস আবার চালু করুন';

  @override
  String get attCancelledBanner => 'এই ক্লাস বাতিল করা হয়েছে';

  @override
  String get attHolidayBanner => 'এই দিন ছুটি';

  @override
  String attMarked(String done, String total) {
    return 'চিহ্নিত $done/$total';
  }

  @override
  String get homeToday => 'আজ';

  @override
  String get homeClasses => 'ক্লাস';

  @override
  String get homeNoClasses => 'এই দিনে কোনো ক্লাস নেই';

  @override
  String get classNotTaken => 'নেওয়া হয়নি';

  @override
  String get classTaken => 'নেওয়া হয়েছে';

  @override
  String get classCancelled => 'বাতিল';

  @override
  String get classHoliday => 'ছুটি';

  @override
  String classAttended(String attended, String total) {
    return 'উপস্থিত $attended/$total';
  }

  @override
  String get classExtra => 'অতিরিক্ত';

  @override
  String get homePrevDay => 'আগের দিন';

  @override
  String get homeNextDay => 'পরের দিন';

  @override
  String get homePickDate => 'তারিখ বাছুন';

  @override
  String get homeAddExtra => 'অতিরিক্ত ক্লাস';

  @override
  String get homeExtraTitle => 'অতিরিক্ত ক্লাস যোগ করুন';

  @override
  String get homeExtraBatches => 'ব্যাচ';

  @override
  String get homeExtraStudents => 'একক শিক্ষার্থী';

  @override
  String get homeExtraNone => 'কিছু পাওয়া যায়নি';

  @override
  String get homeExtraTime => 'শুরুর সময় (ঐচ্ছিক)';

  @override
  String get homeMonthTitle => 'এই মাস';

  @override
  String get homeExpected => 'প্রত্যাশিত';

  @override
  String get homeCollected => 'আদায়';

  @override
  String get homeOutstanding => 'বাকি';

  @override
  String homeOverdueStudents(String count) {
    return '$count জন বিলম্বিত';
  }

  @override
  String homeTotalOwed(String amount) {
    return 'সব মাস মিলিয়ে বাকি: $amount';
  }

  @override
  String get homeUpcoming => 'এই সপ্তাহে ফি দেওয়ার তারিখ';

  @override
  String get homeUpcomingNone => 'এই সপ্তাহে কোনো ফি দেওয়ার তারিখ নেই';

  @override
  String get homeSeeAll => 'সব দেখুন';

  @override
  String get attClassesCount => 'মোট ক্লাস';

  @override
  String get attRate => 'হার';

  @override
  String get attNoClasses => 'এই মাসে কোনো ক্লাসের তথ্য নেই';

  @override
  String get calPrevMonth => 'আগের মাস';

  @override
  String get calNextMonth => 'পরের মাস';

  @override
  String get attShare => 'অভিভাবকের জন্য শেয়ার করুন';

  @override
  String shareAttTitle(String name, String month) {
    return '$name — $month-এর উপস্থিতি';
  }

  @override
  String shareAttClasses(String count) {
    return 'মোট ক্লাস: $count';
  }

  @override
  String shareAttBreakdown(
    String present,
    String late,
    String absent,
    String excused,
  ) {
    return 'উপস্থিত $present · দেরি $late · অনুপস্থিত $absent · ছুটি $excused';
  }

  @override
  String shareAttRate(String percent) {
    return 'উপস্থিতির হার: $percent';
  }

  @override
  String get shareAttNone => 'এই মাসে কোনো ক্লাস হয়নি';

  @override
  String shareFooter(String name) {
    return '— $name';
  }

  @override
  String get reportCollectionRate => 'আদায়ের হার';

  @override
  String get reportCash => 'এই মাসে হাতে পাওয়া';

  @override
  String get reportBatches => 'ব্যাচ অনুযায়ী';

  @override
  String get reportNoBatch => 'কোনো ব্যাচ নয়';

  @override
  String reportStudents(String count) {
    return 'শিক্ষার্থী: $count';
  }

  @override
  String reportAttendance(String percent) {
    return 'উপস্থিতি $percent';
  }

  @override
  String get reportNote =>
      'একাধিক ব্যাচের শিক্ষার্থী প্রথম যে ব্যাচে যোগ দিয়েছেন সেখানে গোনা হয়।';

  @override
  String get reportIncomeTitle => 'মাসওয়ারি আয় (শেষ ১২ মাস)';

  @override
  String get reportNoData => 'এই মাসে কোনো তথ্য নেই';

  @override
  String get receiptTitle => 'রসিদ';

  @override
  String get receiptAction => 'রসিদ';

  @override
  String get receiptShareAction => 'রসিদ শেয়ার করুন';

  @override
  String get receiptStudent => 'শিক্ষার্থী';

  @override
  String get receiptGuardian => 'অভিভাবক';

  @override
  String get receiptFor => 'যে মাসের জন্য';

  @override
  String get receiptTotal => 'মোট জমা';

  @override
  String get receiptThanks => 'ধন্যবাদ';

  @override
  String get receiptShareImage => 'ছবি হিসেবে শেয়ার করুন';

  @override
  String get receiptSharePdf => 'PDF হিসেবে শেয়ার করুন';

  @override
  String get receiptShareFailed => 'শেয়ার করা যায়নি';

  @override
  String get tutorSection => 'শিক্ষকের তথ্য';

  @override
  String get tutorSectionHint => 'রসিদ ও শেয়ার করা বার্তায় দেখানো হবে';

  @override
  String get tutorName => 'শিক্ষকের নাম';

  @override
  String get tutorInstitution => 'প্রতিষ্ঠানের নাম';

  @override
  String get tutorPhone => 'ফোন নম্বর';
}
