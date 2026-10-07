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

  /// No description provided for @attStatusPresent.
  ///
  /// In bn, this message translates to:
  /// **'উপস্থিত'**
  String get attStatusPresent;

  /// No description provided for @attStatusAbsent.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিত'**
  String get attStatusAbsent;

  /// No description provided for @attStatusLate.
  ///
  /// In bn, this message translates to:
  /// **'দেরি'**
  String get attStatusLate;

  /// No description provided for @attStatusExcused.
  ///
  /// In bn, this message translates to:
  /// **'ছুটি'**
  String get attStatusExcused;

  /// No description provided for @attMarkAllPresent.
  ///
  /// In bn, this message translates to:
  /// **'সবাইকে উপস্থিত করুন'**
  String get attMarkAllPresent;

  /// No description provided for @attTopic.
  ///
  /// In bn, this message translates to:
  /// **'আজকের পাঠ (ঐচ্ছিক)'**
  String get attTopic;

  /// No description provided for @attSaved.
  ///
  /// In bn, this message translates to:
  /// **'উপস্থিতি সংরক্ষিত হয়েছে'**
  String get attSaved;

  /// No description provided for @attDiscardTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তন সংরক্ষণ করবেন?'**
  String get attDiscardTitle;

  /// No description provided for @attDiscardBody.
  ///
  /// In bn, this message translates to:
  /// **'আপনি উপস্থিতিতে পরিবর্তন করেছেন যা এখনও সংরক্ষিত হয়নি।'**
  String get attDiscardBody;

  /// No description provided for @attDiscard.
  ///
  /// In bn, this message translates to:
  /// **'বাদ দিন'**
  String get attDiscard;

  /// No description provided for @attNoStudents.
  ///
  /// In bn, this message translates to:
  /// **'এই ক্লাসে কোনো শিক্ষার্থী নেই'**
  String get attNoStudents;

  /// No description provided for @attCancelClass.
  ///
  /// In bn, this message translates to:
  /// **'ক্লাস বাতিল করুন'**
  String get attCancelClass;

  /// No description provided for @attHoliday.
  ///
  /// In bn, this message translates to:
  /// **'ছুটির দিন হিসেবে চিহ্নিত করুন'**
  String get attHoliday;

  /// No description provided for @attReason.
  ///
  /// In bn, this message translates to:
  /// **'কারণ (ঐচ্ছিক)'**
  String get attReason;

  /// No description provided for @attRestore.
  ///
  /// In bn, this message translates to:
  /// **'ক্লাস আবার চালু করুন'**
  String get attRestore;

  /// No description provided for @attCancelledBanner.
  ///
  /// In bn, this message translates to:
  /// **'এই ক্লাস বাতিল করা হয়েছে'**
  String get attCancelledBanner;

  /// No description provided for @attHolidayBanner.
  ///
  /// In bn, this message translates to:
  /// **'এই দিন ছুটি'**
  String get attHolidayBanner;

  /// No description provided for @attMarked.
  ///
  /// In bn, this message translates to:
  /// **'চিহ্নিত {done}/{total}'**
  String attMarked(String done, String total);

  /// No description provided for @homeToday.
  ///
  /// In bn, this message translates to:
  /// **'আজ'**
  String get homeToday;

  /// No description provided for @homeClasses.
  ///
  /// In bn, this message translates to:
  /// **'ক্লাস'**
  String get homeClasses;

  /// No description provided for @homeNoClasses.
  ///
  /// In bn, this message translates to:
  /// **'এই দিনে কোনো ক্লাস নেই'**
  String get homeNoClasses;

  /// No description provided for @classNotTaken.
  ///
  /// In bn, this message translates to:
  /// **'নেওয়া হয়নি'**
  String get classNotTaken;

  /// No description provided for @classTaken.
  ///
  /// In bn, this message translates to:
  /// **'নেওয়া হয়েছে'**
  String get classTaken;

  /// No description provided for @classCancelled.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল'**
  String get classCancelled;

  /// No description provided for @classHoliday.
  ///
  /// In bn, this message translates to:
  /// **'ছুটি'**
  String get classHoliday;

  /// No description provided for @classAttended.
  ///
  /// In bn, this message translates to:
  /// **'উপস্থিত {attended}/{total}'**
  String classAttended(String attended, String total);

  /// No description provided for @classExtra.
  ///
  /// In bn, this message translates to:
  /// **'অতিরিক্ত'**
  String get classExtra;

  /// No description provided for @homePrevDay.
  ///
  /// In bn, this message translates to:
  /// **'আগের দিন'**
  String get homePrevDay;

  /// No description provided for @homeNextDay.
  ///
  /// In bn, this message translates to:
  /// **'পরের দিন'**
  String get homeNextDay;

  /// No description provided for @homePickDate.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ বাছুন'**
  String get homePickDate;

  /// No description provided for @homeAddExtra.
  ///
  /// In bn, this message translates to:
  /// **'অতিরিক্ত ক্লাস'**
  String get homeAddExtra;

  /// No description provided for @homeExtraTitle.
  ///
  /// In bn, this message translates to:
  /// **'অতিরিক্ত ক্লাস যোগ করুন'**
  String get homeExtraTitle;

  /// No description provided for @homeExtraBatches.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচ'**
  String get homeExtraBatches;

  /// No description provided for @homeExtraStudents.
  ///
  /// In bn, this message translates to:
  /// **'একক শিক্ষার্থী'**
  String get homeExtraStudents;

  /// No description provided for @homeExtraNone.
  ///
  /// In bn, this message translates to:
  /// **'কিছু পাওয়া যায়নি'**
  String get homeExtraNone;

  /// No description provided for @homeExtraTime.
  ///
  /// In bn, this message translates to:
  /// **'শুরুর সময় (ঐচ্ছিক)'**
  String get homeExtraTime;

  /// No description provided for @homeMonthTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই মাস'**
  String get homeMonthTitle;

  /// No description provided for @homeExpected.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাশিত'**
  String get homeExpected;

  /// No description provided for @homeCollected.
  ///
  /// In bn, this message translates to:
  /// **'আদায়'**
  String get homeCollected;

  /// No description provided for @homeOutstanding.
  ///
  /// In bn, this message translates to:
  /// **'বাকি'**
  String get homeOutstanding;

  /// No description provided for @homeOverdueStudents.
  ///
  /// In bn, this message translates to:
  /// **'{count} জন বিলম্বিত'**
  String homeOverdueStudents(String count);

  /// No description provided for @homeTotalOwed.
  ///
  /// In bn, this message translates to:
  /// **'সব মাস মিলিয়ে বাকি: {amount}'**
  String homeTotalOwed(String amount);

  /// No description provided for @homeUpcoming.
  ///
  /// In bn, this message translates to:
  /// **'এই সপ্তাহে ফি দেওয়ার তারিখ'**
  String get homeUpcoming;

  /// No description provided for @homeUpcomingNone.
  ///
  /// In bn, this message translates to:
  /// **'এই সপ্তাহে কোনো ফি দেওয়ার তারিখ নেই'**
  String get homeUpcomingNone;

  /// No description provided for @homeSeeAll.
  ///
  /// In bn, this message translates to:
  /// **'সব দেখুন'**
  String get homeSeeAll;

  /// No description provided for @attClassesCount.
  ///
  /// In bn, this message translates to:
  /// **'মোট ক্লাস'**
  String get attClassesCount;

  /// No description provided for @attRate.
  ///
  /// In bn, this message translates to:
  /// **'হার'**
  String get attRate;

  /// No description provided for @attNoClasses.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসে কোনো ক্লাসের তথ্য নেই'**
  String get attNoClasses;

  /// No description provided for @calPrevMonth.
  ///
  /// In bn, this message translates to:
  /// **'আগের মাস'**
  String get calPrevMonth;

  /// No description provided for @calNextMonth.
  ///
  /// In bn, this message translates to:
  /// **'পরের মাস'**
  String get calNextMonth;

  /// No description provided for @attShare.
  ///
  /// In bn, this message translates to:
  /// **'অভিভাবকের জন্য শেয়ার করুন'**
  String get attShare;

  /// No description provided for @shareAttTitle.
  ///
  /// In bn, this message translates to:
  /// **'{name} — {month}-এর উপস্থিতি'**
  String shareAttTitle(String name, String month);

  /// No description provided for @shareAttClasses.
  ///
  /// In bn, this message translates to:
  /// **'মোট ক্লাস: {count}'**
  String shareAttClasses(String count);

  /// No description provided for @shareAttBreakdown.
  ///
  /// In bn, this message translates to:
  /// **'উপস্থিত {present} · দেরি {late} · অনুপস্থিত {absent} · ছুটি {excused}'**
  String shareAttBreakdown(
    String present,
    String late,
    String absent,
    String excused,
  );

  /// No description provided for @shareAttRate.
  ///
  /// In bn, this message translates to:
  /// **'উপস্থিতির হার: {percent}'**
  String shareAttRate(String percent);

  /// No description provided for @shareAttNone.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসে কোনো ক্লাস হয়নি'**
  String get shareAttNone;

  /// No description provided for @shareFooter.
  ///
  /// In bn, this message translates to:
  /// **'— {name}'**
  String shareFooter(String name);

  /// No description provided for @reportCollectionRate.
  ///
  /// In bn, this message translates to:
  /// **'আদায়ের হার'**
  String get reportCollectionRate;

  /// No description provided for @reportCash.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসে হাতে পাওয়া'**
  String get reportCash;

  /// No description provided for @reportBatches.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাচ অনুযায়ী'**
  String get reportBatches;

  /// No description provided for @reportNoBatch.
  ///
  /// In bn, this message translates to:
  /// **'কোনো ব্যাচ নয়'**
  String get reportNoBatch;

  /// No description provided for @reportStudents.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী: {count}'**
  String reportStudents(String count);

  /// No description provided for @reportAttendance.
  ///
  /// In bn, this message translates to:
  /// **'উপস্থিতি {percent}'**
  String reportAttendance(String percent);

  /// No description provided for @reportNote.
  ///
  /// In bn, this message translates to:
  /// **'একাধিক ব্যাচের শিক্ষার্থী প্রথম যে ব্যাচে যোগ দিয়েছেন সেখানে গোনা হয়।'**
  String get reportNote;

  /// No description provided for @reportIncomeTitle.
  ///
  /// In bn, this message translates to:
  /// **'মাসওয়ারি আয় (শেষ ১২ মাস)'**
  String get reportIncomeTitle;

  /// No description provided for @reportNoData.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসে কোনো তথ্য নেই'**
  String get reportNoData;

  /// No description provided for @receiptTitle.
  ///
  /// In bn, this message translates to:
  /// **'রসিদ'**
  String get receiptTitle;

  /// No description provided for @receiptAction.
  ///
  /// In bn, this message translates to:
  /// **'রসিদ'**
  String get receiptAction;

  /// No description provided for @receiptShareAction.
  ///
  /// In bn, this message translates to:
  /// **'রসিদ শেয়ার করুন'**
  String get receiptShareAction;

  /// No description provided for @receiptStudent.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী'**
  String get receiptStudent;

  /// No description provided for @receiptGuardian.
  ///
  /// In bn, this message translates to:
  /// **'অভিভাবক'**
  String get receiptGuardian;

  /// No description provided for @receiptFor.
  ///
  /// In bn, this message translates to:
  /// **'যে মাসের জন্য'**
  String get receiptFor;

  /// No description provided for @receiptTotal.
  ///
  /// In bn, this message translates to:
  /// **'মোট জমা'**
  String get receiptTotal;

  /// No description provided for @receiptThanks.
  ///
  /// In bn, this message translates to:
  /// **'ধন্যবাদ'**
  String get receiptThanks;

  /// No description provided for @receiptShareImage.
  ///
  /// In bn, this message translates to:
  /// **'ছবি হিসেবে শেয়ার করুন'**
  String get receiptShareImage;

  /// No description provided for @receiptSharePdf.
  ///
  /// In bn, this message translates to:
  /// **'PDF হিসেবে শেয়ার করুন'**
  String get receiptSharePdf;

  /// No description provided for @receiptShareFailed.
  ///
  /// In bn, this message translates to:
  /// **'শেয়ার করা যায়নি'**
  String get receiptShareFailed;

  /// No description provided for @tutorSection.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষকের তথ্য'**
  String get tutorSection;

  /// No description provided for @tutorSectionHint.
  ///
  /// In bn, this message translates to:
  /// **'রসিদ ও শেয়ার করা বার্তায় দেখানো হবে'**
  String get tutorSectionHint;

  /// No description provided for @tutorName.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষকের নাম'**
  String get tutorName;

  /// No description provided for @tutorInstitution.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিষ্ঠানের নাম'**
  String get tutorInstitution;

  /// No description provided for @tutorPhone.
  ///
  /// In bn, this message translates to:
  /// **'ফোন নম্বর'**
  String get tutorPhone;

  /// No description provided for @chClasses.
  ///
  /// In bn, this message translates to:
  /// **'ক্লাসের রিমাইন্ডার'**
  String get chClasses;

  /// No description provided for @chClassesAbout.
  ///
  /// In bn, this message translates to:
  /// **'ক্লাস শুরুর আগে মনে করিয়ে দেয়'**
  String get chClassesAbout;

  /// No description provided for @chFees.
  ///
  /// In bn, this message translates to:
  /// **'ফি-র রিমাইন্ডার'**
  String get chFees;

  /// No description provided for @chFeesAbout.
  ///
  /// In bn, this message translates to:
  /// **'যেদিন ফি আদায়ের দিন'**
  String get chFeesAbout;

  /// No description provided for @chSummary.
  ///
  /// In bn, this message translates to:
  /// **'সাপ্তাহিক সারসংক্ষেপ'**
  String get chSummary;

  /// No description provided for @chSummaryAbout.
  ///
  /// In bn, this message translates to:
  /// **'সপ্তাহের বাকি টাকার হিসাব'**
  String get chSummaryAbout;

  /// No description provided for @chBackup.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপ রিমাইন্ডার'**
  String get chBackup;

  /// No description provided for @chBackupAbout.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপ নেওয়ার কথা মনে করায়'**
  String get chBackupAbout;

  /// No description provided for @remClassTitle.
  ///
  /// In bn, this message translates to:
  /// **'ক্লাস: {name}'**
  String remClassTitle(String name);

  /// No description provided for @remClassBody.
  ///
  /// In bn, this message translates to:
  /// **'শুরু {time}'**
  String remClassBody(String time);

  /// No description provided for @remFeesTitle.
  ///
  /// In bn, this message translates to:
  /// **'আজ {count} জনের ফি আদায়ের দিন'**
  String remFeesTitle(String count);

  /// No description provided for @remFeesBody.
  ///
  /// In bn, this message translates to:
  /// **'মোট বাকি {amount}'**
  String remFeesBody(String amount);

  /// No description provided for @remWeeklyTitle.
  ///
  /// In bn, this message translates to:
  /// **'সাপ্তাহিক বাকির হিসাব'**
  String get remWeeklyTitle;

  /// No description provided for @remWeeklyBody.
  ///
  /// In bn, this message translates to:
  /// **'{count} জনের কাছে মোট {amount} বাকি'**
  String remWeeklyBody(String count, String amount);

  /// No description provided for @remBackupTitle.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপ নেওয়ার সময় হয়েছে'**
  String get remBackupTitle;

  /// No description provided for @remBackupBody.
  ///
  /// In bn, this message translates to:
  /// **'তথ্য নিরাপদ রাখতে এখনই ব্যাকআপ নিন'**
  String get remBackupBody;

  /// No description provided for @remKeepOnTitle.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার চালু রাখুন'**
  String get remKeepOnTitle;

  /// No description provided for @remKeepOnBody.
  ///
  /// In bn, this message translates to:
  /// **'পরবর্তী দুই সপ্তাহের রিমাইন্ডারের জন্য অ্যাপটি একবার খুলুন'**
  String get remKeepOnBody;

  /// No description provided for @remTestTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরীক্ষামূলক নোটিফিকেশন'**
  String get remTestTitle;

  /// No description provided for @remTestBody.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার ঠিকমতো কাজ করছে'**
  String get remTestBody;

  /// No description provided for @remPermTitle.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার চালু করুন'**
  String get remPermTitle;

  /// No description provided for @remPermWhy.
  ///
  /// In bn, this message translates to:
  /// **'ক্লাস শুরুর আগে এবং ফি আদায়ের দিনে আপনাকে মনে করিয়ে দিতে অ্যাপের নোটিফিকেশন পাঠানোর অনুমতি দরকার। আপনার তথ্য ফোনের বাইরে যায় না।'**
  String get remPermWhy;

  /// No description provided for @remPermAllow.
  ///
  /// In bn, this message translates to:
  /// **'অনুমতি দিন'**
  String get remPermAllow;

  /// No description provided for @remPermNotNow.
  ///
  /// In bn, this message translates to:
  /// **'এখন নয়'**
  String get remPermNotNow;

  /// No description provided for @remPermDenied.
  ///
  /// In bn, this message translates to:
  /// **'নোটিফিকেশনের অনুমতি দেওয়া হয়নি, তাই রিমাইন্ডার পাঠানো যাবে না। ফোনের সেটিংস থেকে অনুমতি দিলে রিমাইন্ডার কাজ করবে।'**
  String get remPermDenied;

  /// No description provided for @remPermOpenSettings.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস খুলুন'**
  String get remPermOpenSettings;

  /// No description provided for @remPermGranted.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার চালু হয়েছে'**
  String get remPermGranted;

  /// No description provided for @remTestSend.
  ///
  /// In bn, this message translates to:
  /// **'পরীক্ষামূলক নোটিফিকেশন পাঠান'**
  String get remTestSend;

  /// No description provided for @oemTitle.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাটারি সেটিংস'**
  String get oemTitle;

  /// No description provided for @oemIntro.
  ///
  /// In bn, this message translates to:
  /// **'কিছু ফোন ব্যাটারি বাঁচাতে অ্যাপ বন্ধ করে দেয়, তাতে রিমাইন্ডার আসে না। নিচের ধাপগুলো একবার করে নিন।'**
  String get oemIntro;

  /// No description provided for @oemDetected.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ফোন: {maker}'**
  String oemDetected(String maker);

  /// No description provided for @oemMakerXiaomi.
  ///
  /// In bn, this message translates to:
  /// **'Xiaomi / Redmi / POCO'**
  String get oemMakerXiaomi;

  /// No description provided for @oemMakerOppo.
  ///
  /// In bn, this message translates to:
  /// **'Oppo / OnePlus'**
  String get oemMakerOppo;

  /// No description provided for @oemMakerVivo.
  ///
  /// In bn, this message translates to:
  /// **'Vivo / iQOO'**
  String get oemMakerVivo;

  /// No description provided for @oemMakerRealme.
  ///
  /// In bn, this message translates to:
  /// **'Realme'**
  String get oemMakerRealme;

  /// No description provided for @oemMakerSamsung.
  ///
  /// In bn, this message translates to:
  /// **'Samsung'**
  String get oemMakerSamsung;

  /// No description provided for @oemMakerOther.
  ///
  /// In bn, this message translates to:
  /// **'অন্যান্য ফোন'**
  String get oemMakerOther;

  /// No description provided for @oemStepsXiaomi.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস › অ্যাপস › অ্যাপ ম্যানেজ › টিউশন খাতা খুলুন\n“অটোস্টার্ট” চালু করুন\n“ব্যাটারি সেভার” থেকে “কোনো সীমাবদ্ধতা নেই” বেছে নিন'**
  String get oemStepsXiaomi;

  /// No description provided for @oemStepsOppo.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস › ব্যাটারি › অ্যাপ ব্যাটারি ম্যানেজমেন্ট › টিউশন খাতা খুলুন\n“ব্যাকগ্রাউন্ডে চলার অনুমতি” চালু করুন\n“অটো-লঞ্চ” চালু করুন'**
  String get oemStepsOppo;

  /// No description provided for @oemStepsVivo.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস › ব্যাটারি › ব্যাকগ্রাউন্ড পাওয়ার ব্যবহার › টিউশন খাতা খুলুন\n“উচ্চ ব্যাকগ্রাউন্ড পাওয়ার ব্যবহার” অনুমোদন করুন\n“অটোস্টার্ট” চালু করুন'**
  String get oemStepsVivo;

  /// No description provided for @oemStepsRealme.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস › ব্যাটারি › অ্যাপ ব্যাটারি ম্যানেজমেন্ট › টিউশন খাতা খুলুন\n“ব্যাকগ্রাউন্ডে চলার অনুমতি” চালু করুন\n“অটো-লঞ্চ” চালু করুন'**
  String get oemStepsRealme;

  /// No description provided for @oemStepsSamsung.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস › ব্যাটারি › ব্যাকগ্রাউন্ড ব্যবহারের সীমা খুলুন\n“কখনো ঘুমায় না এমন অ্যাপ” তালিকায় টিউশন খাতা যোগ করুন'**
  String get oemStepsSamsung;

  /// No description provided for @oemStepsOther.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস › অ্যাপস › টিউশন খাতা › ব্যাটারি খুলুন\n“সীমাবদ্ধতা নেই” বা “অপ্টিমাইজ করবেন না” বেছে নিন'**
  String get oemStepsOther;

  /// No description provided for @oemOpenBattery.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাটারি সেটিংস খুলুন'**
  String get oemOpenBattery;

  /// No description provided for @oemDone.
  ///
  /// In bn, this message translates to:
  /// **'বুঝেছি'**
  String get oemDone;

  /// No description provided for @remHealth.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডারের অবস্থা'**
  String get remHealth;

  /// No description provided for @remHealthOff.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ আছে'**
  String get remHealthOff;

  /// No description provided for @remHealthBlocked.
  ///
  /// In bn, this message translates to:
  /// **'নোটিফিকেশন বন্ধ করা আছে'**
  String get remHealthBlocked;

  /// No description provided for @remHealthOk.
  ///
  /// In bn, this message translates to:
  /// **'ঠিক আছে — {count}টি রিমাইন্ডার নির্ধারিত'**
  String remHealthOk(String count);

  /// No description provided for @remHealthNone.
  ///
  /// In bn, this message translates to:
  /// **'এখন কোনো রিমাইন্ডার নির্ধারিত নেই'**
  String get remHealthNone;

  /// No description provided for @remHealthGuide.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাটারি গাইড দেখুন'**
  String get remHealthGuide;

  /// No description provided for @remHealthTapEnable.
  ///
  /// In bn, this message translates to:
  /// **'চালু করতে এখানে চাপুন'**
  String get remHealthTapEnable;

  /// No description provided for @remSettingsTitle.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার'**
  String get remSettingsTitle;

  /// No description provided for @remMasterTitle.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার'**
  String get remMasterTitle;

  /// No description provided for @remMasterHint.
  ///
  /// In bn, this message translates to:
  /// **'ক্লাস, ফি ও ব্যাকআপের কথা মনে করিয়ে দেবে'**
  String get remMasterHint;

  /// No description provided for @remClassOn.
  ///
  /// In bn, this message translates to:
  /// **'ক্লাস শুরুর আগে'**
  String get remClassOn;

  /// No description provided for @remMinutes.
  ///
  /// In bn, this message translates to:
  /// **'{minutes} মিনিট আগে'**
  String remMinutes(String minutes);

  /// No description provided for @remFeeOn.
  ///
  /// In bn, this message translates to:
  /// **'ফি আদায়ের দিনে'**
  String get remFeeOn;

  /// No description provided for @remAt.
  ///
  /// In bn, this message translates to:
  /// **'সময়: {time}'**
  String remAt(String time);

  /// No description provided for @remWeeklyOn.
  ///
  /// In bn, this message translates to:
  /// **'সাপ্তাহিক বাকির হিসাব'**
  String get remWeeklyOn;

  /// No description provided for @remWeeklyWhen.
  ///
  /// In bn, this message translates to:
  /// **'{day}, {time}'**
  String remWeeklyWhen(String day, String time);

  /// No description provided for @remBackupOn.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপের রিমাইন্ডার'**
  String get remBackupOn;

  /// No description provided for @remBackupAfter.
  ///
  /// In bn, this message translates to:
  /// **'{days} দিনের বেশি পুরনো হলে'**
  String remBackupAfter(String days);

  /// No description provided for @remTestSent.
  ///
  /// In bn, this message translates to:
  /// **'পরীক্ষামূলক নোটিফিকেশন পাঠানো হয়েছে'**
  String get remTestSent;

  /// No description provided for @tplTitle.
  ///
  /// In bn, this message translates to:
  /// **'মেসেজ টেমপ্লেট'**
  String get tplTitle;

  /// No description provided for @tplFeeReminder.
  ///
  /// In bn, this message translates to:
  /// **'ফি-র রিমাইন্ডার'**
  String get tplFeeReminder;

  /// No description provided for @tplPreview.
  ///
  /// In bn, this message translates to:
  /// **'প্রিভিউ'**
  String get tplPreview;

  /// No description provided for @tplVariables.
  ///
  /// In bn, this message translates to:
  /// **'ভেরিয়েবল (চাপলে যোগ হবে)'**
  String get tplVariables;

  /// No description provided for @tplReset.
  ///
  /// In bn, this message translates to:
  /// **'ডিফল্টে ফিরুন'**
  String get tplReset;

  /// No description provided for @tplSaved.
  ///
  /// In bn, this message translates to:
  /// **'টেমপ্লেট সংরক্ষিত হয়েছে'**
  String get tplSaved;

  /// No description provided for @tplEmpty.
  ///
  /// In bn, this message translates to:
  /// **'টেমপ্লেট খালি রাখা যাবে না'**
  String get tplEmpty;

  /// No description provided for @tplBodyLabel.
  ///
  /// In bn, this message translates to:
  /// **'মেসেজের লেখা'**
  String get tplBodyLabel;

  /// No description provided for @tplSampleStudent.
  ///
  /// In bn, this message translates to:
  /// **'রহিম'**
  String get tplSampleStudent;

  /// No description provided for @tplVarStudent.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থীর নাম'**
  String get tplVarStudent;

  /// No description provided for @tplVarGuardian.
  ///
  /// In bn, this message translates to:
  /// **'অভিভাবকের নাম'**
  String get tplVarGuardian;

  /// No description provided for @tplVarMonth.
  ///
  /// In bn, this message translates to:
  /// **'মাস'**
  String get tplVarMonth;

  /// No description provided for @tplVarAmount.
  ///
  /// In bn, this message translates to:
  /// **'বাকি টাকা'**
  String get tplVarAmount;

  /// No description provided for @tplVarDue.
  ///
  /// In bn, this message translates to:
  /// **'নির্ধারিত তারিখ'**
  String get tplVarDue;

  /// No description provided for @tplVarMonths.
  ///
  /// In bn, this message translates to:
  /// **'বাকি মাসের সংখ্যা'**
  String get tplVarMonths;

  /// No description provided for @tplVarTutor.
  ///
  /// In bn, this message translates to:
  /// **'আপনার নাম'**
  String get tplVarTutor;

  /// No description provided for @tplVarInstitution.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিষ্ঠান'**
  String get tplVarInstitution;

  /// No description provided for @tplVarSignature.
  ///
  /// In bn, this message translates to:
  /// **'সই (— আপনার নাম)'**
  String get tplVarSignature;

  /// No description provided for @remindGuardian.
  ///
  /// In bn, this message translates to:
  /// **'অভিভাবককে রিমাইন্ডার'**
  String get remindGuardian;

  /// No description provided for @remindSms.
  ///
  /// In bn, this message translates to:
  /// **'SMS'**
  String get remindSms;

  /// No description provided for @remindWhatsApp.
  ///
  /// In bn, this message translates to:
  /// **'WhatsApp'**
  String get remindWhatsApp;

  /// No description provided for @remindNoPhone.
  ///
  /// In bn, this message translates to:
  /// **'এই শিক্ষার্থীর ফোন নম্বর নেই'**
  String get remindNoPhone;

  /// No description provided for @remindEditHint.
  ///
  /// In bn, this message translates to:
  /// **'পাঠানোর আগে লেখা বদলাতে পারেন'**
  String get remindEditHint;

  /// No description provided for @remindEditTemplate.
  ///
  /// In bn, this message translates to:
  /// **'টেমপ্লেট বদলান'**
  String get remindEditTemplate;

  /// No description provided for @remindBulkTitle.
  ///
  /// In bn, this message translates to:
  /// **'সবাইকে রিমাইন্ডার'**
  String get remindBulkTitle;

  /// No description provided for @remindBulkProgress.
  ///
  /// In bn, this message translates to:
  /// **'{done}/{total} জন সম্পন্ন'**
  String remindBulkProgress(String done, String total);

  /// No description provided for @remindMarkDone.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ড করা হয়েছে'**
  String get remindMarkDone;

  /// No description provided for @remindSkip.
  ///
  /// In bn, this message translates to:
  /// **'বাদ দিন'**
  String get remindSkip;

  /// No description provided for @remindUndo.
  ///
  /// In bn, this message translates to:
  /// **'ফিরিয়ে নিন'**
  String get remindUndo;

  /// No description provided for @remindMarked.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ড হিসেবে চিহ্নিত করা হয়েছে'**
  String get remindMarked;

  /// No description provided for @remindDoneAll.
  ///
  /// In bn, this message translates to:
  /// **'সবাইকে রিমাইন্ড করা হয়েছে'**
  String get remindDoneAll;

  /// No description provided for @remindNothing.
  ///
  /// In bn, this message translates to:
  /// **'কেউ মেয়াদ পেরিয়ে বাকি নেই'**
  String get remindNothing;

  /// No description provided for @remindLast.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ রিমাইন্ড: {date}'**
  String remindLast(String date);

  /// No description provided for @remindReminded.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ড করা হয়েছে'**
  String get remindReminded;

  /// No description provided for @remindClear.
  ///
  /// In bn, this message translates to:
  /// **'চিহ্ন মুছে আবার শুরু করুন'**
  String get remindClear;

  /// No description provided for @remindNext.
  ///
  /// In bn, this message translates to:
  /// **'পরের জন'**
  String get remindNext;

  /// No description provided for @remindPrevious.
  ///
  /// In bn, this message translates to:
  /// **'আগের জন'**
  String get remindPrevious;

  /// No description provided for @remindAwaiting.
  ///
  /// In bn, this message translates to:
  /// **'মেসেজ পাঠানো হলে “রিমাইন্ড করা হয়েছে” চাপুন'**
  String get remindAwaiting;

  /// No description provided for @bkTitle.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপ ও রিস্টোর'**
  String get bkTitle;

  /// No description provided for @bkLast.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ ব্যাকআপ: {when}'**
  String bkLast(String when);

  /// No description provided for @bkNever.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো ব্যাকআপ নেওয়া হয়নি'**
  String get bkNever;

  /// No description provided for @bkPrivacy.
  ///
  /// In bn, this message translates to:
  /// **'আপনার তথ্য এই ফোনেই থাকে। নিয়মিত ব্যাকআপ নিন।'**
  String get bkPrivacy;

  /// No description provided for @bkNow.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপ নিন'**
  String get bkNow;

  /// No description provided for @bkEncrypt.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড দিয়ে সুরক্ষিত করুন'**
  String get bkEncrypt;

  /// No description provided for @bkEncryptHint.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপে শিক্ষার্থী ও অভিভাবকের তথ্য থাকে। পাসওয়ার্ড ভুলে গেলে ফাইল খোলা যাবে না।'**
  String get bkEncryptHint;

  /// No description provided for @bkPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড'**
  String get bkPassword;

  /// No description provided for @bkPasswordConfirm.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড আবার লিখুন'**
  String get bkPasswordConfirm;

  /// No description provided for @bkPasswordMismatch.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড দুটি মেলেনি'**
  String get bkPasswordMismatch;

  /// No description provided for @bkPasswordShort.
  ///
  /// In bn, this message translates to:
  /// **'কমপক্ষে ৬টি অক্ষর দিন'**
  String get bkPasswordShort;

  /// No description provided for @bkWorking.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপ তৈরি হচ্ছে…'**
  String get bkWorking;

  /// No description provided for @bkFailed.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপ তৈরি করা যায়নি'**
  String get bkFailed;

  /// No description provided for @bkSavedHint.
  ///
  /// In bn, this message translates to:
  /// **'ফাইলটি নিরাপদ জায়গায় (Google Drive, ইমেইল বা অন্য ফোনে) পাঠিয়ে রাখুন'**
  String get bkSavedHint;

  /// No description provided for @bkRestore.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপ থেকে রিস্টোর'**
  String get bkRestore;

  /// No description provided for @bkRestoreHint.
  ///
  /// In bn, this message translates to:
  /// **'বর্তমান সব তথ্য ব্যাকআপের তথ্য দিয়ে বদলে যাবে'**
  String get bkRestoreHint;

  /// No description provided for @rsEnterPassword.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপের পাসওয়ার্ড দিন'**
  String get rsEnterPassword;

  /// No description provided for @rsChecking.
  ///
  /// In bn, this message translates to:
  /// **'ফাইল যাচাই করা হচ্ছে…'**
  String get rsChecking;

  /// No description provided for @rsPreviewTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই ব্যাকআপ রিস্টোর করবেন?'**
  String get rsPreviewTitle;

  /// No description provided for @rsPreviewStudents.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী: {count}'**
  String rsPreviewStudents(String count);

  /// No description provided for @rsPreviewPayments.
  ///
  /// In bn, this message translates to:
  /// **'পেমেন্ট: {count}'**
  String rsPreviewPayments(String count);

  /// No description provided for @rsPreviewLatest.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ পেমেন্ট: {date}'**
  String rsPreviewLatest(String date);

  /// No description provided for @rsPreviewDate.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপের তারিখ: {date}'**
  String rsPreviewDate(String date);

  /// No description provided for @rsPreviewNoPayments.
  ///
  /// In bn, this message translates to:
  /// **'কোনো পেমেন্ট নেই'**
  String get rsPreviewNoPayments;

  /// No description provided for @rsWarn.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনের বর্তমান সব তথ্য মুছে ব্যাকআপের তথ্য বসবে। তার আগে একটি নিরাপত্তা কপি রাখা হবে।'**
  String get rsWarn;

  /// No description provided for @rsConfirm.
  ///
  /// In bn, this message translates to:
  /// **'রিস্টোর করুন'**
  String get rsConfirm;

  /// No description provided for @rsWorking.
  ///
  /// In bn, this message translates to:
  /// **'রিস্টোর হচ্ছে… অ্যাপ বন্ধ করবেন না'**
  String get rsWorking;

  /// No description provided for @rsDone.
  ///
  /// In bn, this message translates to:
  /// **'রিস্টোর সম্পন্ন হয়েছে'**
  String get rsDone;

  /// No description provided for @bkErrNotABackup.
  ///
  /// In bn, this message translates to:
  /// **'এটি টিউশন খাতার ব্যাকআপ ফাইল নয়'**
  String get bkErrNotABackup;

  /// No description provided for @bkErrDamaged.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপ ফাইলটি নষ্ট বা অসম্পূর্ণ'**
  String get bkErrDamaged;

  /// No description provided for @bkErrNewer.
  ///
  /// In bn, this message translates to:
  /// **'এই ব্যাকআপ অ্যাপের নতুন সংস্করণে তৈরি। আগে অ্যাপ আপডেট করুন'**
  String get bkErrNewer;

  /// No description provided for @bkErrChecksum.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপের ভেতরের ফাইল বদলে গেছে বা নষ্ট হয়েছে'**
  String get bkErrChecksum;

  /// No description provided for @bkErrIntegrity.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপের ডাটাবেস নষ্ট'**
  String get bkErrIntegrity;

  /// No description provided for @bkErrPasswordRequired.
  ///
  /// In bn, this message translates to:
  /// **'এই ব্যাকআপ খুলতে পাসওয়ার্ড লাগবে'**
  String get bkErrPasswordRequired;

  /// No description provided for @bkErrWrongPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড ভুল, অথবা ফাইলটি নষ্ট'**
  String get bkErrWrongPassword;

  /// No description provided for @bkErrRolledBack.
  ///
  /// In bn, this message translates to:
  /// **'রিস্টোর সফল হয়নি। আপনার আগের তথ্য যেমন ছিল তেমনই ফিরিয়ে দেওয়া হয়েছে'**
  String get bkErrRolledBack;

  /// No description provided for @bkErrNoRollback.
  ///
  /// In bn, this message translates to:
  /// **'রিস্টোর সফল হয়নি এবং আগের তথ্য নিজে থেকে ফেরানো যায়নি। অ্যাপ বন্ধ করে আবার খুলুন; নিরাপত্তা কপি ফোনে আছে'**
  String get bkErrNoRollback;

  /// No description provided for @bkBannerNever.
  ///
  /// In bn, this message translates to:
  /// **'এখনো ব্যাকআপ নেওয়া হয়নি'**
  String get bkBannerNever;

  /// No description provided for @bkBannerOld.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ ব্যাকআপ {days} দিন আগে'**
  String bkBannerOld(String days);

  /// No description provided for @bkBannerAction.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপ নিন'**
  String get bkBannerAction;

  /// No description provided for @bkReminderEvery.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাকআপের রিমাইন্ডার'**
  String get bkReminderEvery;

  /// No description provided for @bkReminderDays.
  ///
  /// In bn, this message translates to:
  /// **'{days} দিন'**
  String bkReminderDays(String days);

  /// No description provided for @rstTitle.
  ///
  /// In bn, this message translates to:
  /// **'সব তথ্য মুছে ফেলুন'**
  String get rstTitle;

  /// No description provided for @rstHint.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী, ব্যাচ, পেমেন্ট, উপস্থিতি ও সেটিংস — সব মুছে যাবে'**
  String get rstHint;

  /// No description provided for @rstFirstTitle.
  ///
  /// In bn, this message translates to:
  /// **'সব তথ্য মুছে ফেলবেন?'**
  String get rstFirstTitle;

  /// No description provided for @rstFirstBody.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনের সব তথ্য মুছে যাবে। ব্যাকআপ না নিয়ে থাকলে আর ফেরত পাওয়া যাবে না। মোছার আগে একটি নিরাপত্তা কপি ফোনে রাখা হবে।'**
  String get rstFirstBody;

  /// No description provided for @rstContinue.
  ///
  /// In bn, this message translates to:
  /// **'চালিয়ে যান'**
  String get rstContinue;

  /// No description provided for @rstSecondTitle.
  ///
  /// In bn, this message translates to:
  /// **'শেষবার নিশ্চিত করুন'**
  String get rstSecondTitle;

  /// No description provided for @rstSecondBody.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত করতে নিচে “{word}” লিখুন'**
  String rstSecondBody(String word);

  /// No description provided for @rstWord.
  ///
  /// In bn, this message translates to:
  /// **'মুছুন'**
  String get rstWord;

  /// No description provided for @rstDelete.
  ///
  /// In bn, this message translates to:
  /// **'সব মুছে ফেলুন'**
  String get rstDelete;

  /// No description provided for @rstDone.
  ///
  /// In bn, this message translates to:
  /// **'সব তথ্য মুছে ফেলা হয়েছে'**
  String get rstDone;

  /// No description provided for @rstWorking.
  ///
  /// In bn, this message translates to:
  /// **'মোছা হচ্ছে…'**
  String get rstWorking;

  /// No description provided for @setAppearance.
  ///
  /// In bn, this message translates to:
  /// **'চেহারা ও ভাষা'**
  String get setAppearance;

  /// No description provided for @setNumerals.
  ///
  /// In bn, this message translates to:
  /// **'সংখ্যার ধরন'**
  String get setNumerals;

  /// No description provided for @setNumeralsBangla.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা (১২৩)'**
  String get setNumeralsBangla;

  /// No description provided for @setNumeralsWestern.
  ///
  /// In bn, this message translates to:
  /// **'ইংরেজি (123)'**
  String get setNumeralsWestern;

  /// No description provided for @setGrouping.
  ///
  /// In bn, this message translates to:
  /// **'টাকার কমা'**
  String get setGrouping;

  /// No description provided for @setGroupingLakh.
  ///
  /// In bn, this message translates to:
  /// **'লাখ (১২,৩৪,৫৬৭)'**
  String get setGroupingLakh;

  /// No description provided for @setGroupingWestern.
  ///
  /// In bn, this message translates to:
  /// **'মিলিয়ন (১,২৩৪,৫৬৭)'**
  String get setGroupingWestern;

  /// No description provided for @setTheme.
  ///
  /// In bn, this message translates to:
  /// **'থিম'**
  String get setTheme;

  /// No description provided for @setThemeSystem.
  ///
  /// In bn, this message translates to:
  /// **'ফোনের মতো'**
  String get setThemeSystem;

  /// No description provided for @setThemeLight.
  ///
  /// In bn, this message translates to:
  /// **'হালকা'**
  String get setThemeLight;

  /// No description provided for @setThemeDark.
  ///
  /// In bn, this message translates to:
  /// **'গাঢ়'**
  String get setThemeDark;

  /// No description provided for @setFees.
  ///
  /// In bn, this message translates to:
  /// **'ফি'**
  String get setFees;

  /// No description provided for @setDefaultDueDay.
  ///
  /// In bn, this message translates to:
  /// **'নতুন শিক্ষার্থীর ফি আদায়ের দিন'**
  String get setDefaultDueDay;

  /// No description provided for @setDueDayValue.
  ///
  /// In bn, this message translates to:
  /// **'প্রতি মাসের {day} তারিখ'**
  String setDueDayValue(String day);

  /// No description provided for @setProration.
  ///
  /// In bn, this message translates to:
  /// **'যোগদানের মাসের ফি'**
  String get setProration;

  /// No description provided for @setProrationFull.
  ///
  /// In bn, this message translates to:
  /// **'পুরো মাসের ফি'**
  String get setProrationFull;

  /// No description provided for @setProrationDays.
  ///
  /// In bn, this message translates to:
  /// **'দিন হিসাবে আনুপাতিক'**
  String get setProrationDays;

  /// No description provided for @setProrationNext.
  ///
  /// In bn, this message translates to:
  /// **'পরের মাস থেকে'**
  String get setProrationNext;

  /// No description provided for @setProrationHint.
  ///
  /// In bn, this message translates to:
  /// **'এখন থেকে যোগ হওয়া শিক্ষার্থীদের জন্য প্রযোজ্য। আগের ফি বদলাবে না।'**
  String get setProrationHint;

  /// No description provided for @setData.
  ///
  /// In bn, this message translates to:
  /// **'তথ্য ও বার্তা'**
  String get setData;

  /// No description provided for @setAbout.
  ///
  /// In bn, this message translates to:
  /// **'সংস্করণ {version}'**
  String setAbout(String version);

  /// No description provided for @obWelcome.
  ///
  /// In bn, this message translates to:
  /// **'টিউশন খাতায় স্বাগতম'**
  String get obWelcome;

  /// No description provided for @obPickLanguage.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ভাষা বেছে নিন'**
  String get obPickLanguage;

  /// No description provided for @obPrivacy.
  ///
  /// In bn, this message translates to:
  /// **'আপনার তথ্য এই ফোনেই থাকে। কোনো সাইন-আপ লাগে না।'**
  String get obPrivacy;

  /// No description provided for @obIntro1Title.
  ///
  /// In bn, this message translates to:
  /// **'শিক্ষার্থী'**
  String get obIntro1Title;

  /// No description provided for @obIntro1Body.
  ///
  /// In bn, this message translates to:
  /// **'নাম আর ফি দিয়ে এক মিনিটেই শিক্ষার্থী যোগ করুন'**
  String get obIntro1Body;

  /// No description provided for @obIntro2Title.
  ///
  /// In bn, this message translates to:
  /// **'হাজিরা'**
  String get obIntro2Title;

  /// No description provided for @obIntro2Body.
  ///
  /// In bn, this message translates to:
  /// **'সবাই উপস্থিত ধরা থাকে — শুধু অনুপস্থিতদের ছুঁয়ে দিন'**
  String get obIntro2Body;

  /// No description provided for @obIntro3Title.
  ///
  /// In bn, this message translates to:
  /// **'ফি ও রসিদ'**
  String get obIntro3Title;

  /// No description provided for @obIntro3Body.
  ///
  /// In bn, this message translates to:
  /// **'কার কত বাকি, এক নজরে। পেমেন্ট নিন আর রসিদ পাঠান'**
  String get obIntro3Body;

  /// No description provided for @obSkip.
  ///
  /// In bn, this message translates to:
  /// **'এড়িয়ে যান'**
  String get obSkip;

  /// No description provided for @obNext.
  ///
  /// In bn, this message translates to:
  /// **'পরের ধাপ'**
  String get obNext;

  /// No description provided for @obSampleTitle.
  ///
  /// In bn, this message translates to:
  /// **'নমুনা তথ্য দিয়ে দেখবেন?'**
  String get obSampleTitle;

  /// No description provided for @obSampleBody.
  ///
  /// In bn, this message translates to:
  /// **'কয়েকজন উদাহরণ শিক্ষার্থী, হাজিরা ও পেমেন্ট যোগ হবে। এক চাপেই মুছে ফেলা যায়।'**
  String get obSampleBody;

  /// No description provided for @obSampleYes.
  ///
  /// In bn, this message translates to:
  /// **'নমুনা তথ্য যোগ করুন'**
  String get obSampleYes;

  /// No description provided for @obSampleNo.
  ///
  /// In bn, this message translates to:
  /// **'খালি অ্যাপ দিয়ে শুরু করুন'**
  String get obSampleNo;

  /// No description provided for @obLoading.
  ///
  /// In bn, this message translates to:
  /// **'তৈরি করা হচ্ছে…'**
  String get obLoading;

  /// No description provided for @sampleBanner.
  ///
  /// In bn, this message translates to:
  /// **'আপনি নমুনা তথ্য দেখছেন'**
  String get sampleBanner;

  /// No description provided for @sampleRemove.
  ///
  /// In bn, this message translates to:
  /// **'নমুনা মুছুন'**
  String get sampleRemove;

  /// No description provided for @sampleRemoved.
  ///
  /// In bn, this message translates to:
  /// **'নমুনা তথ্য মুছে ফেলা হয়েছে'**
  String get sampleRemoved;

  /// No description provided for @sampleLoad.
  ///
  /// In bn, this message translates to:
  /// **'নমুনা তথ্য যোগ করুন'**
  String get sampleLoad;

  /// No description provided for @sampleLoaded.
  ///
  /// In bn, this message translates to:
  /// **'নমুনা তথ্য যোগ হয়েছে'**
  String get sampleLoaded;

  /// No description provided for @sampleSettingsHint.
  ///
  /// In bn, this message translates to:
  /// **'উদাহরণ দিয়ে অ্যাপ ঘুরে দেখুন, এক চাপে মুছে ফেলুন'**
  String get sampleSettingsHint;

  /// No description provided for @lockEnterPin.
  ///
  /// In bn, this message translates to:
  /// **'পিন দিন'**
  String get lockEnterPin;

  /// No description provided for @lockWrong.
  ///
  /// In bn, this message translates to:
  /// **'ভুল পিন। অপেক্ষার আগে আর {count}টি চেষ্টা বাকি'**
  String lockWrong(String count);

  /// No description provided for @lockBlocked.
  ///
  /// In bn, this message translates to:
  /// **'অনেকবার ভুল হয়েছে। {seconds} সেকেন্ড পরে চেষ্টা করুন'**
  String lockBlocked(String seconds);

  /// No description provided for @lockBiometric.
  ///
  /// In bn, this message translates to:
  /// **'আঙুলের ছাপ বা মুখ দিয়ে খুলুন'**
  String get lockBiometric;

  /// No description provided for @lockBiometricReason.
  ///
  /// In bn, this message translates to:
  /// **'টিউশন খাতা খুলুন'**
  String get lockBiometricReason;

  /// No description provided for @lockForgot.
  ///
  /// In bn, this message translates to:
  /// **'পিন ভুলে গেছেন?'**
  String get lockForgot;

  /// No description provided for @lockForgotBody.
  ///
  /// In bn, this message translates to:
  /// **'পিন ছাড়া অ্যাপ খোলার কোনো উপায় নেই। চাইলে অ্যাপের সব তথ্য মুছে নতুন করে শুরু করতে পারেন; তারপর আগের ব্যাকআপ থেকে তথ্য ফিরিয়ে আনা যাবে। ব্যাকআপ না থাকলে তথ্য আর ফেরত পাওয়া যাবে না।'**
  String get lockForgotBody;

  /// No description provided for @lockSettingsTitle.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপ লক'**
  String get lockSettingsTitle;

  /// No description provided for @lockSettingsHint.
  ///
  /// In bn, this message translates to:
  /// **'পিন দিয়ে অ্যাপ সুরক্ষিত রাখুন'**
  String get lockSettingsHint;

  /// No description provided for @lockOn.
  ///
  /// In bn, this message translates to:
  /// **'পিন দিয়ে লক'**
  String get lockOn;

  /// No description provided for @lockSetPin.
  ///
  /// In bn, this message translates to:
  /// **'পিন ঠিক করুন'**
  String get lockSetPin;

  /// No description provided for @lockPinHint.
  ///
  /// In bn, this message translates to:
  /// **'৪ থেকে ৮টি সংখ্যা'**
  String get lockPinHint;

  /// No description provided for @lockPinAgain.
  ///
  /// In bn, this message translates to:
  /// **'পিন আবার দিন'**
  String get lockPinAgain;

  /// No description provided for @lockPinMismatch.
  ///
  /// In bn, this message translates to:
  /// **'পিন দুটি মেলেনি'**
  String get lockPinMismatch;

  /// No description provided for @lockPinInvalid.
  ///
  /// In bn, this message translates to:
  /// **'৪ থেকে ৮টি সংখ্যা দিন'**
  String get lockPinInvalid;

  /// No description provided for @lockChangePin.
  ///
  /// In bn, this message translates to:
  /// **'পিন বদলান'**
  String get lockChangePin;

  /// No description provided for @lockCurrentPin.
  ///
  /// In bn, this message translates to:
  /// **'বর্তমান পিন'**
  String get lockCurrentPin;

  /// No description provided for @lockTurnOff.
  ///
  /// In bn, this message translates to:
  /// **'লক বন্ধ করুন'**
  String get lockTurnOff;

  /// No description provided for @lockTimeout.
  ///
  /// In bn, this message translates to:
  /// **'কতক্ষণ পরে আবার লক হবে'**
  String get lockTimeout;

  /// No description provided for @lockTimeoutNow.
  ///
  /// In bn, this message translates to:
  /// **'সাথে সাথে'**
  String get lockTimeoutNow;

  /// No description provided for @lockTimeoutMinutes.
  ///
  /// In bn, this message translates to:
  /// **'{minutes} মিনিট'**
  String lockTimeoutMinutes(String minutes);

  /// No description provided for @lockBiometricOn.
  ///
  /// In bn, this message translates to:
  /// **'আঙুলের ছাপ বা মুখ দিয়ে খোলা'**
  String get lockBiometricOn;

  /// No description provided for @lockBiometricNone.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনে চালু করা নেই'**
  String get lockBiometricNone;

  /// No description provided for @lockProtect.
  ///
  /// In bn, this message translates to:
  /// **'স্ক্রিনশট ও সাম্প্রতিক অ্যাপের প্রিভিউ আটকান'**
  String get lockProtect;

  /// No description provided for @lockOnDone.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপ লক চালু হয়েছে'**
  String get lockOnDone;

  /// No description provided for @lockOffDone.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপ লক বন্ধ হয়েছে'**
  String get lockOffDone;

  /// No description provided for @lockRemember.
  ///
  /// In bn, this message translates to:
  /// **'পিন ভুলে গেলে সব তথ্য মুছে নতুন করে শুরু করতে হবে, তাই নিয়মিত ব্যাকআপ রাখুন।'**
  String get lockRemember;

  /// No description provided for @lockWrongCurrent.
  ///
  /// In bn, this message translates to:
  /// **'বর্তমান পিন ভুল'**
  String get lockWrongCurrent;
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
