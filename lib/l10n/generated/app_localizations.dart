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
