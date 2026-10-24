/// Lima waktu sholat wajib. Dipakai lintas fitur (jadwal & tracker).
enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

extension PrayerNameX on PrayerName {
  String get labelId => switch (this) {
        PrayerName.fajr => 'Subuh',
        PrayerName.dhuhr => 'Dzuhur',
        PrayerName.asr => 'Ashar',
        PrayerName.maghrib => 'Maghrib',
        PrayerName.isha => 'Isya',
      };
}