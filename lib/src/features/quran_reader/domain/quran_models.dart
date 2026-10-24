class Surah {
  const Surah({
    required this.number,
    required this.name,
    required this.latin,
    required this.ayahCount,
    this.place = 'Meccan',
  });

  final int number;
  final String name; // teks Arab
  final String latin; // transliterasi
  final int ayahCount;
  final String place; // Meccan / Medinan

  String get placeId => place == 'Medinan' ? 'Madaniyyah' : 'Makkiyyah';
}

class Ayah {
  const Ayah({
    required this.number,
    required this.arabic,
    required this.translation,
  });

  final int number;
  final String arabic;
  final String translation;
}

class SurahWithAyahs {
  const SurahWithAyahs({
    required this.number,
    required this.name,
    required this.latin,
    required this.ayahs,
    this.place = 'Meccan',
  });

  final int number;
  final String name;
  final String latin;
  final List<Ayah> ayahs;
  final String place;

  String get placeId => place == 'Medinan' ? 'Madaniyyah' : 'Makkiyyah';
}

class AyahBookmark {
  const AyahBookmark({
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;
}

class BookmarkDetail {
  const BookmarkDetail({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.surahLatin,
    required this.arabicText,
    required this.translation,
  });

  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String surahLatin;
  final String arabicText;
  final String translation;
}

class ReadingPosition {
  const ReadingPosition({
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;
}