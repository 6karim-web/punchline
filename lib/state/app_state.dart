import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/weather_repository.dart';
import '../l10n/app_locale.dart';

/// A single notifier for the two settings that change everything on screen.
/// No state-management package: two values do not justify a dependency.
class AppState extends ChangeNotifier {
  AppState._();
  static final instance = AppState._();

  AppLocale _locale = AppLocale.en;
  City _city = WeatherRepository.cities.first;

  AppLocale get locale => _locale;
  City get city => _city;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = AppLocale.fromCode(prefs.getString('locale'));
    final cityName = prefs.getString('city');
    _city = WeatherRepository.cities.firstWhere((c) => c.name == cityName,
        orElse: () => WeatherRepository.cities.first);
    notifyListeners();
  }

  Future<void> setLocale(AppLocale value) async {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('locale', value.code);
  }

  Future<void> setCity(City value) async {
    if (_city.name == value.name) return;
    _city = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('city', value.name);
  }
}
