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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengingat Adhan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimaryColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Atur alarm adhan dan waktu pengingat sholat.',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.primaryContainerColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.volume_up_rounded,
                            size: 14,
                            color: context.isDark
                                ? AppColors.darkOnPrimaryContainer
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Uji Suara',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.isDark
                                  ? AppColors.darkOnPrimaryContainer
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: context.borderColor),

              // Area Scrollable untuk daftar sholat & petunjuk daya
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                                'Agar pengingat selalu berbunyi tepat waktu saat layar terkunci, pastikan izin aktivitas latar belakang dan optimasi baterai untuk aplikasi ini diatur ke "Tidak Dibatasi" pada pengaturan perangkat.',
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
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
                  size: 16,
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
                    fontSize: 14,
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
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 36),
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
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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