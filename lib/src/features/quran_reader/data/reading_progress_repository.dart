import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/quran_models.dart';

class ReadingProgressRepository {
  ReadingProgressRepository(this._db);

  final AppDatabase _db;

  Future<void> save(int surahNumber, int ayahNumber) async {
    await _db.into(_db.readingProgress).insert(
          ReadingProgressCompanion.insert(
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
          ),
        );
  }

  Future<ReadingPosition?> load() async {
    final row = await (_db.select(_db.readingProgress)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return ReadingPosition(
      surahNumber: row.surahNumber,
      ayahNumber: row.ayahNumber,
    );
  }
}