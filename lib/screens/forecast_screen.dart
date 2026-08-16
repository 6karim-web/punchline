import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/weather_repository.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/feed_states.dart';

class Day {
  final DateTime date;
  final double high;
  final double low;
  final int code;
  final int rain;
  const Day(this.date, this.high, this.low, this.code, this.rain);
}

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  late Future<List<Day>> _days;

  @override
  void initState() {
    super.initState();
    _days = _fetch(AppState.instance.city);
  }

  Future<List<Day>> _fetch(City city) async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${city.lat}&longitude=${city.lon}'
        '&daily=temperature_2m_max,temperature_2m_min,weather_code,'
        'precipitation_probability_max'
        '&temperature_unit=fahrenheit&timezone=auto&forecast_days=7',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return const [];
      final d = jsonDecode(res.body)['daily'] as Map<String, dynamic>;
      final dates = (d['time'] as List).cast<String>();
      return List.generate(dates.length, (i) {
        return Day(
          DateTime.parse(dates[i]),
          ((d['temperature_2m_max'] as List)[i] as num).toDouble(),
          ((d['temperature_2m_min'] as List)[i] as num).toDouble(),
          ((d['weather_code'] as List)[i] as num).toInt(),
          (((d['precipitation_probability_max'] as List)[i] ?? 0) as num)
              .toInt(),
        );
      });
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final s = S(state.locale);
    return Scaffold(
      appBar: AppBar(
        title: Text('${s('forecast')} \u00b7 ${state.city.name}'),
        shape: const Border(bottom: BorderSide(color: T.border, width: 0.5)),
      ),
      body: FutureBuilder<List<Day>>(
        future: _days,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Loading(label: s('checkingSky'));
          }
          final days = snap.data ?? const <Day>[];
          if (days.isEmpty) {
            return ListView(children: [
              Failed(
                  message: s('weatherUnavailable'),
                  onRetry: () =>
                      setState(() => _days = _fetch(state.city))),
            ]);
          }
          // A shared scale so the bars actually compare across the week.
          final hi = days.map((d) => d.high).reduce((a, b) => a > b ? a : b);
          final lo = days.map((d) => d.low).reduce((a, b) => a < b ? a : b);

          return ListView(
            padding: const EdgeInsets.all(T.s3),
            children: [
              for (final d in days) _row(d, s, hi, lo),
              const SizedBox(height: T.s4),
              Text(s('weatherBy'),
                  style: const TextStyle(fontSize: 10, color: T.textFaint)),
              const SizedBox(height: T.s5),
            ],
          );
        },
      ),
    );
  }

  Widget _row(Day d, S s, double hi, double lo) {
    final span = (hi - lo) == 0 ? 1 : (hi - lo);
    final start = (d.low - lo) / span;
    final width = (d.high - d.low) / span;
    final isToday = DateTime.now().day == d.date.day;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: T.s3),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: T.border, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text(
              isToday ? s('today') : _weekday(d.date),
              style: TextStyle(
                  fontSize: 13, color: isToday ? T.saffron : T.text),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text('${d.rain}%',
                style: TextStyle(
                    fontSize: 11,
                    color: d.rain >= 40 ? T.blue : T.textFaint)),
          ),
          SizedBox(
            width: 34,
            child: Text('${d.low.round()}\u00b0',
                style: AppType.number(color: T.textMuted, size: 13)),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => Stack(
                children: [
                  Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: T.card,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  PositionedDirectional(
                    start: box.maxWidth * start,
                    child: Container(
                      height: 4,
                      width: (box.maxWidth * width).clamp(6.0, box.maxWidth),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: T.saffron,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text('${d.high.round()}\u00b0',
                textAlign: TextAlign.end,
                style: AppType.number(color: T.text, size: 13)),
          ),
        ],
      ),
    );
  }

  static String _weekday(DateTime d) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];
}
