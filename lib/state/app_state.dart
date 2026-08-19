import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/joke_repository.dart';
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
    // The catalogue changes with the language, so it must be swapped before
    // anything rebuilds — otherwise the library shows the previous book.
    await JokeRepository.instance.load(value);
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('locale', value.code);
  }
}
