import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_models.dart';

class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  // Mengganti channelId ke v3 agar Android membuat ulang AudioAttributes dengan audio adhan.ogg
  static const _channelId = 'prayer_adhan_voice_channel_v3';
  static const _channelName = 'Pengingat Adhan Suara';
  static const _channelDescription = 'Notifikasi suara adhan merdu saat masuk waktu sholat fardhu.';

  /// Inisialisasi plugin notifikasi & data timezone perangkat.
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: initSettings);
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

    // Nada audio suara adhan dari android/app/src/main/res/raw/adhan.ogg
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