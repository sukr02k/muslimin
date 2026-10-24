/// Konverter kalender Masehi ke kalender Hijriah (Umm al-Qura approximation).
/// Berjalan 100% offline secara matematis tanpa dependensi eksternal.
abstract final class HijriCalendar {
  static const List<String> monthNamesId = [
    'Muharram',
    'Safar',
    'Rabiul Awwal',
    'Rabiul Akhir',
    'Jumadil Awwal',
    'Jumadil Akhir',
    'Rajab',
    'Sya\'ban',
    'Ramadhan',
    'Syawwal',
    'Dzulqa\'dah',
    'Dzulhijjah',
  ];

  /// Mengonversi objek [DateTime] Masehi menjadi string tanggal Hijriah lengkap.
  /// Contoh: "13 Rabiul Akhir 1448 H"
  static String formatHijri(DateTime date) {
    final hijri = fromGregorian(date);
    final monthName = monthNamesId[hijri.month - 1];
    return '${hijri.day} $monthName ${hijri.year} H';
  }

  /// Konversi algoritma astronomis Kuweit / Julian Day Number ke Hijriah.
  static ({int day, int month, int year}) fromGregorian(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;

    if (year < 1900) {
      return (day: 1, month: 1, year: 1400);
    }

    int m = month;
    int y = year;
    if (m < 3) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524;

    // Epoch Hijriah: Julian Day 1948439.5
    final z = jd - 1948440 + 10632;
    final n = ((z - 1) / 10631).floor();
    final z2 = z - 10631 * n + 354;

    final j = ((10985 - z2) / 5316).floor() * ((50 * z2) / 17719).floor() +
        (z2 / 5670).floor() * ((43 * z2) / 15238).floor();
    final z3 = z2 -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;

    final hMonth = ((24 * z3) / 709).floor();
    final hDay = z3 - ((709 * hMonth) / 24).floor();
    final hYear = 30 * n + j - 30;

    return (
      day: hDay.clamp(1, 30),
      month: hMonth.clamp(1, 12),
      year: hYear,
    );
  }
}