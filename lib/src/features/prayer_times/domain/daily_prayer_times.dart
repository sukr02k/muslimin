import '../../../core/prayer_name.dart';

export '../../../core/prayer_name.dart';

/// Waktu sholat satu hari, disimpan sebagai instant UTC (independen zona).
class DailyPrayerTimes {
  const DailyPrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    DateTime? sunrise,
  }) : sunrise = sunrise ?? fajr;

  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  /// Waktu matahari terbit (Syuruq).
  final DateTime sunrise;

  /// Waktu Imsak (standar Indonesia: 10 menit sebelum Subuh).
  DateTime get imsak => fajr.subtract(const Duration(minutes: 10));

  /// Waktu Dhuha (sekitar 20 menit setelah terbit/syuruq).
  DateTime get dhuha => sunrise.add(const Duration(minutes: 20));

  List<(PrayerName, DateTime)> get ordered => [
        (PrayerName.fajr, fajr),
        (PrayerName.dhuhr, dhuhr),
        (PrayerName.asr, asr),
        (PrayerName.maghrib, maghrib),
        (PrayerName.isha, isha),
      ];

  DateTime timeFor(PrayerName name) => switch (name) {
        PrayerName.fajr => fajr,
        PrayerName.dhuhr => dhuhr,
        PrayerName.asr => asr,
        PrayerName.maghrib => maghrib,
        PrayerName.isha => isha,
      };
}

class NextPrayer {
  const NextPrayer({required this.name, required this.time});

  final PrayerName name;
  final DateTime time;

  Duration countdownFrom(DateTime nowUtc) => time.difference(nowUtc);
}

/// Sholat berikutnya. Jika semua sholat hari ini lewat, kembalikan Subuh besok.
NextPrayer nextPrayerAt(
  DateTime nowUtc,
  DailyPrayerTimes today,
  DailyPrayerTimes tomorrow,
) {
  for (final (name, time) in today.ordered) {
    if (time.isAfter(nowUtc)) return NextPrayer(name: name, time: time);
  }
  return NextPrayer(name: PrayerName.fajr, time: tomorrow.fajr);
}

/// Format instant UTC + offset menjadi "HH:mm" (jam dinding lokal).
String formatHhMm(DateTime utc, int utcOffsetMinutes) {
  final t = utc.add(Duration(minutes: utcOffsetMinutes));
  final hh = t.hour.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}