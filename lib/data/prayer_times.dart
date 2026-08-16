import 'dart:math' as math;

/// Prayer times computed on device from solar geometry. No API, no network,
/// works offline anywhere — and nothing to break if a service goes down.
///
/// The calculation follows the standard method: solar declination and the
/// equation of time give solar noon, then each prayer is an hour angle away
/// from it. Getting this wrong is not a cosmetic bug, so the maths is written
/// out plainly rather than compressed.
enum CalcMethod {
  mwl('Muslim World League', 18.0, 17.0),
  isna('ISNA (North America)', 15.0, 15.0),
  egypt('Egyptian General Authority', 19.5, 17.5),
  makkah('Umm al-Qura (Makkah)', 18.5, 0.0), // Isha = Maghrib + 90 min
  karachi('University of Karachi', 18.0, 18.0),
  moroccan('Morocco (Habous)', 19.0, 17.0);

  final String label;
  final double fajrAngle;
  final double ishaAngle;
  const CalcMethod(this.label, this.fajrAngle, this.ishaAngle);

  bool get ishaIsFixed => this == CalcMethod.makkah;
}

/// Shafi: shadow = object length. Hanafi: shadow = twice object length.
enum AsrSchool { standard('Standard (Shafi, Maliki, Hanbali)', 1),
  hanafi('Hanafi', 2);

  final String label;
  final int factor;
  const AsrSchool(this.label, this.factor);
}

class Prayer {
  final String key;
  final DateTime time;
  const Prayer(this.key, this.time);
}

class PrayerTimes {
  final List<Prayer> prayers;
  const PrayerTimes(this.prayers);

  Prayer? get next {
    final now = DateTime.now();
    for (final p in prayers) {
      if (p.time.isAfter(now)) return p;
    }
    return null;
  }

  Prayer? get current {
    final now = DateTime.now();
    Prayer? last;
    for (final p in prayers) {
      if (p.time.isBefore(now)) last = p;
    }
    return last;
  }

  static PrayerTimes forDate({
    required DateTime date,
    required double latitude,
    required double longitude,
    CalcMethod method = CalcMethod.isna,
    AsrSchool school = AsrSchool.standard,
  }) {
    final tzOffsetHours = date.timeZoneOffset.inMinutes / 60.0;
    final jd = _julianDate(date) - longitude / 360.0;

    // Solar coordinates for the day (Meeus, low-precision form).
    final d = jd - 2451545.0;
    final g = _norm(357.529 + 0.98560028 * d);
    final q = _norm(280.459 + 0.98564736 * d);
    final l = _norm(q +
        1.915 * math.sin(_rad(g)) +
        0.020 * math.sin(_rad(2 * g)));
    final e = 23.439 - 0.00000036 * d;

    final declination = _deg(math.asin(math.sin(_rad(e)) * math.sin(_rad(l))));
    var rightAscension =
        _deg(math.atan2(math.cos(_rad(e)) * math.sin(_rad(l)), math.cos(_rad(l))));
    rightAscension = _norm(rightAscension) / 15.0;
    final equationOfTime = q / 15.0 - rightAscension;

    // Solar noon in local clock time.
    final dhuhr = 12.0 + tzOffsetHours - longitude / 15.0 - equationOfTime;

    /// Hours between solar noon and the moment the sun sits [depression]
    /// degrees BELOW the horizon. Pass a negative value for an altitude
    /// above it (Asr). The sign here was the one bug worth unit-testing:
    /// get it backwards and Fajr lands after sunrise.
    double hourAngle(double depression) {
      final cosH = (-math.sin(_rad(depression)) -
              math.sin(_rad(latitude)) * math.sin(_rad(declination))) /
          (math.cos(_rad(latitude)) * math.cos(_rad(declination)));
      if (cosH > 1 || cosH < -1) return double.nan; // sun never reaches it
      return _deg(math.acos(cosH)) / 15.0;
    }

    // Asr: when an object's shadow equals its own length (times the factor)
    // plus the shadow it already casts at noon.
    final asrAltitude = _deg(math.atan(
        1.0 / (school.factor + math.tan(_rad((latitude - declination).abs())))));

    const horizon = 0.833; // refraction plus the sun's own radius

    final fajr = dhuhr - hourAngle(method.fajrAngle);
    final sunrise = dhuhr - hourAngle(horizon);
    final asr = dhuhr + hourAngle(-asrAltitude);
    final maghrib = dhuhr + hourAngle(horizon);
    final isha = method.ishaIsFixed
        ? maghrib + 1.5
        : dhuhr + hourAngle(method.ishaAngle);

    DateTime at(double hours) {
      if (hours.isNaN) return DateTime(date.year, date.month, date.day, 12);
      final h = hours % 24;
      return DateTime(date.year, date.month, date.day)
          .add(Duration(minutes: (h * 60).round()));
    }

    return PrayerTimes([
      Prayer('fajr', at(fajr)),
      Prayer('sunrise', at(sunrise)),
      Prayer('dhuhr', at(dhuhr)),
      Prayer('asr', at(asr)),
      Prayer('maghrib', at(maghrib)),
      Prayer('isha', at(isha)),
    ]);
  }

  static double _julianDate(DateTime d) {
    var year = d.year;
    var month = d.month;
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        d.day +
        b -
        1524.5;
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
  static double _deg(double rad) => rad * 180.0 / math.pi;
  static double _norm(double deg) {
    final r = deg - 360.0 * (deg / 360.0).floor();
    return r < 0 ? r + 360.0 : r;
  }
}
