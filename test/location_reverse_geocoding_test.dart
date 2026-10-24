import 'package:flutter_test/flutter_test.dart';
import 'package:muslimin/src/features/prayer_times/data/location_repository.dart';

void main() {
  group('LocationRepository - Smart Area Resolution & Fallback', () {
    const repo = LocationRepository();

    test('findNearestCityName mengembalikan nama kota yang presisi via Haversine', () {
      // Koordinat Monas Jakarta (-6.1754, 106.8272) -> harus mendeteksi Jakarta
      final nameJakarta = repo.findNearestCityName(-6.1754, 106.8272);
      expect(nameJakarta, 'Jakarta');

      // Koordinat Dago Bandung (-6.8850, 107.6136) -> harus mendeteksi Bandung
      final nameBandung = repo.findNearestCityName(-6.8850, 107.6136);
      expect(nameBandung, 'Bandung');

      // Koordinat Tunjungan Surabaya (-7.2600, 112.7400) -> harus mendeteksi Surabaya
      final nameSurabaya = repo.findNearestCityName(-7.2600, 112.7400);
      expect(nameSurabaya, 'Surabaya');
    });

    test('Kota default tersedia dan daftar kota tidak kosong', () {
      expect(repo.cities, isNotEmpty);
      expect(repo.defaultCity.label, 'Jakarta');
    });

    test('Kota di Kalimantan Timur terdeteksi sesuai daftar koordinat', () {
      // Dekat Balikpapan (-1.24, 116.86)
      final name = repo.findNearestCityName(-1.24, 116.86);
      expect(name, 'Balikpapan');
    });
  });
}