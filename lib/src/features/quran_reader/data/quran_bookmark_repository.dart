import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/quran_models.dart';

class QuranBookmarkRepository {
  QuranBookmarkRepository(this._db);

  final AppDatabase _db;

  Future<void> add(int surahNumber, int ayahNumber) async {
    // Cek-dan-sisipkan dalam transaksi agar tidak duplikat saat tap cepat.
    await _db.transaction(() async {
      final exists = await (_db.select(_db.quranBookmarks)
            ..where(
              (t) =>
                  t.surahNumber.equals(surahNumber) &
                  t.ayahNumber.equals(ayahNumber),
            ))
          .getSingleOrNull();
      if (exists == null) {
        await _db.into(_db.quranBookmarks).insert(
              QuranBookmarksCompanion.insert(
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
              ),
            );
      }
    });
  }

  Future<void> remove(int surahNumber, int ayahNumber) async {
    await (_db.delete(_db.quranBookmarks)
          ..where(
            (t) =>
                t.surahNumber.equals(surahNumber) &
                t.ayahNumber.equals(ayahNumber),
          ))
        .go();
  }

  Future<List<AyahBookmark>> bookmarks() async {
    final rows = await (_db.select(_db.quranBookmarks)
          ..orderBy([
            (t) => OrderingTerm.asc(t.surahNumber),
            (t) => OrderingTerm.asc(t.ayahNumber),
          ]))
        .get();
    return [
      for (final r in rows)
        AyahBookmark(surahNumber: r.surahNumber, ayahNumber: r.ayahNumber),
    ];
  }
}