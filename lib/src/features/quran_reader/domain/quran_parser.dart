import 'dart:convert';

import 'quran_models.dart';

/// Parse daftar surah dari JSON asset `surah_list.json`.
List<Surah> parseSurahList(String json) {
  final list = jsonDecode(json) as List;
  return [
    for (final e in list)
      Surah(
        number: e['number'] as int,
        name: e['name'] as String,
        latin: e['latin'] as String,
        ayahCount: e['ayahs'] as int,
        place: (e['place'] as String?) ?? 'Meccan',
      ),
  ];
}

/// Parse satu surah beserta ayat-ayatnya dari JSON asset `surah/{n}.json`.
SurahWithAyahs parseSurah(String json) {
  final map = jsonDecode(json) as Map<String, dynamic>;
  final ayahs = (map['ayahs'] as List);
  return SurahWithAyahs(
    number: map['number'] as int,
    name: map['name'] as String,
    latin: map['latin'] as String,
    place: (map['place'] as String?) ?? 'Meccan',
    ayahs: [
      for (final e in ayahs)
        Ayah(
          number: e['number'] as int,
          arabic: e['arabic'] as String,
          translation: e['translation'] as String,
        ),
    ],
  );
}