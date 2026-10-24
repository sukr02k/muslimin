import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/quran_bookmark_repository.dart';
import '../data/quran_repository.dart';
import '../data/reading_progress_repository.dart';
import '../domain/quran_models.dart';

final quranRepositoryProvider = Provider<QuranRepository>(
  (ref) => QuranRepository(),
);

final quranBookmarkRepositoryProvider = Provider<QuranBookmarkRepository>(
  (ref) => QuranBookmarkRepository(ref.watch(appDatabaseProvider)),
);

final readingProgressRepositoryProvider = Provider<ReadingProgressRepository>(
  (ref) => ReadingProgressRepository(ref.watch(appDatabaseProvider)),
);

final surahListProvider = FutureProvider<List<Surah>>(
  (ref) => ref.watch(quranRepositoryProvider).loadSurahList(),
);

final surahProvider = FutureProvider.family<SurahWithAyahs, int>(
  (ref, number) => ref.watch(quranRepositoryProvider).loadSurah(number),
);

/// Provider untuk daftar detail bookmark (nama surah, teks arab, terjemahan).
final bookmarkDetailsProvider = FutureProvider<List<BookmarkDetail>>((ref) async {
  // Pantau bookmarksProvider agar reaktif saat ada bookmark yang di-toggle
  ref.watch(bookmarksProvider);
  final bookmarkList = await ref.watch(quranBookmarkRepositoryProvider).bookmarks();
  if (bookmarkList.isEmpty) return [];

  final quranRepo = ref.watch(quranRepositoryProvider);
  final surahs = await quranRepo.loadSurahList();
  final surahMap = {for (final s in surahs) s.number: s};

  final details = <BookmarkDetail>[];
  for (final b in bookmarkList) {
    try {
      final surahData = await quranRepo.loadSurah(b.surahNumber);
      final ayah = surahData.ayahs.firstWhere(
        (a) => a.number == b.ayahNumber,
        orElse: () => Ayah(number: b.ayahNumber, arabic: '', translation: ''),
      );
      final meta = surahMap[b.surahNumber];

      details.add(
        BookmarkDetail(
          surahNumber: b.surahNumber,
          ayahNumber: b.ayahNumber,
          surahName: meta?.name ?? surahData.name,
          surahLatin: meta?.latin ?? surahData.latin,
          arabicText: ayah.arabic,
          translation: ayah.translation,
        ),
      );
    } catch (_) {}
  }

  return details;
});

final bookmarksProvider =
    AsyncNotifierProvider<BookmarksNotifier, Set<(int, int)>>(
  BookmarksNotifier.new,
);

class BookmarksNotifier extends AsyncNotifier<Set<(int, int)>> {
  @override
  Future<Set<(int, int)>> build() async {
    final list = await ref.watch(quranBookmarkRepositoryProvider).bookmarks();
    return {
      for (final b in list) (b.surahNumber, b.ayahNumber),
    };
  }

  Future<void> toggle(int surah, int ayah) async {
    final repo = ref.read(quranBookmarkRepositoryProvider);
    final current = state.value ?? const <(int, int)>{};
    final set = Set<(int, int)>.from(current);
    final key = (surah, ayah);
    if (set.contains(key)) {
      await repo.remove(surah, ayah);
      set.remove(key);
    } else {
      await repo.add(surah, ayah);
      set.add(key);
    }
    state = AsyncData(set);
    ref.invalidate(bookmarkDetailsProvider);
  }

  bool isBookmarked(int surah, int ayah) =>
      (state.value ?? const <(int, int)>{}).contains((surah, ayah));
}

final readingPositionProvider =
    AsyncNotifierProvider<ReadingPositionNotifier, ReadingPosition?>(
  ReadingPositionNotifier.new,
);

class ReadingPositionNotifier extends AsyncNotifier<ReadingPosition?> {
  @override
  Future<ReadingPosition?> build() =>
      ref.watch(readingProgressRepositoryProvider).load();

  Future<void> save(int surah, int ayah) async {
    await ref.read(readingProgressRepositoryProvider).save(surah, ayah);
    state = AsyncData(ReadingPosition(surahNumber: surah, ayahNumber: ayah));
  }
}

/// Ukuran font teks Arab Al-Qur'an (default: 26.0 sp).
final quranArabicFontSizeProvider =
    NotifierProvider<QuranArabicFontSizeNotifier, double>(
  QuranArabicFontSizeNotifier.new,
);

class QuranArabicFontSizeNotifier extends Notifier<double> {
  static const _storageKey = 'quran_arabic_font_size';
  static const double defaultSize = 26.0;

  @override
  double build() {
    final settingsRepo = ref.watch(appSettingsRepositoryProvider);
    // Muat preferensi ukuran font dari database lokal
    settingsRepo.get(_storageKey).then((val) {
      if (val != null) {
        final parsed = double.tryParse(val);
        if (parsed != null && parsed >= 20.0 && parsed <= 40.0) {
          state = parsed;
        }
      }
    });
    return defaultSize;
  }

  Future<void> setFontSize(double size) async {
    state = size;
    final settingsRepo = ref.read(appSettingsRepositoryProvider);
    await settingsRepo.set(_storageKey, size.toString());
  }
}