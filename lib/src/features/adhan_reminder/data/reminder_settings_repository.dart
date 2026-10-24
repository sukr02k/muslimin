import '../../../core/settings/app_settings_repository.dart';
import '../domain/reminder_models.dart';

class ReminderSettingsRepository {
  ReminderSettingsRepository(this._settingsRepo);

  final AppSettingsRepository _settingsRepo;

  static const _storageKey = 'adhan_reminder_settings_json';

  Future<ReminderSettings> load() async {
    final raw = await _settingsRepo.get(_storageKey);
    if (raw == null || raw.isEmpty) {
      return ReminderSettings.defaultSettings();
    }
    return ReminderSettings.fromJson(raw);
  }

  Future<void> save(ReminderSettings settings) async {
    await _settingsRepo.set(_storageKey, settings.toJson());
  }
}