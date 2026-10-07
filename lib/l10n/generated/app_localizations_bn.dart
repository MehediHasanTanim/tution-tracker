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

  @override
  String get chClasses => 'ক্লাসের রিমাইন্ডার';

  @override
  String get chClassesAbout => 'ক্লাস শুরুর আগে মনে করিয়ে দেয়';

  @override
  String get chFees => 'ফি-র রিমাইন্ডার';

  @override
  String get chFeesAbout => 'যেদিন ফি আদায়ের দিন';

  @override
  String get chSummary => 'সাপ্তাহিক সারসংক্ষেপ';

  @override
  String get chSummaryAbout => 'সপ্তাহের বাকি টাকার হিসাব';

  @override
  String get chBackup => 'ব্যাকআপ রিমাইন্ডার';

  @override
  String get chBackupAbout => 'ব্যাকআপ নেওয়ার কথা মনে করায়';

  @override
  String remClassTitle(String name) {
    return 'ক্লাস: $name';
  }

  @override
  String remClassBody(String time) {
    return 'শুরু $time';
  }

  @override
  String remFeesTitle(String count) {
    return 'আজ $count জনের ফি আদায়ের দিন';
  }

  @override
  String remFeesBody(String amount) {
    return 'মোট বাকি $amount';
  }

  @override
  String get remWeeklyTitle => 'সাপ্তাহিক বাকির হিসাব';

  @override
  String remWeeklyBody(String count, String amount) {
    return '$count জনের কাছে মোট $amount বাকি';
  }

  @override
  String get remBackupTitle => 'ব্যাকআপ নেওয়ার সময় হয়েছে';

  @override
  String get remBackupBody => 'তথ্য নিরাপদ রাখতে এখনই ব্যাকআপ নিন';

  @override
  String get remKeepOnTitle => 'রিমাইন্ডার চালু রাখুন';

  @override
  String get remKeepOnBody =>
      'পরবর্তী দুই সপ্তাহের রিমাইন্ডারের জন্য অ্যাপটি একবার খুলুন';

  @override
  String get remTestTitle => 'পরীক্ষামূলক নোটিফিকেশন';

  @override
  String get remTestBody => 'রিমাইন্ডার ঠিকমতো কাজ করছে';

  @override
  String get remPermTitle => 'রিমাইন্ডার চালু করুন';

  @override
  String get remPermWhy =>
      'ক্লাস শুরুর আগে এবং ফি আদায়ের দিনে আপনাকে মনে করিয়ে দিতে অ্যাপের নোটিফিকেশন পাঠানোর অনুমতি দরকার। আপনার তথ্য ফোনের বাইরে যায় না।';

  @override
  String get remPermAllow => 'অনুমতি দিন';

  @override
  String get remPermNotNow => 'এখন নয়';

  @override
  String get remPermDenied =>
      'নোটিফিকেশনের অনুমতি দেওয়া হয়নি, তাই রিমাইন্ডার পাঠানো যাবে না। ফোনের সেটিংস থেকে অনুমতি দিলে রিমাইন্ডার কাজ করবে।';

  @override
  String get remPermOpenSettings => 'সেটিংস খুলুন';

  @override
  String get remPermGranted => 'রিমাইন্ডার চালু হয়েছে';

  @override
  String get remTestSend => 'পরীক্ষামূলক নোটিফিকেশন পাঠান';

  @override
  String get oemTitle => 'ব্যাটারি সেটিংস';

  @override
  String get oemIntro =>
      'কিছু ফোন ব্যাটারি বাঁচাতে অ্যাপ বন্ধ করে দেয়, তাতে রিমাইন্ডার আসে না। নিচের ধাপগুলো একবার করে নিন।';

  @override
  String oemDetected(String maker) {
    return 'আপনার ফোন: $maker';
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
  String get oemMakerOther => 'অন্যান্য ফোন';

  @override
  String get oemStepsXiaomi =>
      'সেটিংস › অ্যাপস › অ্যাপ ম্যানেজ › টিউশন খাতা খুলুন\n“অটোস্টার্ট” চালু করুন\n“ব্যাটারি সেভার” থেকে “কোনো সীমাবদ্ধতা নেই” বেছে নিন';

  @override
  String get oemStepsOppo =>
      'সেটিংস › ব্যাটারি › অ্যাপ ব্যাটারি ম্যানেজমেন্ট › টিউশন খাতা খুলুন\n“ব্যাকগ্রাউন্ডে চলার অনুমতি” চালু করুন\n“অটো-লঞ্চ” চালু করুন';

  @override
  String get oemStepsVivo =>
      'সেটিংস › ব্যাটারি › ব্যাকগ্রাউন্ড পাওয়ার ব্যবহার › টিউশন খাতা খুলুন\n“উচ্চ ব্যাকগ্রাউন্ড পাওয়ার ব্যবহার” অনুমোদন করুন\n“অটোস্টার্ট” চালু করুন';

  @override
  String get oemStepsRealme =>
      'সেটিংস › ব্যাটারি › অ্যাপ ব্যাটারি ম্যানেজমেন্ট › টিউশন খাতা খুলুন\n“ব্যাকগ্রাউন্ডে চলার অনুমতি” চালু করুন\n“অটো-লঞ্চ” চালু করুন';

  @override
  String get oemStepsSamsung =>
      'সেটিংস › ব্যাটারি › ব্যাকগ্রাউন্ড ব্যবহারের সীমা খুলুন\n“কখনো ঘুমায় না এমন অ্যাপ” তালিকায় টিউশন খাতা যোগ করুন';

  @override
  String get oemStepsOther =>
      'সেটিংস › অ্যাপস › টিউশন খাতা › ব্যাটারি খুলুন\n“সীমাবদ্ধতা নেই” বা “অপ্টিমাইজ করবেন না” বেছে নিন';

  @override
  String get oemOpenBattery => 'ব্যাটারি সেটিংস খুলুন';

  @override
  String get oemDone => 'বুঝেছি';

  @override
  String get remHealth => 'রিমাইন্ডারের অবস্থা';

  @override
  String get remHealthOff => 'বন্ধ আছে';

  @override
  String get remHealthBlocked => 'নোটিফিকেশন বন্ধ করা আছে';

  @override
  String remHealthOk(String count) {
    return 'ঠিক আছে — $countটি রিমাইন্ডার নির্ধারিত';
  }

  @override
  String get remHealthNone => 'এখন কোনো রিমাইন্ডার নির্ধারিত নেই';

  @override
  String get remHealthGuide => 'ব্যাটারি গাইড দেখুন';

  @override
  String get remHealthTapEnable => 'চালু করতে এখানে চাপুন';

  @override
  String get remSettingsTitle => 'রিমাইন্ডার';

  @override
  String get remMasterTitle => 'রিমাইন্ডার';

  @override
  String get remMasterHint => 'ক্লাস, ফি ও ব্যাকআপের কথা মনে করিয়ে দেবে';

  @override
  String get remClassOn => 'ক্লাস শুরুর আগে';

  @override
  String remMinutes(String minutes) {
    return '$minutes মিনিট আগে';
  }

  @override
  String get remFeeOn => 'ফি আদায়ের দিনে';

  @override
  String remAt(String time) {
    return 'সময়: $time';
  }

  @override
  String get remWeeklyOn => 'সাপ্তাহিক বাকির হিসাব';

  @override
  String remWeeklyWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get remBackupOn => 'ব্যাকআপের রিমাইন্ডার';

  @override
  String remBackupAfter(String days) {
    return '$days দিনের বেশি পুরনো হলে';
  }

  @override
  String get remTestSent => 'পরীক্ষামূলক নোটিফিকেশন পাঠানো হয়েছে';

  @override
  String get tplTitle => 'মেসেজ টেমপ্লেট';

  @override
  String get tplFeeReminder => 'ফি-র রিমাইন্ডার';

  @override
  String get tplPreview => 'প্রিভিউ';

  @override
  String get tplVariables => 'ভেরিয়েবল (চাপলে যোগ হবে)';

  @override
  String get tplReset => 'ডিফল্টে ফিরুন';

  @override
  String get tplSaved => 'টেমপ্লেট সংরক্ষিত হয়েছে';

  @override
  String get tplEmpty => 'টেমপ্লেট খালি রাখা যাবে না';

  @override
  String get tplBodyLabel => 'মেসেজের লেখা';

  @override
  String get tplSampleStudent => 'রহিম';

  @override
  String get tplVarStudent => 'শিক্ষার্থীর নাম';

  @override
  String get tplVarGuardian => 'অভিভাবকের নাম';

  @override
  String get tplVarMonth => 'মাস';

  @override
  String get tplVarAmount => 'বাকি টাকা';

  @override
  String get tplVarDue => 'নির্ধারিত তারিখ';

  @override
  String get tplVarMonths => 'বাকি মাসের সংখ্যা';

  @override
  String get tplVarTutor => 'আপনার নাম';

  @override
  String get tplVarInstitution => 'প্রতিষ্ঠান';

  @override
  String get tplVarSignature => 'সই (— আপনার নাম)';

  @override
  String get remindGuardian => 'অভিভাবককে রিমাইন্ডার';

  @override
  String get remindSms => 'SMS';

  @override
  String get remindWhatsApp => 'WhatsApp';

  @override
  String get remindNoPhone => 'এই শিক্ষার্থীর ফোন নম্বর নেই';

  @override
  String get remindEditHint => 'পাঠানোর আগে লেখা বদলাতে পারেন';

  @override
  String get remindEditTemplate => 'টেমপ্লেট বদলান';

  @override
  String get remindBulkTitle => 'সবাইকে রিমাইন্ডার';

  @override
  String remindBulkProgress(String done, String total) {
    return '$done/$total জন সম্পন্ন';
  }

  @override
  String get remindMarkDone => 'রিমাইন্ড করা হয়েছে';

  @override
  String get remindSkip => 'বাদ দিন';

  @override
  String get remindUndo => 'ফিরিয়ে নিন';

  @override
  String get remindMarked => 'রিমাইন্ড হিসেবে চিহ্নিত করা হয়েছে';

  @override
  String get remindDoneAll => 'সবাইকে রিমাইন্ড করা হয়েছে';

  @override
  String get remindNothing => 'কেউ মেয়াদ পেরিয়ে বাকি নেই';

  @override
  String remindLast(String date) {
    return 'সর্বশেষ রিমাইন্ড: $date';
  }

  @override
  String get remindReminded => 'রিমাইন্ড করা হয়েছে';

  @override
  String get remindClear => 'চিহ্ন মুছে আবার শুরু করুন';

  @override
  String get remindNext => 'পরের জন';

  @override
  String get remindPrevious => 'আগের জন';

  @override
  String get remindAwaiting => 'মেসেজ পাঠানো হলে “রিমাইন্ড করা হয়েছে” চাপুন';

  @override
  String get bkTitle => 'ব্যাকআপ ও রিস্টোর';

  @override
  String bkLast(String when) {
    return 'সর্বশেষ ব্যাকআপ: $when';
  }

  @override
  String get bkNever => 'এখনো কোনো ব্যাকআপ নেওয়া হয়নি';

  @override
  String get bkPrivacy => 'আপনার তথ্য এই ফোনেই থাকে। নিয়মিত ব্যাকআপ নিন।';

  @override
  String get bkNow => 'ব্যাকআপ নিন';

  @override
  String get bkEncrypt => 'পাসওয়ার্ড দিয়ে সুরক্ষিত করুন';

  @override
  String get bkEncryptHint =>
      'ব্যাকআপে শিক্ষার্থী ও অভিভাবকের তথ্য থাকে। পাসওয়ার্ড ভুলে গেলে ফাইল খোলা যাবে না।';

  @override
  String get bkPassword => 'পাসওয়ার্ড';

  @override
  String get bkPasswordConfirm => 'পাসওয়ার্ড আবার লিখুন';

  @override
  String get bkPasswordMismatch => 'পাসওয়ার্ড দুটি মেলেনি';

  @override
  String get bkPasswordShort => 'কমপক্ষে ৬টি অক্ষর দিন';

  @override
  String get bkWorking => 'ব্যাকআপ তৈরি হচ্ছে…';

  @override
  String get bkFailed => 'ব্যাকআপ তৈরি করা যায়নি';

  @override
  String get bkSavedHint =>
      'ফাইলটি নিরাপদ জায়গায় (Google Drive, ইমেইল বা অন্য ফোনে) পাঠিয়ে রাখুন';

  @override
  String get bkRestore => 'ব্যাকআপ থেকে রিস্টোর';

  @override
  String get bkRestoreHint => 'বর্তমান সব তথ্য ব্যাকআপের তথ্য দিয়ে বদলে যাবে';

  @override
  String get rsEnterPassword => 'ব্যাকআপের পাসওয়ার্ড দিন';

  @override
  String get rsChecking => 'ফাইল যাচাই করা হচ্ছে…';

  @override
  String get rsPreviewTitle => 'এই ব্যাকআপ রিস্টোর করবেন?';

  @override
  String rsPreviewStudents(String count) {
    return 'শিক্ষার্থী: $count';
  }

  @override
  String rsPreviewPayments(String count) {
    return 'পেমেন্ট: $count';
  }

  @override
  String rsPreviewLatest(String date) {
    return 'সর্বশেষ পেমেন্ট: $date';
  }

  @override
  String rsPreviewDate(String date) {
    return 'ব্যাকআপের তারিখ: $date';
  }

  @override
  String get rsPreviewNoPayments => 'কোনো পেমেন্ট নেই';

  @override
  String get rsWarn =>
      'এই ফোনের বর্তমান সব তথ্য মুছে ব্যাকআপের তথ্য বসবে। তার আগে একটি নিরাপত্তা কপি রাখা হবে।';

  @override
  String get rsConfirm => 'রিস্টোর করুন';

  @override
  String get rsWorking => 'রিস্টোর হচ্ছে… অ্যাপ বন্ধ করবেন না';

  @override
  String get rsDone => 'রিস্টোর সম্পন্ন হয়েছে';

  @override
  String get bkErrNotABackup => 'এটি টিউশন খাতার ব্যাকআপ ফাইল নয়';

  @override
  String get bkErrDamaged => 'ব্যাকআপ ফাইলটি নষ্ট বা অসম্পূর্ণ';

  @override
  String get bkErrNewer =>
      'এই ব্যাকআপ অ্যাপের নতুন সংস্করণে তৈরি। আগে অ্যাপ আপডেট করুন';

  @override
  String get bkErrChecksum => 'ব্যাকআপের ভেতরের ফাইল বদলে গেছে বা নষ্ট হয়েছে';

  @override
  String get bkErrIntegrity => 'ব্যাকআপের ডাটাবেস নষ্ট';

  @override
  String get bkErrPasswordRequired => 'এই ব্যাকআপ খুলতে পাসওয়ার্ড লাগবে';

  @override
  String get bkErrWrongPassword => 'পাসওয়ার্ড ভুল, অথবা ফাইলটি নষ্ট';

  @override
  String get bkErrRolledBack =>
      'রিস্টোর সফল হয়নি। আপনার আগের তথ্য যেমন ছিল তেমনই ফিরিয়ে দেওয়া হয়েছে';

  @override
  String get bkErrNoRollback =>
      'রিস্টোর সফল হয়নি এবং আগের তথ্য নিজে থেকে ফেরানো যায়নি। অ্যাপ বন্ধ করে আবার খুলুন; নিরাপত্তা কপি ফোনে আছে';

  @override
  String get bkBannerNever => 'এখনো ব্যাকআপ নেওয়া হয়নি';

  @override
  String bkBannerOld(String days) {
    return 'সর্বশেষ ব্যাকআপ $days দিন আগে';
  }

  @override
  String get bkBannerAction => 'ব্যাকআপ নিন';

  @override
  String get bkReminderEvery => 'ব্যাকআপের রিমাইন্ডার';

  @override
  String bkReminderDays(String days) {
    return '$days দিন';
  }

  @override
  String get rstTitle => 'সব তথ্য মুছে ফেলুন';

  @override
  String get rstHint =>
      'শিক্ষার্থী, ব্যাচ, পেমেন্ট, উপস্থিতি ও সেটিংস — সব মুছে যাবে';

  @override
  String get rstFirstTitle => 'সব তথ্য মুছে ফেলবেন?';

  @override
  String get rstFirstBody =>
      'এই ফোনের সব তথ্য মুছে যাবে। ব্যাকআপ না নিয়ে থাকলে আর ফেরত পাওয়া যাবে না। মোছার আগে একটি নিরাপত্তা কপি ফোনে রাখা হবে।';

  @override
  String get rstContinue => 'চালিয়ে যান';

  @override
  String get rstSecondTitle => 'শেষবার নিশ্চিত করুন';

  @override
  String rstSecondBody(String word) {
    return 'নিশ্চিত করতে নিচে “$word” লিখুন';
  }

  @override
  String get rstWord => 'মুছুন';

  @override
  String get rstDelete => 'সব মুছে ফেলুন';

  @override
  String get rstDone => 'সব তথ্য মুছে ফেলা হয়েছে';

  @override
  String get rstWorking => 'মোছা হচ্ছে…';

  @override
  String get setAppearance => 'চেহারা ও ভাষা';

  @override
  String get setNumerals => 'সংখ্যার ধরন';

  @override
  String get setNumeralsBangla => 'বাংলা (১২৩)';

  @override
  String get setNumeralsWestern => 'ইংরেজি (123)';

  @override
  String get setGrouping => 'টাকার কমা';

  @override
  String get setGroupingLakh => 'লাখ (১২,৩৪,৫৬৭)';

  @override
  String get setGroupingWestern => 'মিলিয়ন (১,২৩৪,৫৬৭)';

  @override
  String get setTheme => 'থিম';

  @override
  String get setThemeSystem => 'ফোনের মতো';

  @override
  String get setThemeLight => 'হালকা';

  @override
  String get setThemeDark => 'গাঢ়';

  @override
  String get setFees => 'ফি';

  @override
  String get setDefaultDueDay => 'নতুন শিক্ষার্থীর ফি আদায়ের দিন';

  @override
  String setDueDayValue(String day) {
    return 'প্রতি মাসের $day তারিখ';
  }

  @override
  String get setProration => 'যোগদানের মাসের ফি';

  @override
  String get setProrationFull => 'পুরো মাসের ফি';

  @override
  String get setProrationDays => 'দিন হিসাবে আনুপাতিক';

  @override
  String get setProrationNext => 'পরের মাস থেকে';

  @override
  String get setProrationHint =>
      'এখন থেকে যোগ হওয়া শিক্ষার্থীদের জন্য প্রযোজ্য। আগের ফি বদলাবে না।';

  @override
  String get setData => 'তথ্য ও বার্তা';

  @override
  String setAbout(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get obWelcome => 'টিউশন খাতায় স্বাগতম';

  @override
  String get obPickLanguage => 'আপনার ভাষা বেছে নিন';

  @override
  String get obPrivacy => 'আপনার তথ্য এই ফোনেই থাকে। কোনো সাইন-আপ লাগে না।';

  @override
  String get obIntro1Title => 'শিক্ষার্থী';

  @override
  String get obIntro1Body => 'নাম আর ফি দিয়ে এক মিনিটেই শিক্ষার্থী যোগ করুন';

  @override
  String get obIntro2Title => 'হাজিরা';

  @override
  String get obIntro2Body =>
      'সবাই উপস্থিত ধরা থাকে — শুধু অনুপস্থিতদের ছুঁয়ে দিন';

  @override
  String get obIntro3Title => 'ফি ও রসিদ';

  @override
  String get obIntro3Body => 'কার কত বাকি, এক নজরে। পেমেন্ট নিন আর রসিদ পাঠান';

  @override
  String get obSkip => 'এড়িয়ে যান';

  @override
  String get obNext => 'পরের ধাপ';

  @override
  String get obSampleTitle => 'নমুনা তথ্য দিয়ে দেখবেন?';

  @override
  String get obSampleBody =>
      'কয়েকজন উদাহরণ শিক্ষার্থী, হাজিরা ও পেমেন্ট যোগ হবে। এক চাপেই মুছে ফেলা যায়।';

  @override
  String get obSampleYes => 'নমুনা তথ্য যোগ করুন';

  @override
  String get obSampleNo => 'খালি অ্যাপ দিয়ে শুরু করুন';

  @override
  String get obLoading => 'তৈরি করা হচ্ছে…';

  @override
  String get sampleBanner => 'আপনি নমুনা তথ্য দেখছেন';

  @override
  String get sampleRemove => 'নমুনা মুছুন';

  @override
  String get sampleRemoved => 'নমুনা তথ্য মুছে ফেলা হয়েছে';

  @override
  String get sampleLoad => 'নমুনা তথ্য যোগ করুন';

  @override
  String get sampleLoaded => 'নমুনা তথ্য যোগ হয়েছে';

  @override
  String get sampleSettingsHint =>
      'উদাহরণ দিয়ে অ্যাপ ঘুরে দেখুন, এক চাপে মুছে ফেলুন';

  @override
  String get lockEnterPin => 'পিন দিন';

  @override
  String lockWrong(String count) {
    return 'ভুল পিন। অপেক্ষার আগে আর $countটি চেষ্টা বাকি';
  }

  @override
  String lockBlocked(String seconds) {
    return 'অনেকবার ভুল হয়েছে। $seconds সেকেন্ড পরে চেষ্টা করুন';
  }

  @override
  String get lockBiometric => 'আঙুলের ছাপ বা মুখ দিয়ে খুলুন';

  @override
  String get lockBiometricReason => 'টিউশন খাতা খুলুন';

  @override
  String get lockForgot => 'পিন ভুলে গেছেন?';

  @override
  String get lockForgotBody =>
      'পিন ছাড়া অ্যাপ খোলার কোনো উপায় নেই। চাইলে অ্যাপের সব তথ্য মুছে নতুন করে শুরু করতে পারেন; তারপর আগের ব্যাকআপ থেকে তথ্য ফিরিয়ে আনা যাবে। ব্যাকআপ না থাকলে তথ্য আর ফেরত পাওয়া যাবে না।';

  @override
  String get lockSettingsTitle => 'অ্যাপ লক';

  @override
  String get lockSettingsHint => 'পিন দিয়ে অ্যাপ সুরক্ষিত রাখুন';

  @override
  String get lockOn => 'পিন দিয়ে লক';

  @override
  String get lockSetPin => 'পিন ঠিক করুন';

  @override
  String get lockPinHint => '৪ থেকে ৮টি সংখ্যা';

  @override
  String get lockPinAgain => 'পিন আবার দিন';

  @override
  String get lockPinMismatch => 'পিন দুটি মেলেনি';

  @override
  String get lockPinInvalid => '৪ থেকে ৮টি সংখ্যা দিন';

  @override
  String get lockChangePin => 'পিন বদলান';

  @override
  String get lockCurrentPin => 'বর্তমান পিন';

  @override
  String get lockTurnOff => 'লক বন্ধ করুন';

  @override
  String get lockTimeout => 'কতক্ষণ পরে আবার লক হবে';

  @override
  String get lockTimeoutNow => 'সাথে সাথে';

  @override
  String lockTimeoutMinutes(String minutes) {
    return '$minutes মিনিট';
  }

  @override
  String get lockBiometricOn => 'আঙুলের ছাপ বা মুখ দিয়ে খোলা';

  @override
  String get lockBiometricNone => 'এই ফোনে চালু করা নেই';

  @override
  String get lockProtect => 'স্ক্রিনশট ও সাম্প্রতিক অ্যাপের প্রিভিউ আটকান';

  @override
  String get lockOnDone => 'অ্যাপ লক চালু হয়েছে';

  @override
  String get lockOffDone => 'অ্যাপ লক বন্ধ হয়েছে';

  @override
  String get lockRemember =>
      'পিন ভুলে গেলে সব তথ্য মুছে নতুন করে শুরু করতে হবে, তাই নিয়মিত ব্যাকআপ রাখুন।';

  @override
  String get lockWrongCurrent => 'বর্তমান পিন ভুল';
}
