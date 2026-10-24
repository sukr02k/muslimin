import 'package:flutter_test/flutter_test.dart';
import 'package:muslimin/src/features/qibla_finder/domain/qibla_calculator.dart';

void main() {
  group('QiblaCalculator.calculateBearing', () {
    test('Jakarta: bearing kiblat berkisar 295° (arah Barat Laut)', () {
      // Koordinat Monas Jakarta: -6.1754, 106.8272
      final bearing = QiblaCalculator.calculateBearing(-6.1754, 106.8272);
      expect(bearing, inInclusiveRange(294.0, 296.0));
    });

    test('Surabaya: bearing kiblat berkisar 294°', () {
      // Koordinat Surabaya: -7.2575, 112.7521
      final bearing = QiblaCalculator.calculateBearing(-7.2575, 112.7521);
      expect(bearing, inInclusiveRange(293.0, 295.5));
    });

    test('Medan: bearing kiblat berkisar 292°', () {
      // Koordinat Medan: 3.5952, 98.6722
      final bearing = QiblaCalculator.calculateBearing(3.5952, 98.6722);
      expect(bearing, inInclusiveRange(291.0, 294.0));
    });

    test('Makassar: bearing kiblat berkisar 292°', () {
      // Koordinat Makassar: -5.1477, 119.4327
      final bearing = QiblaCalculator.calculateBearing(-5.1477, 119.4327);
      expect(bearing, inInclusiveRange(291.0, 293.5));
    });

    test('London: bearing kiblat berkisar 118° (arah Tenggara)', () {
      // Koordinat London: 51.5074, -0.1278
      final bearing = QiblaCalculator.calculateBearing(51.5074, -0.1278);
      expect(bearing, inInclusiveRange(117.0, 120.0));
    });

    test('Nilai bearing selalu dalam rentang 0 s/d 360 derajat', () {
      final samples = [
        [-6.2088, 106.8456],
        [35.6762, 139.6503], // Tokyo
        [-33.8688, 151.2093], // Sydney
        [40.7128, -74.0060], // New York
      ];
      for (final coords in samples) {
        final b = QiblaCalculator.calculateBearing(coords[0], coords[1]);
        expect(b >= 0.0 && b < 360.0, isTrue);
      }
    });
  });

  group('QiblaCalculator.headingDelta & isFacingQibla', () {
    test('heading sama dengan bearing -> delta 0, isFacing true', () {
      expect(QiblaCalculator.headingDelta(295.0, 295.0), 0.0);
      expect(QiblaCalculator.isFacingQibla(295.0, 295.0), isTrue);
    });

    test('toleransi default 3 derajat', () {
      expect(QiblaCalculator.isFacingQibla(293.0, 295.0), isTrue); // selisih 2°
      expect(QiblaCalculator.isFacingQibla(297.5, 295.0), isTrue); // selisih 2.5°
      expect(QiblaCalculator.isFacingQibla(290.0, 295.0), isFalse); // selisih 5°
    });

    test('perhitungan selisih melewati titik 0/360 derajat (wrap-around)', () {
      // Bearing 2 derajat, heading 359 derajat -> selisih hanya +3 derajat
      final delta = QiblaCalculator.headingDelta(359.0, 2.0);
      expect(delta, closeTo(3.0, 0.001));
      expect(QiblaCalculator.isFacingQibla(359.0, 2.0), isTrue);
    });
  });
}