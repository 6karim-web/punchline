import 'package:flutter/material.dart';

/// Four languages. Arabic brings right-to-left, which is why every layout in
/// this app uses EdgeInsetsDirectional and start/end rather than left/right —
/// retrofitting RTL onto a finished app is miserable work.
enum AppLocale {
  en('en', 'English', 'English', TextDirection.ltr),
  es('es', 'Spanish', 'Espanol', TextDirection.ltr),
  fr('fr', 'French', 'Francais', TextDirection.ltr),
  ar('ar', 'Arabic', 'العربية', TextDirection.rtl);

  final String code;
  final String englishName;
  final String nativeName;
  final TextDirection direction;

  const AppLocale(this.code, this.englishName, this.nativeName, this.direction);

  Locale get locale => Locale(code);
  bool get isRtl => direction == TextDirection.rtl;

  static AppLocale fromCode(String? code) =>
      AppLocale.values.firstWhere((l) => l.code == code,
          orElse: () => AppLocale.en);
}
