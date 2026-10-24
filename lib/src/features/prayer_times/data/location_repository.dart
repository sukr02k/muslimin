import 'dart:math' as math;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/geo_location.dart';
import 'cities.dart';

class LocationUnavailableError implements Exception {
  const LocationUnavailableError(this.message);

  final String message;
}

class LocationRepository {
  const LocationRepository();

  List<GeoLocation> get cities => indonesianCities;

  GeoLocation get defaultCity => indonesianCities.first; // Jakarta

  /// Ambil lokasi GPS dengan nama daerah cerdas.
  ///
  /// 1. Coba reverse geocoding via native OS (Google Play Services / Android Geocoder).
  /// 2. Jika offline/gagal, cari nama kota terdekat dari database 40+ kota lokal via formula Haversine.
  Future<GeoLocation> currentGpsLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationUnavailableError(
        'Layanan lokasi nonaktif. Aktifkan GPS atau pilih kota manual.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationUnavailableError(
        'Izin lokasi ditolak. Pilih kota manual.',
      );
    }

    final position = await Geolocator.getCurrentPosition();
    final lat = position.latitude;
    final lng = position.longitude;

    // Resolusi nama daerah cerdas
    final resolvedLabel = await resolveAreaName(lat, lng);

    return GeoLocation(
      label: resolvedLabel,
      latitude: lat,
      longitude: lng,
      utcOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
    );
  }

  /// Resolusi nama daerah: coba Geocoder native -> fallback hitung kota lokal terdekat.
  Future<String> resolveAreaName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(const Duration(seconds: 4));

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // Prioritas label: SubAdministrativeArea (Kota/Kab) -> Locality (Kecamatan/Kota) -> AdministrativeArea (Provinsi)
        final city = p.subAdministrativeArea?.isNotEmpty == true
            ? p.subAdministrativeArea
            : (p.locality?.isNotEmpty == true ? p.locality : p.administrativeArea);

        if (city != null && city.trim().isNotEmpty) {
          // Bersihkan prefix umum seperti "Kota ", "Kabupaten " agar ringkas dan rapi
          final cleanCity = city
              .replaceAll(RegExp(r'^(Kota|Kabupaten|Kab\.)\s+', caseSensitive: false), '')
              .trim();

          // Jika ada nama kecamatan (locality) yang berbeda dari kota, bisa tambahkan
          final subArea = p.locality;
          if (subArea != null &&
              subArea.trim().isNotEmpty &&
              subArea.toLowerCase() != city.toLowerCase()) {
            return '$cleanCity (${subArea.trim()})';
          }
          return cleanCity;
        }
      }
    } catch (_) {
      // Offline atau geocoder timeout -> lanjut ke fallback lokal
    }

    // Fallback murni offline: cari kota terdekat dari daftar koordinat kota Indonesia
    return findNearestCityName(latitude, longitude);
  }

  /// Hitung kota terdekat berdasarkan koordinat menggunakan rumus Haversine (Great-Circle Distance).
  String findNearestCityName(double latitude, double longitude) {
    if (indonesianCities.isEmpty) return 'Lokasi Anda';

    GeoLocation nearest = indonesianCities.first;
    double minDistance = double.infinity;

    for (final city in indonesianCities) {
      final d = _haversineDistanceKm(
        latitude,
        longitude,
        city.latitude,
        city.longitude,
      );
      if (d < minDistance) {
        minDistance = d;
        nearest = city;
      }
    }

    // Jika jaraknya wajar (< 100 km), gunakan nama kota tersebut
    if (minDistance <= 100.0) {
      return nearest.label;
    }

    return 'Sekitar ${nearest.label}';
  }

  /// Rumus Haversine untuk menghitung jarak antara 2 koordinat (dalam Kilometer).
  static double _haversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
}