import 'dart:math' as math;

import 'package:adhan/adhan.dart' as adhan;

/// Kalkulator arah kiblat (bearing) dalam derajat (0 - 360).
abstract final class QiblaCalculator {
  /// Koordinat Ka'bah di Masjidil Haram, Makkah.
  static const double makkahLat = 21.4225241;
  static const double makkahLng = 39.8261818;

  /// Hitung arah kiblat dari [latitude] & [longitude].
  ///
  /// Menggunakan rumus Great Circle Bearing standar spherical trigonometry:
  /// tan(θ) = sin(Δλ) / (cos(φ1) * tan(φ2) - sin(φ1) * cos(Δλ))
  /// Hasil dinormalisasi ke 0 - 360 derajat searah jarum jam dari Utara.
  static double calculateBearing(double latitude, double longitude) {
    // Manfaatkan kalkulasi terverifikasi dari paket adhan.
    final qibla = adhan.Qibla(adhan.Coordinates(latitude, longitude));
    return (qibla.direction % 360.0 + 360.0) % 360.0;
  }

  /// Hitung selisih sudut antara heading device dengan arah kiblat.
  ///
  /// Mengembalikan nilai dalam rentang -180 s/d +180 derajat.
  /// Nilai dekat 0 (|delta| <= [thresholdDegrees]) berarti device sudah menghadap kiblat.
  static double headingDelta(double deviceHeading, double qiblaBearing) {
    double diff = (qiblaBearing - deviceHeading) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return diff;
  }

  /// Cek apakah device sedang menghadap ke arah kiblat dalam toleransi [threshold].
  static bool isFacingQibla(
    double deviceHeading,
    double qiblaBearing, {
    double threshold = 3.0,
  }) {
    return headingDelta(deviceHeading, qiblaBearing).abs() <= threshold;
  }

  /// Konversi derajat ke radian untuk rotasi widget Flutter.
  static double toRadians(double degrees) => degrees * (math.pi / 180.0);
}