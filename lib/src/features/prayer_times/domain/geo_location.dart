/// Lokasi geografis + offset UTC dalam menit.
class GeoLocation {
  const GeoLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.utcOffsetMinutes,
  });

  final String label;
  final double latitude;
  final double longitude;
  final int utcOffsetMinutes;

  Duration get utcOffset => Duration(minutes: utcOffsetMinutes);
}