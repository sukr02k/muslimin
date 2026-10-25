import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_models.dart';

class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  // Channel ID v4 dengan registrasi eksplisit AudioAttributes USAGE_ALARM
  static const _channelId = 'prayer_adhan_voice_channel_v4';
  static const _channelName = 'Pengingat Adhan Suara';
  static const _channelDescription = 'Notifikasi suara adhan merdu saat masuk waktu sholat fardhu.';

  /// Inisialisasi plugin notifikasi, timezone, dan daftarkan NotificationChannel secara eksplisit ke OS Android.
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: initSettings);

    // Daftarkan channel secara eksplisit dengan AudioAttributesUsage.alarm
    // agar suara adhan diperlakukan sebagai ALARM sistem (selalu berbunyi nyaring & tembus lockscreen)
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      const soundSource = RawResourceAndroidNotificationSound('adhan');
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        sound: soundSource,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );
      await androidImpl.createNotificationChannel(channel);
    }

    _initialized = true;
  }

  /// Minta izin notifikasi (Android 13+).
  Future<bool> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return false;

    final granted = await androidImpl.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Cek apakah izin notifikasi sudah diberikan.
  Future<bool> areNotificationsEnabled() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return false;

    final enabled = await androidImpl.areNotificationsEnabled();
    return enabled ?? false;
  }

  /// Batalkan semua jadwal pengingat sholat yang ada.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Jadwalkan daftar notifikasi baru secara offline dengan nada suara adhan.
  Future<void> syncScheduledNotifications(
    List<ScheduledPrayerNotification> items,
  ) async {
    await cancelAll();

    if (items.isEmpty) return;

    const soundSource = RawResourceAndroidNotificationSound('adhan');

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      sound: soundSource,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    for (final item in items) {
      final scheduledTz = tz.TZDateTime.from(item.scheduledTime, tz.local);

      try {
        await _plugin.zonedSchedule(
          id: item.id,
          title: item.title,
          body: item.body,
          scheduledDate: scheduledTz,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (_) {
        try {
          await _plugin.zonedSchedule(
            id: item.id,
            title: item.title,
            body: item.body,
            scheduledDate: scheduledTz,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        } catch (_) {}
      }
    }
  }

  /// Tampilkan notifikasi test instan dengan suara adhan merdu.
  Future<void> showTestNotification() async {
    const soundSource = RawResourceAndroidNotificationSound('adhan');

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      sound: soundSource,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 999,
      title: 'Uji Coba Suara Adhan',
      body: 'Allahu Akbar, Allahu Akbar — Waktu sholat telah masuk.',
      notificationDetails: notificationDetails,
    );
  }
}