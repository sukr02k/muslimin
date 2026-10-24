import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/prayer_name.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/shadcn_widgets.dart';
import '../domain/reminder_models.dart';
import 'reminder_controllers.dart';

class ReminderSettingsSheet extends ConsumerWidget {
  const ReminderSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ReminderSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(reminderSettingsProvider);
    final notificationService = ref.watch(localNotificationServiceProvider);
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pengingat Adhan Otomatis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimaryColor,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Atur alarm suara adhan dan waktu pengingat sebelum sholat.',
                style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
              ),
              const SizedBox(height: 16),

              // Banner Uji Coba Kumandang Adhan yang Jelas & Menarik
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uji Suara Kumandang Adhan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Putar sampel adhan merdu yang tersimpan offline.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFFA7F3D0) : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF059669) : AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        await notificationService.requestPermission();
                        await notificationService.showTestNotification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Memutar kumandang adhan di bilah notifikasi...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 16),
                          SizedBox(width: 4),
                          Text('Putar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Daftar Waktu Sholat & Segmented Offset Langsung
              settingsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (e, _) => Text(
                  'Gagal memuat pengaturan: $e',
                  style: const TextStyle(color: AppColors.danger),
                ),
                data: (settings) {
                  return Column(
                    children: [
                      for (final name in PrayerName.values) ...[
                        _PrayerReminderTile(
                          config: settings.configs[name] ??
                              PrayerReminderConfig(name: name),
                          onToggle: (enabled) {
                            ref
                                .read(reminderSettingsProvider.notifier)
                                .updateConfig(name, isEnabled: enabled);
                          },
                          onOffsetChanged: (offset) {
                            ref
                                .read(reminderSettingsProvider.notifier)
                                .updateConfig(name, offsetMinutes: offset);
                          },
                        ),
                        if (name != PrayerName.isha)
                          Divider(height: 1, color: context.borderColor),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Petunjuk optimasi daya baterai perangkat (Bahasa General)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceMutedColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.battery_charging_full_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Agar pengingat selalu berbunyi tepat waktu saat layar ponsel terkunci, pastikan izin aktivitas latar belakang dan optimasi baterai untuk aplikasi ini diatur ke "Tidak Dibatasi" pada pengaturan perangkat Anda.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Selesai',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerReminderTile extends StatelessWidget {
  const _PrayerReminderTile({
    required this.config,
    required this.onToggle,
    required this.onOffsetChanged,
  });

  final PrayerReminderConfig config;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onOffsetChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: config.isEnabled
                      ? context.primaryContainerColor
                      : context.surfaceMutedColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.isEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_outlined,
                  size: 18,
                  color: config.isEnabled
                      ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary)
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  config.name.labelId,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Switch(
                value: config.isEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: onToggle,
              ),
            ],
          ),
          if (config.isEnabled) ...[
            const SizedBox(height: 8),
            // Segmented Chips horizontal cepat: 0m, 5m, 10m, 15m, 30m
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 44),
                  _offsetChip(context, 0, 'Tepat Waktu'),
                  const SizedBox(width: 6),
                  _offsetChip(context, 5, '5 mnt sblm'),
                  const SizedBox(width: 6),
                  _offsetChip(context, 10, '10 mnt sblm'),
                  const SizedBox(width: 6),
                  _offsetChip(context, 15, '15 mnt sblm'),
                  const SizedBox(width: 6),
                  _offsetChip(context, 30, '30 mnt sblm'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _offsetChip(BuildContext context, int minutes, String label) {
    final isSelected = config.offsetMinutes == minutes;
    final isDark = context.isDark;

    final bg = isSelected
        ? (isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer)
        : context.surfaceMutedColor;

    final border = isSelected
        ? AppColors.primary
        : context.borderColor;

    final textColor = isSelected
        ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary)
        : context.textSecondaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onOffsetChanged(minutes),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}