import 'package:flutter/material.dart';

import '../../../../core/prayer_name.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shadcn_widgets.dart';

class TimeAtmosphereTheme {
  const TimeAtmosphereTheme({
    required this.gradient,
    required this.borderColor,
    required this.iconColor,
    required this.iconBg,
    required this.iconData,
    required this.greeting,
  });

  final LinearGradient gradient;
  final Color borderColor;
  final Color iconColor;
  final Color iconBg;
  final IconData iconData;
  final String greeting;

  static TimeAtmosphereTheme resolve({
    required PrayerName nextPrayer,
    required bool isDark,
  }) {
    switch (nextPrayer) {
      case PrayerName.fajr:
        // Suasana Fajar / Subuh (Deep Indigo ke Soft Teal)
        return TimeAtmosphereTheme(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF064E3B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFF0FDF4), Color(0xFFEFF6FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderColor: isDark ? const Color(0xFF065F46) : const Color(0xFFBAE6FD),
          iconColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
          iconBg: isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE),
          iconData: Icons.wb_twilight_rounded,
          greeting: 'Fajar yang Tenang',
        );

      case PrayerName.dhuhr:
      case PrayerName.asr:
        // Suasana Siang / Hari Cerah (Emerald Vibrant)
        return TimeAtmosphereTheme(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF141E18), Color(0xFF064E3B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderColor: isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0),
          iconColor: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF059669),
          iconBg: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
          iconData: nextPrayer == PrayerName.dhuhr
              ? Icons.wb_sunny_rounded
              : Icons.wb_cloudy_rounded,
          greeting: nextPrayer == PrayerName.dhuhr ? 'Siang yang Berkah' : 'Sore yang Sejuk',
        );

      case PrayerName.maghrib:
        // Suasana Senja / Maghrib (Sunset Warm Amber & Dusk)
        return TimeAtmosphereTheme(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF2E1065), Color(0xFF451A03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFFFBEB), Color(0xFFFAF5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderColor: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
          iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
          iconBg: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
          iconData: Icons.nights_stay_rounded,
          greeting: 'Senja yang Khusyuk',
        );

      case PrayerName.isha:
        // Suasana Malam / Isya (OLED Night & Emerald Glow)
        return TimeAtmosphereTheme(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF18181B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
          iconColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
          iconBg: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
          iconData: Icons.bedtime_rounded,
          greeting: 'Malam yang Teduh',
        );
    }
  }
}

class NextPrayerHeroCard extends StatelessWidget {
  const NextPrayerHeroCard({
    super.key,
    required this.prayerName,
    required this.timeLabel,
    required this.countdownStr,
  });

  final PrayerName prayerName;
  final String timeLabel;
  final String countdownStr;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final atmosphere = TimeAtmosphereTheme.resolve(
      nextPrayer: prayerName,
      isDark: isDark,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: atmosphere.gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: atmosphere.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x0A059669),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ornamen motif geometris islami halus di latar
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(
              Icons.stars_rounded,
              size: 110,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : AppColors.primary.withValues(alpha: 0.05),
            ),
          ),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: atmosphere.iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  atmosphere.iconData,
                  color: atmosphere.iconColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Menjelang ${prayerName.labelId}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimaryColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const Spacer(),
                        ShadcnBadge(
                          label: timeLabel,
                          icon: Icons.access_time_rounded,
                          fontSize: 11,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sisa waktu: $countdownStr',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}