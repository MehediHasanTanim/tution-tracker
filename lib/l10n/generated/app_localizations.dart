import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In bn, this message translates to:
  /// **'টিউশন খাতা'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In bn, this message translates to:
  /// **'হোম'**
  String get navHome;

  /// No description provided for @navStudents.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী'**
  String get navStudents;

  /// No description provided for @navFees.
  ///
  /// In bn, this message translates to:
  /// **'ফি'**
  String get navFees;

  /// No description provided for @navReports.
  ///
  /// In bn, this message translates to:
  /// **'রিপোর্ট'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস'**
  String get navSettings;

  /// No description provided for @language.
  ///
  /// In bn, this message translates to:
  /// **'ভাষা'**
  String get language;

  /// No description provided for @languageBangla.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// No description provided for @languageEnglish.
  ///
  /// In bn, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @sampleConjuncts.
  ///
  /// In bn, this message translates to:
  /// **'ক্ষমতা, বিজ্ঞান, সংখ্যা, শ্রদ্ধা, দুর্গাপুর'**
  String get sampleConjuncts;

  /// No description provided for @studentsSearchHint.
  ///
  /// In bn, this message translates to:
  /// **'নাম, অভিভাবক বা ফোন দিয়ে খুঁজুন'**
  String get studentsSearchHint;

  /// No description provided for @studentsClearSearch.
  ///
  /// In bn, this message translates to:
  /// **'মুছুন'**
  String get studentsClearSearch;

  /// No description provided for @studentsFilterClass.
  ///
  /// In bn, this message translates to:
  /// **'শ্রেণি'**
  String get studentsFilterClass;

  /// No description provided for @studentsAllClasses.
  ///
  /// In bn, this message translates to:
  /// **'সব শ্রেণি'**
  String get studentsAllClasses;

  /// No description provided for @studentsFilterBatch.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচ'**
  String get studentsFilterBatch;

  /// No description provided for @studentsAllBatches.
  ///
  /// In bn, this message translates to:
  /// **'সব ব্যাচ'**
  String get studentsAllBatches;

  /// No description provided for @statusActive.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয়'**
  String get statusActive;

  /// No description provided for @statusPaused.
  ///
  /// In bn, this message translates to:
  /// **'বিরতিতে'**
  String get statusPaused;

  /// No description provided for @statusArchived.
  ///
  /// In bn, this message translates to:
  /// **'আর্কাইভ'**
  String get statusArchived;

  /// No description provided for @studentsCount.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী: {count}'**
  String studentsCount(String count);

  /// No description provided for @studentsEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'এখনও কোনো শিক্ষার্থী নেই'**
  String get studentsEmptyTitle;

  /// No description provided for @studentsEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম শিক্ষার্থী যোগ করুন'**
  String get studentsEmptyBody;

  /// No description provided for @studentsNoMatch.
  ///
  /// In bn, this message translates to:
  /// **'কোনো শিক্ষার্থী মেলেনি'**
  String get studentsNoMatch;

  /// No description provided for @studentsClearFilters.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার মুছুন'**
  String get studentsClearFilters;

  /// No description provided for @studentsAdd.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী যোগ করুন'**
  String get studentsAdd;

  /// No description provided for @studentProfileTitle.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থীর প্রোফাইল'**
  String get studentProfileTitle;

  /// No description provided for @studentFeePerMonth.
  ///
  /// In bn, this message translates to:
  /// **'{amount} / মাস'**
  String studentFeePerMonth(String amount);

  /// No description provided for @studentEditTitle.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী সম্পাদনা'**
  String get studentEditTitle;

  /// No description provided for @fieldName.
  ///
  /// In bn, this message translates to:
  /// **'নাম'**
  String get fieldName;

  /// No description provided for @fieldMonthlyFee.
  ///
  /// In bn, this message translates to:
  /// **'মাসিক ফি (৳)'**
  String get fieldMonthlyFee;

  /// No description provided for @feeLockedHint.
  ///
  /// In bn, this message translates to:
  /// **'ফি পরিবর্তন করতে ফি সমন্বয় ব্যবহার করুন'**
  String get feeLockedHint;

  /// No description provided for @moreDetails.
  ///
  /// In bn, this message translates to:
  /// **'আরও তথ্য যোগ করুন'**
  String get moreDetails;

  /// No description provided for @fewerDetails.
  ///
  /// In bn, this message translates to:
  /// **'কম তথ্য দেখান'**
  String get fewerDetails;

  /// No description provided for @fieldDueDay.
  ///
  /// In bn, this message translates to:
  /// **'ফি দেওয়ার দিন (মাসের তারিখ)'**
  String get fieldDueDay;

  /// No description provided for @fieldClassLevel.
  ///
  /// In bn, this message translates to:
  /// **'শ্রেণি'**
  String get fieldClassLevel;

  /// No description provided for @fieldSchool.
  ///
  /// In bn, this message translates to:
  /// **'স্কুল / প্রতিষ্ঠান'**
  String get fieldSchool;

  /// No description provided for @fieldGuardianName.
  ///
  /// In bn, this message translates to:
  /// **'অভিভাবকের নাম'**
  String get fieldGuardianName;

  /// No description provided for @fieldGuardianPhone.
  ///
  /// In bn, this message translates to:
  /// **'অভিভাবকের ফোন'**
  String get fieldGuardianPhone;

  /// No description provided for @fieldStudentPhone.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থীর ফোন'**
  String get fieldStudentPhone;

  /// No description provided for @fieldAddress.
  ///
  /// In bn, this message translates to:
  /// **'ঠিকানা / এলাকা'**
  String get fieldAddress;

  /// No description provided for @fieldSubjects.
  ///
  /// In bn, this message translates to:
  /// **'বিষয়'**
  String get fieldSubjects;

  /// No description provided for @fieldOtherSubject.
  ///
  /// In bn, this message translates to:
  /// **'অন্য বিষয় যোগ করুন'**
  String get fieldOtherSubject;

  /// No description provided for @fieldJoinedOn.
  ///
  /// In bn, this message translates to:
  /// **'ভর্তির তারিখ'**
  String get fieldJoinedOn;

  /// No description provided for @fieldClassDays.
  ///
  /// In bn, this message translates to:
  /// **'ক্লাসের দিন'**
  String get fieldClassDays;

  /// No description provided for @fieldClassTime.
  ///
  /// In bn, this message translates to:
  /// **'ক্লাসের সময়'**
  String get fieldClassTime;

  /// No description provided for @fieldNotes.
  ///
  /// In bn, this message translates to:
  /// **'নোট'**
  String get fieldNotes;

  /// No description provided for @actionSave.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ করুন'**
  String get actionSave;

  /// No description provided for @actionClear.
  ///
  /// In bn, this message translates to:
  /// **'মুছুন'**
  String get actionClear;

  /// No description provided for @errorNameRequired.
  ///
  /// In bn, this message translates to:
  /// **'নাম লিখুন'**
  String get errorNameRequired;

  /// No description provided for @errorFeeRequired.
  ///
  /// In bn, this message translates to:
  /// **'মাসিক ফি লিখুন'**
  String get errorFeeRequired;

  /// No description provided for @errorPhoneInvalid.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক মোবাইল নম্বর দিন (যেমন ০১৭১২৩৪৫৬৭৮)'**
  String get errorPhoneInvalid;

  /// No description provided for @studentSaved.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী সংরক্ষিত হয়েছে'**
  String get studentSaved;

  /// No description provided for @none.
  ///
  /// In bn, this message translates to:
  /// **'নেই'**
  String get none;

  /// No description provided for @tabOverview.
  ///
  /// In bn, this message translates to:
  /// **'সারসংক্ষেপ'**
  String get tabOverview;

  /// No description provided for @tabAttendance.
  ///
  /// In bn, this message translates to:
  /// **'উপস্থিতি'**
  String get tabAttendance;

  /// No description provided for @tabFees.
  ///
  /// In bn, this message translates to:
  /// **'ফি'**
  String get tabFees;

  /// No description provided for @tabNotes.
  ///
  /// In bn, this message translates to:
  /// **'নোট'**
  String get tabNotes;

  /// No description provided for @comingSoon.
  ///
  /// In bn, this message translates to:
  /// **'শীঘ্রই আসছে'**
  String get comingSoon;

  /// No description provided for @actionCall.
  ///
  /// In bn, this message translates to:
  /// **'কল'**
  String get actionCall;

  /// No description provided for @actionSms.
  ///
  /// In bn, this message translates to:
  /// **'এসএমএস'**
  String get actionSms;

  /// No description provided for @actionWhatsapp.
  ///
  /// In bn, this message translates to:
  /// **'হোয়াটসঅ্যাপ'**
  String get actionWhatsapp;

  /// No description provided for @noPhoneNumber.
  ///
  /// In bn, this message translates to:
  /// **'ফোন নম্বর নেই'**
  String get noPhoneNumber;

  /// No description provided for @contactLaunchFailed.
  ///
  /// In bn, this message translates to:
  /// **'খুলতে পারেনি। অ্যাপটি ইনস্টল করা আছে কি?'**
  String get contactLaunchFailed;

  /// No description provided for @actionEdit.
  ///
  /// In bn, this message translates to:
  /// **'সম্পাদনা'**
  String get actionEdit;

  /// No description provided for @actionArchive.
  ///
  /// In bn, this message translates to:
  /// **'আর্কাইভ করুন'**
  String get actionArchive;

  /// No description provided for @actionRestore.
  ///
  /// In bn, this message translates to:
  /// **'পুনরুদ্ধার করুন'**
  String get actionRestore;

  /// No description provided for @actionDelete.
  ///
  /// In bn, this message translates to:
  /// **'স্থায়ীভাবে মুছুন'**
  String get actionDelete;

  /// No description provided for @actionCancel.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল'**
  String get actionCancel;

  /// No description provided for @deleteStudentTitle.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী মুছবেন?'**
  String get deleteStudentTitle;

  /// No description provided for @deleteStudentBody.
  ///
  /// In bn, this message translates to:
  /// **'এই শিক্ষার্থীর সব হিসাব (ফি, পেমেন্ট, উপস্থিতি) চিরতরে মুছে যাবে। এটি ফেরানো যাবে না। হিসাব রাখতে চাইলে আর্কাইভ করুন।'**
  String get deleteStudentBody;

  /// No description provided for @studentDeleted.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী মুছে ফেলা হয়েছে'**
  String get studentDeleted;

  /// No description provided for @studentArchived.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী আর্কাইভ করা হয়েছে'**
  String get studentArchived;

  /// No description provided for @studentRestored.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী পুনরুদ্ধার করা হয়েছে'**
  String get studentRestored;

  /// No description provided for @profileMonthlyFee.
  ///
  /// In bn, this message translates to:
  /// **'মাসিক ফি'**
  String get profileMonthlyFee;

  /// No description provided for @profileDueDay.
  ///
  /// In bn, this message translates to:
  /// **'ফি দেওয়ার দিন'**
  String get profileDueDay;

  /// No description provided for @photoAdd.
  ///
  /// In bn, this message translates to:
  /// **'ছবি যোগ করুন'**
  String get photoAdd;

  /// No description provided for @photoChange.
  ///
  /// In bn, this message translates to:
  /// **'ছবি পরিবর্তন করুন'**
  String get photoChange;

  /// No description provided for @photoTake.
  ///
  /// In bn, this message translates to:
  /// **'ছবি তুলুন'**
  String get photoTake;

  /// No description provided for @photoChoose.
  ///
  /// In bn, this message translates to:
  /// **'গ্যালারি থেকে বাছাই করুন'**
  String get photoChoose;

  /// No description provided for @photoRemove.
  ///
  /// In bn, this message translates to:
  /// **'ছবি সরান'**
  String get photoRemove;

  /// No description provided for @photoFailed.
  ///
  /// In bn, this message translates to:
  /// **'ছবিটি ব্যবহার করা গেল না'**
  String get photoFailed;

  /// No description provided for @tabAllStudents.
  ///
  /// In bn, this message translates to:
  /// **'সব শিক্ষার্থী'**
  String get tabAllStudents;

  /// No description provided for @tabBatches.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচসমূহ'**
  String get tabBatches;

  /// No description provided for @batchesAdd.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচ যোগ করুন'**
  String get batchesAdd;

  /// No description provided for @batchEditTitle.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচ সম্পাদনা'**
  String get batchEditTitle;

  /// No description provided for @batchesEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'এখনও কোনো ব্যাচ নেই'**
  String get batchesEmptyTitle;

  /// No description provided for @batchesEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম ব্যাচ তৈরি করুন'**
  String get batchesEmptyBody;

  /// No description provided for @batchShowArchived.
  ///
  /// In bn, this message translates to:
  /// **'আর্কাইভ দেখান'**
  String get batchShowArchived;

  /// No description provided for @batchFieldName.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচের নাম'**
  String get batchFieldName;

  /// No description provided for @batchFieldSubject.
  ///
  /// In bn, this message translates to:
  /// **'বিষয়'**
  String get batchFieldSubject;

  /// No description provided for @batchFieldDuration.
  ///
  /// In bn, this message translates to:
  /// **'সময়কাল (মিনিট)'**
  String get batchFieldDuration;

  /// No description provided for @batchFieldDefaultFee.
  ///
  /// In bn, this message translates to:
  /// **'ডিফল্ট মাসিক ফি (৳)'**
  String get batchFieldDefaultFee;

  /// No description provided for @errorScheduleRequired.
  ///
  /// In bn, this message translates to:
  /// **'অন্তত একটি দিন বাছাই করুন'**
  String get errorScheduleRequired;

  /// No description provided for @errorDurationInvalid.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক সময়কাল দিন'**
  String get errorDurationInvalid;

  /// No description provided for @batchSaved.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচ সংরক্ষিত হয়েছে'**
  String get batchSaved;

  /// No description provided for @batchMemberCount.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য: {count}'**
  String batchMemberCount(String count);

  /// No description provided for @batchMembersTitle.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য'**
  String get batchMembersTitle;

  /// No description provided for @batchNoMembers.
  ///
  /// In bn, this message translates to:
  /// **'এই ব্যাচে এখনও কেউ নেই'**
  String get batchNoMembers;

  /// No description provided for @batchAddMembers.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী যোগ করুন'**
  String get batchAddMembers;

  /// No description provided for @batchNoAddable.
  ///
  /// In bn, this message translates to:
  /// **'যোগ করার মতো আর কোনো শিক্ষার্থী নেই'**
  String get batchNoAddable;

  /// No description provided for @batchAddSelected.
  ///
  /// In bn, this message translates to:
  /// **'{count} জনকে যোগ করুন'**
  String batchAddSelected(String count);

  /// No description provided for @batchMembersAdded.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী যোগ করা হয়েছে'**
  String get batchMembersAdded;

  /// No description provided for @batchMemberFee.
  ///
  /// In bn, this message translates to:
  /// **'ফি: {amount}'**
  String batchMemberFee(String amount);

  /// No description provided for @batchMemberCustomFee.
  ///
  /// In bn, this message translates to:
  /// **'আলাদা ফি'**
  String get batchMemberCustomFee;

  /// No description provided for @batchSetCustomFee.
  ///
  /// In bn, this message translates to:
  /// **'আলাদা ফি নির্ধারণ'**
  String get batchSetCustomFee;

  /// No description provided for @batchCustomFeeLabel.
  ///
  /// In bn, this message translates to:
  /// **'আলাদা মাসিক ফি (৳)'**
  String get batchCustomFeeLabel;

  /// No description provided for @batchCustomFeeHint.
  ///
  /// In bn, this message translates to:
  /// **'ফাঁকা রাখলে ব্যাচের ডিফল্ট ফি প্রযোজ্য'**
  String get batchCustomFeeHint;

  /// No description provided for @batchRemoveMember.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচ থেকে সরান'**
  String get batchRemoveMember;

  /// No description provided for @batchMemberRemoved.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থীকে ব্যাচ থেকে সরানো হয়েছে'**
  String get batchMemberRemoved;

  /// No description provided for @batchArchived.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচ আর্কাইভ করা হয়েছে'**
  String get batchArchived;

  /// No description provided for @batchRestored.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচ পুনরুদ্ধার করা হয়েছে'**
  String get batchRestored;

  /// No description provided for @batchDefaultFee.
  ///
  /// In bn, this message translates to:
  /// **'ডিফল্ট ফি'**
  String get batchDefaultFee;

  /// No description provided for @profileBatches.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচ'**
  String get profileBatches;

  /// No description provided for @feesOutstanding.
  ///
  /// In bn, this message translates to:
  /// **'মোট বাকি'**
  String get feesOutstanding;

  /// No description provided for @feesStudentsOwing.
  ///
  /// In bn, this message translates to:
  /// **'{count} জন বাকি'**
  String feesStudentsOwing(String count);

  /// No description provided for @filterAll.
  ///
  /// In bn, this message translates to:
  /// **'সব'**
  String get filterAll;

  /// No description provided for @filterOverdue.
  ///
  /// In bn, this message translates to:
  /// **'বিলম্বিত'**
  String get filterOverdue;

  /// No description provided for @filterDueWeek.
  ///
  /// In bn, this message translates to:
  /// **'এই সপ্তাহে'**
  String get filterDueWeek;

  /// No description provided for @sortByOverdue.
  ///
  /// In bn, this message translates to:
  /// **'বিলম্ব অনুযায়ী'**
  String get sortByOverdue;

  /// No description provided for @sortByAmount.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণ অনুযায়ী'**
  String get sortByAmount;

  /// No description provided for @feesEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'কারও কোনো বাকি নেই'**
  String get feesEmptyTitle;

  /// No description provided for @feesEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'সব ফি আদায় হয়েছে'**
  String get feesEmptyBody;

  /// No description provided for @feesOpenMonths.
  ///
  /// In bn, this message translates to:
  /// **'{count} মাস বাকি'**
  String feesOpenMonths(String count);

  /// No description provided for @feesOverdueDays.
  ///
  /// In bn, this message translates to:
  /// **'{days} দিন বিলম্ব'**
  String feesOverdueDays(String days);

  /// No description provided for @feesDueOn.
  ///
  /// In bn, this message translates to:
  /// **'শেষ তারিখ {date}'**
  String feesDueOn(String date);

  /// No description provided for @actionRecordPayment.
  ///
  /// In bn, this message translates to:
  /// **'পেমেন্ট নিন'**
  String get actionRecordPayment;

  /// No description provided for @payEditTitle.
  ///
  /// In bn, this message translates to:
  /// **'পেমেন্ট সম্পাদনা'**
  String get payEditTitle;

  /// No description provided for @payAmount.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণ (৳)'**
  String get payAmount;

  /// No description provided for @payOutstanding.
  ///
  /// In bn, this message translates to:
  /// **'মোট বাকি: {amount}'**
  String payOutstanding(String amount);

  /// No description provided for @payCredit.
  ///
  /// In bn, this message translates to:
  /// **'অগ্রিম জমা: {amount}'**
  String payCredit(String amount);

  /// No description provided for @payMonths.
  ///
  /// In bn, this message translates to:
  /// **'কোন মাসের জন্য'**
  String get payMonths;

  /// No description provided for @payMonthsHint.
  ///
  /// In bn, this message translates to:
  /// **'না বাছলে পুরোনো মাস আগে পরিশোধ হবে'**
  String get payMonthsHint;

  /// No description provided for @payMethod.
  ///
  /// In bn, this message translates to:
  /// **'মাধ্যম'**
  String get payMethod;

  /// No description provided for @methodCash.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাশ'**
  String get methodCash;

  /// No description provided for @methodBkash.
  ///
  /// In bn, this message translates to:
  /// **'বিকাশ'**
  String get methodBkash;

  /// No description provided for @methodNagad.
  ///
  /// In bn, this message translates to:
  /// **'নগদ'**
  String get methodNagad;

  /// No description provided for @methodRocket.
  ///
  /// In bn, this message translates to:
  /// **'রকেট'**
  String get methodRocket;

  /// No description provided for @methodBank.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাংক'**
  String get methodBank;

  /// No description provided for @methodOther.
  ///
  /// In bn, this message translates to:
  /// **'অন্যান্য'**
  String get methodOther;

  /// No description provided for @payReference.
  ///
  /// In bn, this message translates to:
  /// **'ট্রানজ্যাকশন আইডি / রেফারেন্স'**
  String get payReference;

  /// No description provided for @payDate.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ'**
  String get payDate;

  /// No description provided for @payBreakdown.
  ///
  /// In bn, this message translates to:
  /// **'যেভাবে প্রয়োগ হবে'**
  String get payBreakdown;

  /// No description provided for @payCreditLine.
  ///
  /// In bn, this message translates to:
  /// **'অগ্রিম জমা'**
  String get payCreditLine;

  /// No description provided for @payAmountRequired.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণ লিখুন'**
  String get payAmountRequired;

  /// No description provided for @paySaved.
  ///
  /// In bn, this message translates to:
  /// **'পেমেন্ট সংরক্ষিত হয়েছে'**
  String get paySaved;

  /// No description provided for @payReceiptNo.
  ///
  /// In bn, this message translates to:
  /// **'রসিদ নং {no}'**
  String payReceiptNo(String no);

  /// No description provided for @payDone.
  ///
  /// In bn, this message translates to:
  /// **'ঠিক আছে'**
  String get payDone;

  /// No description provided for @tabFeesCredit.
  ///
  /// In bn, this message translates to:
  /// **'অগ্রিম জমা'**
  String get tabFeesCredit;

  /// No description provided for @ledgerTitle.
  ///
  /// In bn, this message translates to:
  /// **'মাসওয়ারি হিসাব'**
  String get ledgerTitle;

  /// No description provided for @paymentsTitle.
  ///
  /// In bn, this message translates to:
  /// **'পেমেন্টের ইতিহাস'**
  String get paymentsTitle;

  /// No description provided for @noPayments.
  ///
  /// In bn, this message translates to:
  /// **'কোনো পেমেন্ট নেই'**
  String get noPayments;

  /// No description provided for @noDues.
  ///
  /// In bn, this message translates to:
  /// **'এখনও কোনো ফি তৈরি হয়নি'**
  String get noDues;

  /// No description provided for @statusPaid.
  ///
  /// In bn, this message translates to:
  /// **'পরিশোধিত'**
  String get statusPaid;

  /// No description provided for @statusPartial.
  ///
  /// In bn, this message translates to:
  /// **'আংশিক'**
  String get statusPartial;

  /// No description provided for @statusDue.
  ///
  /// In bn, this message translates to:
  /// **'বাকি'**
  String get statusDue;

  /// No description provided for @statusOverdue.
  ///
  /// In bn, this message translates to:
  /// **'বিলম্বিত'**
  String get statusOverdue;

  /// No description provided for @statusWaived.
  ///
  /// In bn, this message translates to:
  /// **'মওকুফ'**
  String get statusWaived;

  /// No description provided for @ledgerAmounts.
  ///
  /// In bn, this message translates to:
  /// **'ফি {payable} · জমা {paid} · বাকি {balance}'**
  String ledgerAmounts(String payable, String paid, String balance);

  /// No description provided for @ledgerRunning.
  ///
  /// In bn, this message translates to:
  /// **'এ পর্যন্ত মোট বাকি {amount}'**
  String ledgerRunning(String amount);

  /// No description provided for @actionAdjust.
  ///
  /// In bn, this message translates to:
  /// **'ফি সমন্বয়'**
  String get actionAdjust;

  /// No description provided for @adjChangeFee.
  ///
  /// In bn, this message translates to:
  /// **'মাসিক ফি পরিবর্তন'**
  String get adjChangeFee;

  /// No description provided for @adjEffectiveMonth.
  ///
  /// In bn, this message translates to:
  /// **'যে মাস থেকে কার্যকর'**
  String get adjEffectiveMonth;

  /// No description provided for @adjNewFee.
  ///
  /// In bn, this message translates to:
  /// **'নতুন মাসিক ফি (৳)'**
  String get adjNewFee;

  /// No description provided for @adjFeeChanged.
  ///
  /// In bn, this message translates to:
  /// **'ফি পরিবর্তন করা হয়েছে'**
  String get adjFeeChanged;

  /// No description provided for @adjPause.
  ///
  /// In bn, this message translates to:
  /// **'ফি বন্ধ রাখুন'**
  String get adjPause;

  /// No description provided for @adjResume.
  ///
  /// In bn, this message translates to:
  /// **'ফি আবার চালু করুন'**
  String get adjResume;

  /// No description provided for @adjPauseFrom.
  ///
  /// In bn, this message translates to:
  /// **'যে মাস থেকে বন্ধ'**
  String get adjPauseFrom;

  /// No description provided for @adjResumeFrom.
  ///
  /// In bn, this message translates to:
  /// **'যে মাস থেকে চালু'**
  String get adjResumeFrom;

  /// No description provided for @adjPaused.
  ///
  /// In bn, this message translates to:
  /// **'ফি বন্ধ করা হয়েছে'**
  String get adjPaused;

  /// No description provided for @adjResumed.
  ///
  /// In bn, this message translates to:
  /// **'ফি চালু করা হয়েছে'**
  String get adjResumed;

  /// No description provided for @adjOneTime.
  ///
  /// In bn, this message translates to:
  /// **'এককালীন ফি যোগ করুন'**
  String get adjOneTime;

  /// No description provided for @adjOneTimeLabel.
  ///
  /// In bn, this message translates to:
  /// **'বিবরণ (যেমন ভর্তি ফি)'**
  String get adjOneTimeLabel;

  /// No description provided for @adjOneTimeAmount.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণ (৳)'**
  String get adjOneTimeAmount;

  /// No description provided for @adjOneTimeAdded.
  ///
  /// In bn, this message translates to:
  /// **'এককালীন ফি যোগ করা হয়েছে'**
  String get adjOneTimeAdded;

  /// No description provided for @adjWaive.
  ///
  /// In bn, this message translates to:
  /// **'মওকুফ করুন'**
  String get adjWaive;

  /// No description provided for @adjUnwaive.
  ///
  /// In bn, this message translates to:
  /// **'মওকুফ বাতিল করুন'**
  String get adjUnwaive;

  /// No description provided for @adjDiscount.
  ///
  /// In bn, this message translates to:
  /// **'ছাড় দিন'**
  String get adjDiscount;

  /// No description provided for @adjReason.
  ///
  /// In bn, this message translates to:
  /// **'কারণ'**
  String get adjReason;

  /// No description provided for @adjReasonRequired.
  ///
  /// In bn, this message translates to:
  /// **'কারণ লিখুন'**
  String get adjReasonRequired;

  /// No description provided for @adjDiscountAmount.
  ///
  /// In bn, this message translates to:
  /// **'ছাড়ের পরিমাণ (৳)'**
  String get adjDiscountAmount;

  /// No description provided for @adjDone.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষিত হয়েছে'**
  String get adjDone;

  /// No description provided for @payDelete.
  ///
  /// In bn, this message translates to:
  /// **'পেমেন্ট মুছুন'**
  String get payDelete;

  /// No description provided for @payDeleteTitle.
  ///
  /// In bn, this message translates to:
  /// **'পেমেন্ট মুছবেন?'**
  String get payDeleteTitle;

  /// No description provided for @payDeleteBody.
  ///
  /// In bn, this message translates to:
  /// **'রসিদ নং {no} মুছে ফেললে সংশ্লিষ্ট মাসগুলো আবার বাকি হবে। রসিদ নম্বরটি আর ব্যবহার হবে না।'**
  String payDeleteBody(String no);

  /// No description provided for @payReceiptSharedWarning.
  ///
  /// In bn, this message translates to:
  /// **'এই পেমেন্টের রসিদ আগে শেয়ার করা হয়েছে। পরিবর্তন করলে অভিভাবকের কাছে থাকা রসিদের সাথে মিলবে না।'**
  String get payReceiptSharedWarning;

  /// No description provided for @payDeleted.
  ///
  /// In bn, this message translates to:
  /// **'পেমেন্ট মুছে ফেলা হয়েছে'**
  String get payDeleted;

  /// No description provided for @devSection.
  ///
  /// In bn, this message translates to:
  /// **'ডেভেলপার'**
  String get devSection;

  /// No description provided for @devConsistency.
  ///
  /// In bn, this message translates to:
  /// **'হিসাব যাচাই চালান'**
  String get devConsistency;

  /// No description provided for @devConsistencyOk.
  ///
  /// In bn, this message translates to:
  /// **'কোনো সমস্যা পাওয়া যায়নি'**
  String get devConsistencyOk;

  /// No description provided for @devConsistencyIssues.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি সমস্যা পাওয়া গেছে'**
  String devConsistencyIssues(String count);

  /// No description provided for @genericError.
  ///
  /// In bn, this message translates to:
  /// **'কিছু ভুল হয়েছে'**
  String get genericError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
