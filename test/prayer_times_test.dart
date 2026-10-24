import 'package:flutter_test/flutter_test.dart';
import 'package:muslimin/src/features/prayer_times/domain/daily_prayer_times.dart';
import 'package:muslimin/src/features/prayer_times/domain/geo_location.dart';
import 'package:muslimin/src/features/prayer_times/domain/prayer_settings.dart';
import 'package:muslimin/src/features/prayer_times/domain/prayer_times_calculator.dart';

void main() {
  const calculator = PrayerTimesCalculator();
  const jakarta = GeoLocation(
    label: 'Jakarta',
    latitude: -6.2088,
    longitude: 106.8456,
    utcOffsetMinutes: 420,
  );
  const settings = PrayerSettings();
  final date = DateTime(2026, 10, 24);

  group('PrayerTimesCalculator', () {
    test('lima waktu valid dan berurutan', () {
      final t = calculator.forDate(jakarta, date, settings);

      expect(t.fajr.isBefore(t.dhuhr), isTrue);
      expect(t.dhuhr.isBefore(t.asr), isTrue);
      expect(t.asr.isBefore(t.maghrib), isTrue);
      expect(t.maghrib.isBefore(t.isha), isTrue);
    });

    test('waktu Jakarta masuk rentang wajar (jam lokal)', () {
      final t = calculator.forDate(jakarta, date, settings);
      final offset = const Duration(minutes: 420);

      expect(t.fajr.add(offset).hour, inInclusiveRange(3, 5));
      expect(t.dhuhr.add(offset).hour, inInclusiveRange(11, 12));
      expect(t.asr.add(offset).hour, inInclusiveRange(14, 16));
      expect(t.maghrib.add(offset).hour, inInclusiveRange(17, 18));
      expect(t.isha.add(offset).hour, inInclusiveRange(18, 20));
    });

    test('mazhab Hanafi membuat Ashar lebih lambat dari Syafi\'i', () {
      final shafi = calculator.forDate(jakarta, date, settings);
      final hanafi = calculator.forDate(
        jakarta,
        date,
        const PrayerSettings(madhab: PrayerMadhab.hanafi),
      );

      expect(hanafi.asr.isAfter(shafi.asr), isTrue);
    });
  });

  group('nextPrayerAt', () {
    final today = DailyPrayerTimes(
      fajr: DateTime.utc(2026, 10, 24, 21, 0),
      dhuhr: DateTime.utc(2026, 10, 25, 4, 0),
      asr: DateTime.utc(2026, 10, 25, 7, 30),
      maghrib: DateTime.utc(2026, 10, 25, 10, 30),
      isha: DateTime.utc(2026, 10, 25, 12, 0),
    );
    final tomorrow = DailyPrayerTimes(
      fajr: DateTime.utc(2026, 10, 25, 21, 0),
      dhuhr: DateTime.utc(2026, 10, 26, 4, 0),
      asr: DateTime.utc(2026, 10, 26, 7, 30),
      maghrib: DateTime.utc(2026, 10, 26, 10, 30),
      isha: DateTime.utc(2026, 10, 26, 12, 0),
    );

    test('sebelum Subuh', () {
      final now = DateTime.utc(2026, 10, 24, 20, 0);
      expect(nextPrayerAt(now, today, tomorrow).name, PrayerName.fajr);
    });

    test('setelah Isya -> Subuh besok', () {
      final now = DateTime.utc(2026, 10, 25, 13, 0);
      final next = nextPrayerAt(now, today, tomorrow);
      expect(next.name, PrayerName.fajr);
      expect(next.time, tomorrow.fajr);
    });
  });

  group('formatHhMm', () {
    test('menambah offset dan memformat 24 jam', () {
      // 04:00 UTC + 7 jam = 11:00 WIB.
      expect(formatHhMm(DateTime.utc(2026, 1, 1, 4, 0), 420), '11:00');
      expect(formatHhMm(DateTime.utc(2026, 1, 1, 0, 5), 0), '00:05');
    });
  });
}