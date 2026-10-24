class DayProgress {
  const DayProgress({
    required this.date,
    required this.doneCount,
    required this.isToday,
  });

  final DateTime date;
  final int doneCount;
  final bool isToday;

  bool get isFullyCompleted => doneCount >= 5;
  double get ratio => (doneCount / 5.0).clamp(0.0, 1.0);
}

class PrayerTrackerSummary {
  const PrayerTrackerSummary({
    required this.streak,
    required this.doneLast7Days,
    this.weeklyProgress = const [],
  });

  /// Jumlah hari berturut-turut dengan semua 5 sholat berstatus done.
  final int streak;

  /// Jumlah sholat berstatus done dalam 7 hari terakhir (termasuk hari ini).
  final int doneLast7Days;

  /// Progress 7 hari terakhir secara berurutan dari H-6 s/d Hari ini.
  final List<DayProgress> weeklyProgress;
}

/// Normalisasi DateTime ke tanggal saja (jam 00:00 lokal).
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Hitung streak mundur dari [todayLocal].
/// Jika hari ini belum lengkap, streak tidak dianggap putus (mulai dari kemarin).
int computeStreak(Set<DateTime> allDoneDays, DateTime todayLocal) {
  final today = dateOnly(todayLocal);
  var cursor = allDoneDays.contains(today)
      ? today
      : today.subtract(const Duration(days: 1));
  var streak = 0;
  while (allDoneDays.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}