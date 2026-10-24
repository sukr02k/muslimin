import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../domain/quran_models.dart';
import '../domain/quran_parser.dart';

class QuranRepository {
  QuranRepository({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;

  Future<List<Surah>> loadSurahList() async {
    final json = await bundle.loadString('assets/quran/surah_list.json');
    return parseSurahList(json);
  }

  Future<SurahWithAyahs> loadSurah(int number) async {
    final json = await bundle.loadString('assets/quran/surah/$number.json');
    return parseSurah(json);
  }
}