import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/shadcn_dialog.dart';
import '../../../core/theme/shadcn_widgets.dart';
import '../../prayer_times/presentation/prayer_times_controllers.dart';
import '../domain/qibla_calculator.dart';
import 'qibla_controllers.dart';
import 'widgets/qibla_compass_dial.dart';

class QiblaFinderScreen extends ConsumerStatefulWidget {
  const QiblaFinderScreen({super.key});

  @override
  ConsumerState<QiblaFinderScreen> createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends ConsumerState<QiblaFinderScreen> {
  bool _hasVibrated = false;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);
    final qiblaBearing = ref.watch(qiblaBearingProvider);
    final compassAsync = ref.watch(compassStreamProvider);

    final compassState = compassAsync.value;
    final heading = compassState?.heading ?? 0.0;
    final isSensorAvailable = compassState?.sensorAvailable ?? true;
    final bearing = qiblaBearing ?? 0.0;

    final isAligned = isSensorAvailable &&
        qiblaBearing != null &&
        compassState?.heading != null &&
        QiblaCalculator.isFacingQibla(heading, bearing, threshold: 3.5);

    if (isAligned && !_hasVibrated) {
      _hasVibrated = true;
      HapticFeedback.lightImpact();
    } else if (!isAligned && _hasVibrated) {
      _hasVibrated = false;
    }

    final location = locationAsync.value;
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arah Kiblat'),
        actions: [
          IconButton(
            tooltip: 'Kalibrasi kompas',
            icon: const Icon(Icons.info_outline_rounded, size: 20),
            onPressed: () => _showCalibrationDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // 1. Lokasi & Sudut Bearing Kiblat
          ShadcnCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.primaryContainerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.explore_outlined,
                    color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        location?.label ?? 'Menentukan lokasi...',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimaryColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        qiblaBearing != null
                            ? 'Sudut Kiblat: ${qiblaBearing.toStringAsFixed(1)}° dari Utara'
                            : 'Menghitung sudut...',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (qiblaBearing != null)
                  ShadcnBadge(
                    label: '${qiblaBearing.round()}°',
                    icon: Icons.navigation_rounded,
                    fontSize: 12,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Status Banner
          if (!isSensorAvailable)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF451A03) : AppColors.warningBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sensors_off_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sensor magnetometer tidak terdeteksi. Silakan arahkan ponsel manual ke sudut derajat di atas.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAligned
                    ? (isDark ? AppColors.darkPrimaryContainer : AppColors.successBg)
                    : context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isAligned
                      ? (isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0))
                      : context.borderColor,
                  width: isAligned ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isAligned
                        ? Icons.check_circle_rounded
                        : Icons.screen_rotation_rounded,
                    size: 20,
                    color: isAligned
                        ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.success)
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isAligned
                          ? 'Perangkat sudah tepat menghadap Kiblat!'
                          : 'Putar perangkat hingga panah sejajar ke Ka\'bah',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isAligned ? FontWeight.w700 : FontWeight.w500,
                        color: isAligned
                            ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.onPrimaryContainer)
                            : context.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 28),

          // 3. Dial Kompas
          QiblaCompassDial(
            deviceHeading: heading,
            qiblaBearing: bearing,
            isAligned: isAligned,
          ),
          const SizedBox(height: 32),

          // 4. Kartu Panduan Akurasi Kompas
          ShadcnCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceSubtle,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Petunjuk Penggunaan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pegang ponsel sejajar mendatar (horizontal) dan jauhkan dari benda logam, magnet, atau casing tebal untuk akurasi optimal.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondaryColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showCalibrationDialog(BuildContext context) {
    ShadcnDialog.show<void>(
      context: context,
      icon: Icons.compass_calibration_rounded,
      title: 'Kalibrasi Kompas',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jika arah kompas terasa kurang presisi atau berputar lambat:',
            style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            '1. Pegang ponsel mendatar di udara.\n'
            '2. Gerakkan ponsel membentuk pola angka delapan (∞) sebanyak 3 - 5 kali.\n'
            '3. Hindari area dekat medan magnet seperti laptop, speaker, atau logam tebal.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.textPrimaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}