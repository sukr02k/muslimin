import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimin/src/core/database/app_database.dart';
import 'package:muslimin/src/core/settings/app_settings_repository.dart';

void main() {
  late AppDatabase db;
  late AppSettingsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AppSettingsRepository(db);
  });

  tearDown(() => db.close());

  test('app_settings: baca key kosong mengembalikan null', () async {
    expect(await repo.get('belum-ada'), isNull);
  });

  test('app_settings: simpan lalu baca kembali', () async {
    await repo.set('kota', 'Jakarta');

    expect(await repo.get('kota'), 'Jakarta');
  });

  test('app_settings: update nilai menimpa nilai lama', () async {
    await repo.set('metode', 'Kemenag');
    await repo.set('metode', 'MWL');

    expect(await repo.get('metode'), 'MWL');
  });
}