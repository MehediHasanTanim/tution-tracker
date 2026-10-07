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
}
