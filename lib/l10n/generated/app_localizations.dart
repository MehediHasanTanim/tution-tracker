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
