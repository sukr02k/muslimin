import '../../prayer_times/domain/daily_prayer_times.dart';
import 'reminder_models.dart';

abstract final class ReminderScheduler {
  /// Hitung daftar notifikasi sholat yang harus dijadwalkan ke depan (dari [nowUtc]).
  ///
  /// Menjadwalkan waktu sholat hari ini & besok yang belum lewat dari [nowUtc].
  static List<ScheduledPrayerNotification> buildScheduledList({
    required DateTime nowUtc,
    required DailyPrayerTimes todayTimes,
    required DailyPrayerTimes tomorrowTimes,
    required ReminderSettings settings,
    required int utcOffsetMinutes,
  }) {
    final list = <ScheduledPrayerNotification>[];

    void processDay(DailyPrayerTimes times, int idOffset, String dayLabel) {
      for (final (name, prayerTimeUtc) in times.ordered) {
        final config = settings.configs[name];
        if (config == null || !config.isEnabled) continue;

        // Kurangi waktu adhan dengan offset pengingat
        final alertTimeUtc = prayerTimeUtc.subtract(
          Duration(minutes: config.offsetMinutes),
        );

        // Hanya jadwalkan jika waktu alarm masih di masa depan
        if (alertTimeUtc.isAfter(nowUtc)) {
          final id = _notificationId(name) + idOffset;
          final timeStr = formatHhMm(prayerTimeUtc, utcOffsetMinutes);

          String title;
          String body;
          if (config.offsetMinutes == 0) {
            title = 'Waktu Sholat ${name.labelId}';
            body = 'Telah masuk waktu sholat ${name.labelId} ($timeStr WIB/lokal).';
          } else {
            title = 'Pengingat ${name.labelId}';
            body = '${config.offsetMinutes} menit lagi masuk waktu ${name.labelId} ($timeStr).';
          }

          list.add(
            ScheduledPrayerNotification(
              id: id,
              prayerName: name,
              scheduledTime: alertTimeUtc,
              title: title,
              body: body,
            ),
          );
        }
      }
    }

    // Hari ini (ID 1..5)
    processDay(todayTimes, 0, 'Hari ini');
    // Besok (ID 10..15) agar setelah Isya malam, Subuh besok tetap aman terjadwal
    processDay(tomorrowTimes, 10, 'Besok');

    return list;
  }

  static int _notificationId(PrayerName name) => switch (name) {
        PrayerName.fajr => 1,
        PrayerName.dhuhr => 2,
        PrayerName.asr => 3,
        PrayerName.maghrib => 4,
        PrayerName.isha => 5,
      };
}