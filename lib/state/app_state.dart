import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/weather_repository.dart';
import '../data/prayer_times.dart';
import '../l10n/app_locale.dart';
import '../services/notifications.dart';

/// A single notifier for the two settings that change everything on screen.
/// No state-management package: two values do not justify a dependency.
class AppState extends ChangeNotifier {
  AppState._();
  static final instance = AppState._();

  AppLocale _locale = AppLocale.en;
  City _city = WeatherRepository.cities.first;
  CalcMethod _calcMethod = CalcMethod.isna;
  AsrSchool _asrSchool = AsrSchool.standard;
  Set<String> _prayerAlerts = {};

  AppLocale get locale => _locale;
  City get city => _city;
  CalcMethod get calcMethod => _calcMethod;
  AsrSchool get asrSchool => _asrSchool;
  Set<String> get prayerAlerts => Set.unmodifiable(_prayerAlerts);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = AppLocale.fromCode(prefs.getString('locale'));
    final cityName = prefs.getString('city');
    _city = WeatherRepository.cities.firstWhere((c) => c.name == cityName,
        orElse: () => WeatherRepository.cities.first);
    _calcMethod = CalcMethod.values.firstWhere(
        (m) => m.name == prefs.getString('calcMethod'),
        orElse: () => CalcMethod.isna);
    _asrSchool = AsrSchool.values.firstWhere(
        (a) => a.name == prefs.getString('asrSchool'),
        orElse: () => AsrSchool.standard);
    _prayerAlerts = (prefs.getStringList('prayerAlerts') ?? const []).toSet();
    notifyListeners();
    _reschedule();
  }

  Future<void> setCalcMethod(CalcMethod value) async {
    _calcMethod = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('calcMethod', value.name);
    _reschedule();
  }

  Future<void> setAsrSchool(AsrSchool value) async {
    _asrSchool = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('asrSchool', value.name);
    _reschedule();
  }

  Future<void> togglePrayerAlert(String key) async {
    if (_prayerAlerts.contains(key)) {
      _prayerAlerts.remove(key);
    } else {
      _prayerAlerts.add(key);
      // Android 13+ refuses to post anything until the user has said yes.
      await Notifications.instance.requestPermission();
    }
    notifyListeners();
    (await SharedPreferences.getInstance())
        .setStringList('prayerAlerts', _prayerAlerts.toList());
    _reschedule();
  }

  /// Alarms are rebuilt from scratch on every change. Cheap, and it removes a
  /// whole class of bugs where a stale prayer fires at the wrong hour.
  void _reschedule() {
    Notifications.instance.schedulePrayers(
      latitude: _city.lat,
      longitude: _city.lon,
      method: _calcMethod,
      school: _asrSchool,
      enabled: _prayerAlerts,
    );
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
    _reschedule();
  }
}
