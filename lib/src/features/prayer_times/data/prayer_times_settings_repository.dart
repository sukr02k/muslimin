import '../../../core/settings/app_settings_repository.dart';
import '../domain/geo_location.dart';
import '../domain/prayer_settings.dart';

class PrayerTimesSettingsRepository {
  PrayerTimesSettingsRepository(this._settings);

  final AppSettingsRepository _settings;

  static const _methodKey = 'prayer.method';
  static const _madhabKey = 'prayer.madhab';
  static const _locLabelKey = 'location.label';
  static const _locLatKey = 'location.lat';
  static const _locLngKey = 'location.lng';
  static const _locOffsetKey = 'location.offset';

  Future<PrayerSettings> loadSettings() async {
    final method = await _settings.get(_methodKey);
    final madhab = await _settings.get(_madhabKey);
    return PrayerSettings(
      method: PrayerMethod.values.firstWhere(
        (m) => m.name == method,
        orElse: () => PrayerMethod.kemenag,
      ),
      madhab: PrayerMadhab.values.firstWhere(
        (m) => m.name == madhab,
        orElse: () => PrayerMadhab.shafi,
      ),
    );
  }

  Future<void> saveSettings(PrayerSettings settings) async {
    await _settings.set(_methodKey, settings.method.name);
    await _settings.set(_madhabKey, settings.madhab.name);
  }

  Future<GeoLocation?> loadLocation() async {
    final label = await _settings.get(_locLabelKey);
    final lat = await _settings.get(_locLatKey);
    final lng = await _settings.get(_locLngKey);
    final offset = await _settings.get(_locOffsetKey);
    if (label == null || lat == null || lng == null || offset == null) {
      return null;
    }
    return GeoLocation(
      label: label,
      latitude: double.parse(lat),
      longitude: double.parse(lng),
      utcOffsetMinutes: int.parse(offset),
    );
  }

  Future<void> saveLocation(GeoLocation location) async {
    await _settings.set(_locLabelKey, location.label);
    await _settings.set(_locLatKey, location.latitude.toString());
    await _settings.set(_locLngKey, location.longitude.toString());
    await _settings.set(_locOffsetKey, location.utcOffsetMinutes.toString());
  }
}