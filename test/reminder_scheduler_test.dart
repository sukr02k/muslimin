import 'package:flutter_test/flutter_test.dart';
import 'package:muslimin/src/features/adhan_reminder/domain/reminder_models.dart';
import 'package:muslimin/src/features/adhan_reminder/domain/reminder_scheduler.dart';
import 'package:muslimin/src/features/prayer_times/domain/daily_prayer_times.dart';

void main() {
  group('ReminderSettings', () {
    test('defaultSettings mengaktifkan ke-5 waktu sholat dengan offset 0', () {
      final settings = ReminderSettings.defaultSettings();
      expect(settings.configs.length, 5);
      for (final name in PrayerName.values) {
        final config = settings.configs[name];
        expect(config, isNotNull);
        expect(config!.isEnabled, isTrue);
        expect(config.offsetMinutes, 0);
      }
    });

    test('update mengubah status enabled & offset secara presisi', () {
      final settings = ReminderSettings.defaultSettings();
      final updated = settings.update(
        PrayerName.maghrib,
        isEnabled: false,
        offsetMinutes: 15,
      );

      expect(updated.configs[PrayerName.maghrib]!.isEnabled, isFalse);
      expect(updated.configs[PrayerName.maghrib]!.offsetMinutes, 15);
      // Sholat lain tetap tidak berubah
      expect(updated.configs[PrayerName.fajr]!.isEnabled, isTrue);
    });

    test('toJson dan fromJson serialisasi konsisten', () {
      final settings = ReminderSettings.defaultSettings().update(
        PrayerName.isha,
        isEnabled: true,
        offsetMinutes: 10,
      );

      final json = settings.toJson();
      final restored = ReminderSettings.fromJson(json);

      expect(restored.configs[PrayerName.isha]!.offsetMinutes, 10);
      expect(restored.configs[PrayerName.isha]!.isEnabled, isTrue);
    });
  });

  group('ReminderScheduler.buildScheduledList', () {
    final today = DailyPrayerTimes(
      fajr: DateTime.utc(2026, 10, 24, 4, 30),
      dhuhr: DateTime.utc(2026, 10, 24, 11, 45),
      asr: DateTime.utc(2026, 10, 24, 15, 0),
      maghrib: DateTime.utc(2026, 10, 24, 17, 50),
      isha: DateTime.utc(2026, 10, 24, 19, 0),
    );

    final tomorrow = DailyPrayerTimes(
      fajr: DateTime.utc(2026, 10, 25, 4, 30),
      dhuhr: DateTime.utc(2026, 10, 25, 11, 45),
      asr: DateTime.utc(2026, 10, 25, 15, 0),
      maghrib: DateTime.utc(2026, 10, 25, 17, 50),
      isha: DateTime.utc(2026, 10, 25, 19, 0),
    );

    test('hanya jadwalkan sholat yang belum lewat waktu (masa depan)', () {
      // Sekarang pukul 12:00 UTC (Subuh & Dzuhur hari ini sudah lewat)
      final nowUtc = DateTime.utc(2026, 10, 24, 12, 0);

      final list = ReminderScheduler.buildScheduledList(
        nowUtc: nowUtc,
        todayTimes: today,
        tomorrowTimes: tomorrow,
        settings: ReminderSettings.defaultSettings(),
        utcOffsetMinutes: 420, // UTC+7
      );

      // Sisa hari ini: Ashar, Maghrib, Isya (3) + Besok: 5 waktu = Total 8
      expect(list.length, 8);
      expect(list.first.prayerName, PrayerName.asr);
      expect(list.first.scheduledTime, today.asr);
    });

    test('offset pengingat mengurangi scheduledTime secara tepat', () {
      // Isya jam 19:00, pasang offset 10 menit -> alarm jam 18:50
      final settings = ReminderSettings.defaultSettings().update(
        PrayerName.isha,
        offsetMinutes: 10,
      );

      final nowUtc = DateTime.utc(2026, 10, 24, 18, 0);

      final list = ReminderScheduler.buildScheduledList(
        nowUtc: nowUtc,
        todayTimes: today,
        tomorrowTimes: tomorrow,
        settings: settings,
        utcOffsetMinutes: 420,
      );

      final isyaNotification =
          list.firstWhere((n) => n.prayerName == PrayerName.isha);
      expect(isyaNotification.scheduledTime, DateTime.utc(2026, 10, 24, 18, 50));
      expect(isyaNotification.body, contains('10 menit lagi'));
    });

    test('sholat yang dimatikan tidak dimasukkan ke antrean notifikasi', () {
      final settings = ReminderSettings.defaultSettings()
          .update(PrayerName.fajr, isEnabled: false)
          .update(PrayerName.dhuhr, isEnabled: false)
          .update(PrayerName.asr, isEnabled: false)
          .update(PrayerName.maghrib, isEnabled: false)
          .update(PrayerName.isha, isEnabled: false);

      final nowUtc = DateTime.utc(2026, 10, 24, 1, 0);

      final list = ReminderScheduler.buildScheduledList(
        nowUtc: nowUtc,
        todayTimes: today,
        tomorrowTimes: tomorrow,
        settings: settings,
        utcOffsetMinutes: 420,
      );

      expect(list, isEmpty);
    });
  });
}