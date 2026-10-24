/// Kumpulan mutiara ayat & hadits seputar sholat dan ketenangan jiwa.
/// Berganti secara otomatis dan deterministik setiap hari tanpa perlu koneksi internet.
class DailyReflection {
  const DailyReflection({
    required this.text,
    required this.source,
  });

  final String text;
  final String source;

  static const List<DailyReflection> _reflections = [
    DailyReflection(
      text: 'Sesungguhnya sholat itu adalah fardhu yang ditentukan waktunya atas orang-orang yang beriman.',
      source: 'QS. An-Nisa: 103',
    ),
    DailyReflection(
      text: 'Dan dirikanlah sholat untuk mengingat-Ku.',
      source: 'QS. Thaha: 14',
    ),
    DailyReflection(
      text: 'Amalan yang pertama kali dihisab dari seorang hamba pada hari kiamat adalah sholatnya.',
      source: 'HR. Tirmidzi & Abu Dawud',
    ),
    DailyReflection(
      text: 'Jadikanlah sabar dan sholat sebagai penolongmu.',
      source: 'QS. Al-Baqarah: 45',
    ),
    DailyReflection(
      text: 'Sesungguhnya sholat itu mencegah dari perbuatan keji dan mungkar.',
      source: 'QS. Al-Ankabut: 45',
    ),
    DailyReflection(
      text: 'Kesejukan dan ketenangan mataku dijadikan di dalam sholat.',
      source: 'HR. An-Nasa\'i & Ahmad',
    ),
    DailyReflection(
      text: 'Keadaan paling dekat antara seorang hamba dengan Tuhannya adalah ketika ia sedang sujud, maka perbanyaklah doa.',
      source: 'HR. Muslim',
    ),
    DailyReflection(
      text: 'Peliharalah semua sholatmu, dan peliharalah sholat wustha (Ashar). Berdirilah untuk Allah dengan khusyuk.',
      source: 'QS. Al-Baqarah: 238',
    ),
    DailyReflection(
      text: 'Barangsiapa menjaga sholat lima waktu, maka baginya cahaya, petunjuk, dan keselamatan pada hari kiamat.',
      source: 'HR. Ahmad',
    ),
    DailyReflection(
      text: 'Perumpamaan sholat lima waktu seperti sungai yang mengalir deras di depan pintu rumah salah seorang di antara kalian, ia mandi darinya lima kali sehari.',
      source: 'HR. Muslim',
    ),
    DailyReflection(
      text: 'Wahai orang-orang yang beriman! Ingatlah kepada Allah dengan mengingat nama-Nya sebanyak-banyaknya.',
      source: 'QS. Al-Ahzab: 41',
    ),
    DailyReflection(
      text: 'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.',
      source: 'QS. Ar-Ra\'d: 28',
    ),
  ];

  /// Mengambil kutipan mutiara harian yang berganti deterministik berdasarkan tanggal [date].
  static DailyReflection forDate(DateTime date) {
    // Hitung hari Julian / epoch day agar setiap tanggal punya indeks mutiara tetap
    final dayNumber = date.year * 365 + date.month * 31 + date.day;
    final index = dayNumber % _reflections.length;
    return _reflections[index];
  }
}