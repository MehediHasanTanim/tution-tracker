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
}
