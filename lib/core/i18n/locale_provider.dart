import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';

/// Locales the app ships with. Bangla is the default (spec ON-1).
const supportedAppLocales = [Locale('bn'), Locale('en')];

/// Current UI locale. Persistence arrives with the settings store (S1-08).
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => supportedAppLocales.first;

  void setLocale(Locale locale) {
    assert(supportedAppLocales.contains(locale));
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

/// [localeProvider] as the formatter-facing language enum.
final appLanguageProvider = Provider<AppLanguage>(
  (ref) => ref.watch(localeProvider).languageCode == 'en'
      ? AppLanguage.en
      : AppLanguage.bn,
);
