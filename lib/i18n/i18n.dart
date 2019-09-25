
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class I18N {

  I18N(this.locale);

  final Locale locale;

  static I18N of(BuildContext context) {
    return Localizations.of<I18N>(context, I18N);
  }

  Map<String, String> _sentences;

  Future<bool> load() async {
    String data = await rootBundle.loadString('assets/languages/${locale.languageCode}_${locale.countryCode}.json');
    Map<String, dynamic> _result = json.decode(data);

    _sentences = new Map();
    _result.forEach((String key, dynamic value) {
      _sentences[key] = value.toString();
    });

    return true;
  }

  String text(String key) {
    return _sentences[key];
  }

}