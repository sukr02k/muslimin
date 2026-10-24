import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/prayer_name.dart';
import '../../../core/providers.dart';
import '../../prayer_times/presentation/prayer_times_controllers.dart';
import '../data/local_notification_service.dart';
import '../data/reminder_settings_repository.dart';
import '../domain/reminder_models.dart';
import '../domain/reminder_scheduler.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  final service = LocalNotificationService();
  service.initialize();
  return service;
});

final reminderSettingsRepositoryProvider =
    Provider<ReminderSettingsRepository>((ref) {
  return ReminderSettingsRepository(ref.watch(appSettingsRepositoryProvider));
});

/// Notifier untuk mengelola state preferensi pengingat sholat (toggle & offset).
final reminderSettingsProvider =
    AsyncNotifierProvider<ReminderSettingsNotifier, ReminderSettings>(
  ReminderSettingsNotifier.new,
);

class ReminderSettingsNotifier extends AsyncNotifier<ReminderSettings> {
  @override
  Future<ReminderSettings> build() async {
    final repo = ref.watch(reminderSettingsRepositoryProvider);
    final settings = await repo.load();
    return settings;
  }

  Future<void> updateConfig(
    PrayerName name, {
    bool? isEnabled,
    int? offsetMinutes,
  }) async {
    final current = state.value ?? ReminderSettings.defaultSettings();
    final updated = current.update(
      name,
      isEnabled: isEnabled,
      offsetMinutes: offsetMinutes,
    );

    state = AsyncData(updated);
    await ref.read(reminderSettingsRepositoryProvider).save(updated);

    // Otomatis sinkronisasi ulang antrean notifikasi setelah setting berubah
    ref.read(notificationSyncProvider);
  }
}

/// Provider yang memantau waktu sholat & settings untuk sinkronisasi antrean notifikasi sistem.
final notificationSyncProvider = Provider<void>((ref) {
  final todayAsync = ref.watch(dailyPrayerTimesProvider);
  final tomorrowAsync = ref.watch(tomorrowPrayerTimesProvider);
  final settingsAsync = ref.watch(reminderSettingsProvider);
  final locationAsync = ref.watch(locationProvider);

  final today = todayAsync.value;
  final tomorrow = tomorrowAsync.value;
  final settings = settingsAsync.value;
  final location = locationAsync.value;

  if (today == null || tomorrow == null || settings == null || location == null) {
    return;
  }

  final nowUtc = DateTime.now().toUtc();
  final scheduledItems = ReminderScheduler.buildScheduledList(
    nowUtc: nowUtc,
    todayTimes: today,
    tomorrowTimes: tomorrow,
    settings: settings,
    utcOffsetMinutes: location.utcOffsetMinutes,
  );

  final notificationService = ref.read(localNotificationServiceProvider);
  notificationService.syncScheduledNotifications(scheduledItems);
});