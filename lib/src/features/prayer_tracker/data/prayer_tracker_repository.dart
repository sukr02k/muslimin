import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/prayer_name.dart';
import '../domain/prayer_status.dart';
import '../domain/prayer_tracker_summary.dart';

class PrayerTrackerRepository {
  PrayerTrackerRepository(this._db);

  final AppDatabase _db;

  /// Status tiap sholat untuk satu tanggal. Sholat tanpa log tidak muncul.
  Future<Map<PrayerName, PrayerStatus>> statusesFor(DateTime date) async {
    final rows = await (_db.select(_db.prayerLogs)
          ..where((t) => t.prayerDate.equals(date)))
        .get();
    return {
      for (final row in rows)
        _prayerNameOf(row.prayerName): _statusOf(row.status),
    };
  }

  Future<void> setStatus(
    DateTime date,
    PrayerName name,
    PrayerStatus status,
  ) async {
    // Upsert manual dalam transaksi: satu log per (tanggal, sholat),
    // aman dari tap cepat (transaksi drift terserialisasi).
    await _db.transaction(() async {
      final existing = await (_db.select(_db.prayerLogs)
            ..where(
              (t) => t.prayerDate.equals(date) & t.prayerName.equals(name.name),
            ))
          .getSingleOrNull();

      final now = DateTime.now();
      if (existing == null) {
        await _db.into(_db.prayerLogs).insert(
              PrayerLogsCompanion.insert(
                prayerDate: date,
                prayerName: name.name,
                status: status.name,
                completedAt: Value(now),
              ),
            );
      } else {
        await (_db.update(_db.prayerLogs)
              ..where((t) => t.id.equals(existing.id)))
            .write(
          PrayerLogsCompanion(
            status: Value(status.name),
            completedAt: Value(now),
          ),
        );
      }
    });
  }

  Future<void> clearStatus(DateTime date, PrayerName name) async {
    await (_db.delete(_db.prayerLogs)
          ..where(
            (t) => t.prayerDate.equals(date) & t.prayerName.equals(name.name),
          ))
        .go();
  }

  /// Ringkasan progres (streak & jumlah done). Berbasis [PrayerStatus.done] saja.
  Future<PrayerTrackerSummary> summary(DateTime todayLocal) async {
    final doneLogs = await (_db.select(_db.prayerLogs)
          ..where((t) => t.status.equals(PrayerStatus.done.name)))
        .get();

    final counts = <DateTime, int>{};
    final today = dateOnly(todayLocal);
    final start = today.subtract(const Duration(days: 6));
    var doneLast7Days = 0;

    for (final log in doneLogs) {
      final day = dateOnly(log.prayerDate);
      counts[day] = (counts[day] ?? 0) + 1;
      if (!day.isBefore(start) && !day.isAfter(today)) {
        doneLast7Days++;
      }
    }

    final allDoneDays = {
      for (final e in counts.entries)
        if (e.value >= 5) e.key,
    };

    // Bangun data harian 7 hari terakhir (dari start s/d today)
    final weeklyProgress = <DayProgress>[];
    for (int i = 6; i >= 0; i--) {
      final currentDay = today.subtract(Duration(days: i));
      final done = counts[currentDay] ?? 0;
      weeklyProgress.add(
        DayProgress(
          date: currentDay,
          doneCount: done,
          isToday: i == 0,
        ),
      );
    }

    return PrayerTrackerSummary(
      streak: computeStreak(allDoneDays, today),
      doneLast7Days: doneLast7Days,
      weeklyProgress: weeklyProgress,
    );
  }

  PrayerName _prayerNameOf(String value) =>
      PrayerName.values.firstWhere((n) => n.name == value);

  PrayerStatus _statusOf(String value) =>
      PrayerStatus.values.firstWhere((s) => s.name == value);
}