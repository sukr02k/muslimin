import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimin/src/core/database/app_database.dart';
import 'package:muslimin/src/features/quran_reader/data/quran_bookmark_repository.dart';
import 'package:muslimin/src/features/quran_reader/data/reading_progress_repository.dart';
import 'package:muslimin/src/features/quran_reader/domain/quran_parser.dart';

const _listJson =
    '[{"number":1,"name":"ٱلْفَاتِحَةِ","latin":"Al-Faatiha","ayahs":7},'
    '{"number":2,"name":"البقرة","latin":"Al-Baqara","ayahs":286}]';

const _surahJson =
    '{"number":1,"name":"ٱلْفَاتِحَةِ","latin":"Al-Faatiha","ayahs":['
    '{"number":1,"arabic":"بِسْمِ","translation":"Dengan nama"},'
    '{"number":2,"arabic":"ٱلْحَمْدُ","translation":"Segala puji"}]}';

void main() {
  group('parseSurahList', () {
    test('parse semua field', () {
      final surahs = parseSurahList(_listJson);
      expect(surahs.length, 2);
      expect(surahs.first.number, 1);
      expect(surahs.first.name, 'ٱلْفَاتِحَةِ');
      expect(surahs.first.latin, 'Al-Faatiha');
      expect(surahs.first.ayahCount, 7);
    });
  });

  group('parseSurah', () {
    test('parse surah + ayat + terjemahan', () {
      final surah = parseSurah(_surahJson);
      expect(surah.number, 1);
      expect(surah.ayahs.length, 2);
      expect(surah.ayahs.first.number, 1);
      expect(surah.ayahs.first.arabic, 'بِسْمِ');
      expect(surah.ayahs.first.translation, 'Dengan nama');
    });
  });

  group('asset Quran', () {
    test('surah_list.json: 114 surah, total 6236 ayat', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final json = await rootBundle.loadString('assets/quran/surah_list.json');
      final surahs = parseSurahList(json);
      expect(surahs.length, 114);
      expect(surahs.first.number, 1);
      expect(surahs.first.name, 'ٱلْفَاتِحَةِ');
      expect(surahs.first.ayahCount, 7);
      final total = surahs.fold<int>(0, (sum, s) => sum + s.ayahCount);
      expect(total, 6236);
    });

    test('surah/1.json: Al-Fatihah 7 ayat valid', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final json = await rootBundle.loadString('assets/quran/surah/1.json');
      final surah = parseSurah(json);
      expect(surah.number, 1);
      expect(surah.ayahs.length, 7);
      expect(surah.ayahs.first.arabic, startsWith('بِسْمِ'));
      expect(surah.ayahs.first.translation, isNotEmpty);
    });
  });

  group('QuranBookmarkRepository', () {
    late AppDatabase db;
    late QuranBookmarkRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = QuranBookmarkRepository(db);
    });

    tearDown(() => db.close());

    test('add lalu bookmark tersimpan', () async {
      await repo.add(1, 1);
      final list = await repo.bookmarks();
      expect(list.length, 1);
      expect(list.first.surahNumber, 1);
      expect(list.first.ayahNumber, 1);
    });

    test('add ganda tidak duplikat', () async {
      await repo.add(1, 1);
      await repo.add(1, 1);
      expect((await repo.bookmarks()).length, 1);
    });

    test('remove menghapus bookmark', () async {
      await repo.add(1, 1);
      await repo.remove(1, 1);
      expect(await repo.bookmarks(), isEmpty);
    });
  });

  group('ReadingProgressRepository', () {
    late AppDatabase db;
    late ReadingProgressRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = ReadingProgressRepository(db);
    });

    tearDown(() => db.close());

    test('save lalu load', () async {
      await repo.save(1, 5);
      final p = await repo.load();
      expect(p, isNotNull);
      expect(p!.surahNumber, 1);
      expect(p.ayahNumber, 5);
    });

    test('load kosong -> null', () async {
      expect(await repo.load(), isNull);
    });

    test('load mengembalikan posisi terakhir', () async {
      await repo.save(1, 5);
      await repo.save(2, 10);
      final p = await repo.load();
      expect(p, isNotNull);
      expect(p!.surahNumber, 2);
      expect(p.ayahNumber, 10);
    });
  });
}