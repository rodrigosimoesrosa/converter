import 'package:flutter/material.dart';
import 'package:converter/i18n/i18n.dart';

class I18NDelegate extends LocalizationsDelegate<I18N> {
  const I18NDelegate();

  @override
  bool isSupported(Locale locale) => ['pt', 'en'].contains(locale.languageCode);

  @override
  Future<I18N> load(Locale locale) async {
    I18N localizations = new I18N(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(I18NDelegate old) => false;

}