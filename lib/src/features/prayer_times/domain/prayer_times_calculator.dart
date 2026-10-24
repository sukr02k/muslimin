import 'package:adhan/adhan.dart';

import 'daily_prayer_times.dart';
import 'geo_location.dart';
import 'prayer_settings.dart';

class PrayerTimesCalculator {
  const PrayerTimesCalculator();

  /// Hitung waktu sholat lengkap (termasuk Terbit/Syuruq & Imsak) untuk [location] pada [localDate].
  DailyPrayerTimes forDate(
    GeoLocation location,
    DateTime localDate,
    PrayerSettings settings,
  ) {
    final params = _parameters(settings);
    final components =
        DateComponents(localDate.year, localDate.month, localDate.day);
    final coordinates = Coordinates(location.latitude, location.longitude);
    final t = PrayerTimes.utc(coordinates, components, params);

    return DailyPrayerTimes(
      fajr: t.fajr,
      dhuhr: t.dhuhr,
      asr: t.asr,
      maghrib: t.maghrib,
      isha: t.isha,
      sunrise: t.sunrise,
    );
  }

  CalculationParameters _parameters(PrayerSettings settings) {
    final params = switch (settings.method) {
      PrayerMethod.kemenag => CalculationParameters(
          fajrAngle: 20,
          ishaAngle: 18,
          method: CalculationMethod.other,
        ),
      PrayerMethod.muslimWorldLeague => CalculationMethod.muslim_world_league.getParameters(),
      PrayerMethod.egyptian => CalculationMethod.egyptian.getParameters(),
      PrayerMethod.karachi => CalculationMethod.karachi.getParameters(),
      PrayerMethod.ummAlQura => CalculationMethod.umm_al_qura.getParameters(),
    };

    params.madhab = switch (settings.madhab) {
      PrayerMadhab.shafi => Madhab.shafi,
      PrayerMadhab.hanafi => Madhab.hanafi,
    };

    return params;
  }
}