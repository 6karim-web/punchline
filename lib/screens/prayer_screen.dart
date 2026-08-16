import 'package:flutter/material.dart';
import '../data/prayer_times.dart';
import '../l10n/strings.dart';
import '../services/notifications.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final s = S(state.locale);

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final city = state.city;
        final times = PrayerTimes.forDate(
          date: DateTime.now(),
          latitude: city.lat,
          longitude: city.lon,
          method: state.calcMethod,
          school: state.asrSchool,
        );
        final next = times.next;

        return Scaffold(
          appBar: AppBar(
            title: Text(s('prayer')),
            shape:
                const Border(bottom: BorderSide(color: T.border, width: 0.5)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(T.s3),
            children: [
              if (next != null) _countdown(next, s, city.name),
              const SizedBox(height: T.s4),
              for (final p in times.prayers)
                _row(p, s, isNext: p.key == next?.key),
              const SizedBox(height: T.s5),
              _methodPicker(s, state),
              const SizedBox(height: T.s5),
            ],
          ),
        );
      },
    );
  }

  Widget _countdown(Prayer next, S s, String city) {
    final left = next.time.difference(DateTime.now());
    final h = left.inHours;
    final m = left.inMinutes % 60;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: T.card,
        border: Border.all(color: T.border, width: 0.5),
        borderRadius: BorderRadius.circular(T.rCard),
      ),
      padding: const EdgeInsets.all(T.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${s('nextPrayer')} \u00b7 $city',
              style: const TextStyle(fontSize: 12, color: T.textMuted)),
          const SizedBox(height: T.s2),
          Text(s(next.key),
              style: AppType.punchlineHero().copyWith(color: T.violet)),
          const SizedBox(height: T.s1),
          Text(
            '${_hhmm(next.time)}   \u00b7   ${s('in_')} '
            '${h > 0 ? '${h}h ' : ''}${m}min',
            style: AppType.number(color: T.text, size: 15),
          ),
        ],
      ),
    );
  }

  Widget _row(Prayer p, S s, {required bool isNext}) {
    final state = AppState.instance;
    final isSunrise = p.key == 'sunrise';
    final on = state.prayerAlerts.contains(p.key);
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 2, end: 2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: T.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              s(p.key),
              style: TextStyle(
                fontSize: 16,
                color: isNext ? T.violet : (isSunrise ? T.textMuted : T.text),
              ),
            ),
          ),
          Text(_hhmm(p.time),
              style: AppType.number(
                  color: isNext ? T.violet : T.text, size: 16)),
          const SizedBox(width: T.s3),
          SizedBox(
            width: 52,
            child: isSunrise
                ? const SizedBox.shrink()
                : Switch(
                    value: on,
                    onChanged: (v) => state.togglePrayerAlert(p.key),
                    activeThumbColor: T.canvas,
                    activeTrackColor: T.violet,
                    inactiveThumbColor: T.textMuted,
                    inactiveTrackColor: T.card,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _methodPicker(S s, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 2, bottom: T.s2),
          child: Text(s('method'),
              style: const TextStyle(
                  fontSize: 11, letterSpacing: 0.9, color: T.textMuted)),
        ),
        for (final m in CalcMethod.values)
          _choice(m.label, state.calcMethod == m, () => state.setCalcMethod(m)),
        const SizedBox(height: T.s4),
        for (final school in AsrSchool.values)
          _choice(school.label, state.asrSchool == school,
              () => state.setAsrSchool(school)),
      ],
    );
  }

  Widget _choice(String label, bool selected, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 2),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: T.border, width: 0.5)),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.circle_outlined,
                size: 18,
                color: selected ? T.violet : T.textFaint,
              ),
              const SizedBox(width: T.s3),
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontSize: 14, color: T.text)),
              ),
            ],
          ),
        ),
      );

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
