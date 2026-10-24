class DhikrItem {
  const DhikrItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.targetCount,
  });

  final String id;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final int targetCount;
}

class DailyDuaItem {
  const DailyDuaItem({
    required this.id,
    required this.title,
    required this.category,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.source = '',
  });

  final String id;
  final String title;
  final String category;
  final String arabic;
  final String latin;
  final String translation;
  final String source;
}

const List<DhikrItem> dailyDhikrList = [
  DhikrItem(
    id: 'istighfar',
    title: 'Istighfar',
    arabic: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ',
    latin: 'Astaghfirullahal \'adzim',
    translation: 'Aku memohon ampun kepada Allah Yang Maha Agung.',
    targetCount: 33,
  ),
  DhikrItem(
    id: 'tasbih',
    title: 'Tasbih',
    arabic: 'سُبْحَانَ اللَّهِ',
    latin: 'Subhanallah',
    translation: 'Maha Suci Allah.',
    targetCount: 33,
  ),
  DhikrItem(
    id: 'tahmid',
    title: 'Tahmid',
    arabic: 'الْحَمْدُ لِلَّهِ',
    latin: 'Alhamdulillah',
    translation: 'Segala puji bagi Allah.',
    targetCount: 33,
  ),
  DhikrItem(
    id: 'takbir',
    title: 'Takbir',
    arabic: 'اللَّهُ أَكْبَرُ',
    latin: 'Allahu Akbar',
    translation: 'Allah Maha Besar.',
    targetCount: 33,
  ),
  DhikrItem(
    id: 'tahlil',
    title: 'Tahlil Lengkap',
    arabic:
        'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    latin:
        'Laa ilaaha illallaahu wahdahu laa syariika lah, lahul mulku wa lahul hamdu wa huwa \'alaa kulli syai-in qadiir',
    translation:
        'Tidak ada tuhan selain Allah yang Maha Esa, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan pujian, dan Dia Maha Kuasa atas segala sesuatu.',
    targetCount: 10,
  ),
  DhikrItem(
    id: 'hauqalah',
    title: 'Hauqalah',
    arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
    latin: 'Laa hawla wa laa quwwata illaa billaahil \'aliyyil \'adziim',
    translation:
        'Tiada daya dan upaya kecuali dengan pertolongan Allah Yang Maha Tinggi lagi Maha Agung.',
    targetCount: 33,
  ),
  DhikrItem(
    id: 'sholawat',
    title: 'Shalawat Nabi',
    arabic: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِ سَيِّدِنَا مُحَمَّدٍ',
    latin: 'Allahumma shalli \'alaa sayyidinaa Muhammad wa \'alaa aali sayyidinaa Muhammad',
    translation:
        'Ya Allah, limpahkanlah rahmat kepada junjungan kami Nabi Muhammad beserta keluarganya.',
    targetCount: 100,
  ),
];

const List<DailyDuaItem> dailyDuaList = [
  DailyDuaItem(
    id: 'sapujagad',
    title: 'Doa Sapujagad (Kebaikan Dunia & Akhirat)',
    category: 'Harian',
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    latin: 'Rabbanaa aatinaa fid-dunyaa hasanah, wa fil-aakhirati hasanah, wa qinaa \'adzaaban-naar',
    translation: 'Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat, dan lindungilah kami dari azab neraka.',
    source: 'QS. Al-Baqarah: 201',
  ),
  DailyDuaItem(
    id: 'orangtua',
    title: 'Doa untuk Kedua Orang Tua',
    category: 'Keluarga',
    arabic: 'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
    latin: 'Rabbighfir lii wa liwaalidayya warhamhumaa kamaa rabbayaanii shaghiiraa',
    translation: 'Wahai Tuhanku, ampunilah aku dan kedua orang tuaku, dan sayangilah mereka keduanya sebagaimana mereka telah mendidik aku di waktu kecil.',
    source: 'QS. Al-Isra: 24',
  ),
  DailyDuaItem(
    id: 'bangun_tidur',
    title: 'Doa Bangun Tidur',
    category: 'Aktivitas',
    arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    latin: 'Alhamdulillahil-ladzii ahyaanaa ba\'da maa amaatanaa wa ilaihin-nusyuur',
    translation: 'Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami dan kepada-Nya kami kembali.',
    source: 'HR. Bukhari',
  ),
  DailyDuaItem(
    id: 'sebelum_tidur',
    title: 'Doa Sebelum Tidur',
    category: 'Aktivitas',
    arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    latin: 'Bismikallaahumma amuutu wa ahyaa',
    translation: 'Dengan nama-Mu ya Allah, aku mati dan aku hidup.',
    source: 'HR. Bukhari',
  ),
  DailyDuaItem(
    id: 'keluar_rumah',
    title: 'Doa Keluar Rumah',
    category: 'Bepergian',
    arabic: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    latin: 'Bismillaahi tawakkaltu \'alallaahi, laa hawla wa laa quwwata illaa billaah',
    translation: 'Dengan nama Allah, aku bertawakal kepada Allah. Tiada daya dan upaya kecuali dengan pertolongan Allah.',
    source: 'HR. Abu Dawud & Tirmidzi',
  ),
  DailyDuaItem(
    id: 'masuk_masjid',
    title: 'Doa Masuk Masjid',
    category: 'Ibadah',
    arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
    latin: 'Allaahummaftah lii abwaaba rahmatik',
    translation: 'Ya Allah, bukakanlah bagiku pintu-pintu rahmat-Mu.',
    source: 'HR. Muslim',
  ),
  DailyDuaItem(
    id: 'keluar_masjid',
    title: 'Doa Keluar Masjid',
    category: 'Ibadah',
    arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
    latin: 'Allaahumma innii as-aluka min fadhlik',
    translation: 'Ya Allah, sesungguhnya aku memohon keutamaan dari-Mu.',
    source: 'HR. Muslim',
  ),
  DailyDuaItem(
    id: 'ilmu_rejeki',
    title: 'Doa Memohon Ilmu, Rezeki & Amal Baik',
    category: 'Harian',
    arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا',
    latin: 'Allaahumma innii as-aluka \'ilman naafi\'aa, wa rizqan thayyibaa, wa \'amalan mutaqabbalaa',
    translation: 'Ya Allah, sesungguhnya aku memohon kepada-Mu ilmu yang bermanfaat, rezeki yang baik, dan amalan yang diterima.',
    source: 'HR. Ibnu Majah',
  ),
];