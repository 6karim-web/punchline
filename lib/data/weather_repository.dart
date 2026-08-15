import 'dart:convert';
import 'package:http/http.dart' as http;

/// Weather data by Open-Meteo (https://open-meteo.com), CC BY 4.0.
/// The free tier is non-commercial only — a paid plan is required once the
/// app carries advertising.
class City {
  final String name;
  final double lat;
  final double lon;
  const City(this.name, this.lat, this.lon);
}

class Weather {
  final double tempF;
  final double feelsF;
  final int code;
  final double highF;
  final double lowF;
  final int rainChance;

  const Weather({
    required this.tempF,
    required this.feelsF,
    required this.code,
    required this.highF,
    required this.lowF,
    required this.rainChance,
  });

  /// WMO weather codes, collapsed to what a person actually needs to know.
  /// Returns a translation key, never a literal — the brief speaks four
  /// languages and the API only ever sends us a number.
  String get descriptionKey {
    if (code == 0) return 'clear';
    if (code <= 3) return 'partlyCloudy';
    if (code <= 48) return 'fog';
    if (code <= 57) return 'drizzle';
    if (code <= 67) return 'rainy';
    if (code <= 77) return 'snow';
    if (code <= 82) return 'showers';
    if (code <= 86) return 'snowShowers';
    return 'thunder';
  }

  /// The line that earns weather its place in the brief: not the numbers,
  /// the advice. Numbers you can get anywhere; the verdict is the value.
  String get adviceKey {
    if (code >= 95) return 'adviceStorm';
    if (code >= 71 && code <= 86) return 'adviceSnow';
    if (rainChance >= 60) return 'adviceUmbrella';
    if (highF >= 90) return 'adviceHot';
    if (lowF <= 25) return 'adviceCold';
    if (code == 0 && highF >= 65) return 'adviceNice';
    return 'adviceNothing';
  }
}

class WeatherRepository {
  WeatherRepository._();
  static final instance = WeatherRepository._();

  static const cities = <City>[
    City('New York', 40.71, -74.01),
    City('Los Angeles', 34.05, -118.24),
    City('Chicago', 41.88, -87.63),
    City('Houston', 29.76, -95.37),
    City('Phoenix', 33.45, -112.07),
    City('Philadelphia', 39.95, -75.17),
    City('San Antonio', 29.42, -98.49),
    City('San Diego', 32.72, -117.16),
    City('Dallas', 32.78, -96.80),
    City('Miami', 25.76, -80.19),
    City('Atlanta', 33.75, -84.39),
    City('Seattle', 47.61, -122.33),
    City('Denver', 39.74, -104.98),
    City('Boston', 42.36, -71.06),
  ];

  Weather? _cache;
  String? _cacheKey;

  Future<Weather?> forCity(City city, {bool refresh = false}) async {
    final key = '${city.lat},${city.lon}';
    if (_cache != null && _cacheKey == key && !refresh) return _cache;
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${city.lat}&longitude=${city.lon}'
        '&current=temperature_2m,apparent_temperature,weather_code'
        '&daily=temperature_2m_max,temperature_2m_min,'
        'precipitation_probability_max'
        '&temperature_unit=fahrenheit&timezone=auto&forecast_days=1',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final c = j['current'] as Map<String, dynamic>;
      final d = j['daily'] as Map<String, dynamic>;
      _cacheKey = key;
      return _cache = Weather(
        tempF: (c['temperature_2m'] as num).toDouble(),
        feelsF: (c['apparent_temperature'] as num).toDouble(),
        code: (c['weather_code'] as num).toInt(),
        highF: ((d['temperature_2m_max'] as List).first as num).toDouble(),
        lowF: ((d['temperature_2m_min'] as List).first as num).toDouble(),
        rainChance:
            (((d['precipitation_probability_max'] as List).first ?? 0) as num)
                .toInt(),
      );
    } catch (_) {
      return null;
    }
  }
}
