import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_locale.dart';

/// One notifier for the settings that change what is on screen.
/// No state-management package: a single value does not justify a dependency.
class AppState extends ChangeNotifier {
  AppState._();
  static final instance = AppState._();

  AppLocale _locale = AppLocale.en;
  AppLocale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = AppLocale.fromCode(prefs.getString('locale'));
    notifyListeners();
  }

  Future<void> setLocale(AppLocale value) async {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('locale', value.code);
  }
}
