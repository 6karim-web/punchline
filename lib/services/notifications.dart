import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../data/prayer_times.dart';

/// Scheduling is deliberately conservative: Android drops exact alarms without
/// warning when the user denies the permission, so every call is wrapped and
/// a failure degrades to "no notification" rather than a crash on launch.
class Notifications {
  Notifications._();
  static final instance = Notifications._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      await _plugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ));
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  static const _prayerChannel = AndroidNotificationDetails(
    'prayer',
    'Prayer times',
    channelDescription: 'The call to prayer at its scheduled time',
    importance: Importance.max,
    priority: Priority.high,
    enableVibration: true,
    // Long-short-long: distinct enough to recognise in a pocket.
    vibrationPattern: null,
    category: AndroidNotificationCategory.alarm,
  );

  static const _dailyChannel = AndroidNotificationDetails(
    'daily',
    'Daily punchline',
    channelDescription: 'One setup a day. The punchline stays in the app.',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    enableVibration: true,
  );

  Future<void> cancelAll() async {
    if (_ready) await _plugin.cancelAll();
  }

  /// Schedules the five prayers for today and tomorrow. Two days is enough:
  /// the app reschedules on every launch, and anything further out is more
  /// likely to be wrong than useful.
  Future<void> schedulePrayers({
    required double latitude,
    required double longitude,
    required CalcMethod method,
    required AsrSchool school,
    required Set<String> enabled,
  }) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    var id = 100;
    for (var day = 0; day < 2; day++) {
      final date = DateTime.now().add(Duration(days: day));
      final times = PrayerTimes.forDate(
        date: date,
        latitude: latitude,
        longitude: longitude,
        method: method,
        school: school,
      );
      for (final p in times.prayers) {
        if (p.key == 'sunrise' || !enabled.contains(p.key)) continue;
        if (p.time.isBefore(DateTime.now())) continue;
        await _schedule(id++, _title(p.key), 'It is time for ${_title(p.key)}',
            p.time, _prayerChannel);
      }
    }
  }

  /// The notification carries the setup and never the punchline. The fold
  /// already exists in the notification — that is what earns the open.
  Future<void> scheduleDailyPunchline({
    required int hour,
    required int minute,
    required String setup,
  }) async {
    if (!_ready) return;
    var when = DateTime.now();
    when = DateTime(when.year, when.month, when.day, hour, minute);
    if (when.isBefore(DateTime.now())) {
      when = when.add(const Duration(days: 1));
    }
    await _schedule(1, 'Punchline', setup, when, _dailyChannel);
  }

  Future<void> _schedule(int id, String title, String body, DateTime when,
      AndroidNotificationDetails channel) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        NotificationDetails(android: channel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // Exact-alarm permission denied, or the OS refused. Not fatal.
    }
  }

  static String _title(String key) =>
      key[0].toUpperCase() + key.substring(1);
}
