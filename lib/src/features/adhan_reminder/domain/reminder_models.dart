import 'dart:convert';
import '../../../core/prayer_name.dart';

/// Konfigurasi reminder adhan untuk satu waktu sholat.
class PrayerReminderConfig {
  const PrayerReminderConfig({
    required this.name,
    this.isEnabled = true,
    this.offsetMinutes = 0,
  });

  final PrayerName name;

  /// Apakah notifikasi aktif untuk sholat ini.
  final bool isEnabled;

  /// Menit sebelum waktu sholat (misal 10 = 10 menit sebelum adhan).
  /// 0 = tepat saat waktu adhan masuk.
  final int offsetMinutes;

  PrayerReminderConfig copyWith({
    bool? isEnabled,
    int? offsetMinutes,
  }) {
    return PrayerReminderConfig(
      name: name,
      isEnabled: isEnabled ?? this.isEnabled,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name.name,
        'isEnabled': isEnabled,
        'offsetMinutes': offsetMinutes,
      };

  factory PrayerReminderConfig.fromMap(Map<String, dynamic> map) {
    return PrayerReminderConfig(
      name: PrayerName.values.byName(map['name'] as String),
      isEnabled: map['isEnabled'] as bool? ?? true,
      offsetMinutes: map['offsetMinutes'] as int? ?? 0,
    );
  }
}

/// Daftar pengaturan reminder untuk ke-5 waktu sholat.
class ReminderSettings {
  const ReminderSettings({required this.configs});

  final Map<PrayerName, PrayerReminderConfig> configs;

  /// Pengaturan default: semua sholat aktif tepat waktu (offset 0 menit).
  factory ReminderSettings.defaultSettings() {
    return ReminderSettings(
      configs: {
        for (final name in PrayerName.values)
          name: PrayerReminderConfig(name: name, isEnabled: true, offsetMinutes: 0),
      },
    );
  }

  ReminderSettings update(PrayerName name, {bool? isEnabled, int? offsetMinutes}) {
    final current = configs[name] ?? PrayerReminderConfig(name: name);
    final updated = current.copyWith(
      isEnabled: isEnabled,
      offsetMinutes: offsetMinutes,
    );
    return ReminderSettings(
      configs: {
        ...configs,
        name: updated,
      },
    );
  }

  String toJson() {
    final list = configs.values.map((c) => c.toMap()).toList();
    return jsonEncode(list);
  }

  factory ReminderSettings.fromJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List;
      final map = <PrayerName, PrayerReminderConfig>{};
      for (final item in list) {
        final config = PrayerReminderConfig.fromMap(item as Map<String, dynamic>);
        map[config.name] = config;
      }
      // Pastikan semua 5 waktu sholat ada
      for (final name in PrayerName.values) {
        map.putIfAbsent(name, () => PrayerReminderConfig(name: name));
      }
      return ReminderSettings(configs: map);
    } catch (_) {
      return ReminderSettings.defaultSettings();
    }
  }
}

/// Item jadwal notifikasi terhitung yang siap dikirim ke plugin notifikasi.
class ScheduledPrayerNotification {
  const ScheduledPrayerNotification({
    required this.id,
    required this.prayerName,
    required this.scheduledTime,
    required this.title,
    required this.body,
  });

  /// ID integer unik untuk notification manager (1..5 untuk hari ini, 6..10 untuk besok).
  final int id;
  final PrayerName prayerName;
  final DateTime scheduledTime;
  final String title;
  final String body;
}