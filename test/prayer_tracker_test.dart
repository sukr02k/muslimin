import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimin/src/core/database/app_database.dart';
import 'package:muslimin/src/core/prayer_name.dart';
import 'package:muslimin/src/features/prayer_tracker/data/prayer_tracker_repository.dart';
import 'package:muslimin/src/features/prayer_tracker/domain/prayer_status.dart';
import 'package:muslimin/src/features/prayer_tracker/domain/prayer_tracker_summary.dart';

void main() {
  group('computeStreak', () {
    test('tidak ada hari done -> 0', () {
      expect(computeStreak(<DateTime>{}, DateTime(2026, 10, 24)), 0);
    });

    test('hari ini & kemarin done -> 2', () {
      final days = {DateTime(2026, 10, 24), DateTime(2026, 10, 23)};
      expect(computeStreak(days, DateTime(2026, 10, 24)), 2);
    });

    test('hari ini belum lengkap, hitung mulai kemarin', () {
      final days = {DateTime(2026, 10, 23), DateTime(2026, 10, 22)};
      expect(computeStreak(days, DateTime(2026, 10, 24)), 2);
    });

    test('celah menghentikan streak', () {
      final days = {DateTime(2026, 10, 24), DateTime(2026, 10, 22)};
      expect(computeStreak(days, DateTime(2026, 10, 24)), 1);
    });
  });

  group('PrayerTrackerRepository & Weekly Progress', () {
    late AppDatabase db;
    late PrayerTrackerRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = PrayerTrackerRepository(db);
    });

    tearDown(() => db.close());

    test('simpan lalu baca status', () async {
      final date = DateTime(2026, 10, 24);
      await repo.setStatus(date, PrayerName.fajr, PrayerStatus.done);

      final statuses = await repo.statusesFor(date);
      expect(statuses[PrayerName.fajr], PrayerStatus.done);
      expect(statuses.length, 1);
    });

    test('summary menghasilkan weeklyProgress 7 hari berurutan', () async {
      final date = DateTime(2026, 10, 24);
      for (final name in PrayerName.values) {
        await repo.setStatus(date, name, PrayerStatus.done);
      }

      final summary = await repo.summary(date);
      expect(summary.streak, 1);
      expect(summary.doneLast7Days, 5);
      expect(summary.weeklyProgress.length, 7);

      // Hari terakhir pada list adalah hari ini
      final todayProgress = summary.weeklyProgress.last;
      expect(todayProgress.isToday, isTrue);
      expect(todayProgress.doneCount, 5);
      expect(todayProgress.isFullyCompleted, isTrue);
      expect(todayProgress.ratio, 1.0);
    });
  });
}