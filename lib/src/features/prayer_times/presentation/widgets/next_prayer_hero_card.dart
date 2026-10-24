import 'package:flutter/material.dart';

import '../../../../core/prayer_name.dart';
import '../../../../core/theme/shadcn_widgets.dart';

class TimeAtmosphereTheme {
  const TimeAtmosphereTheme({
    required this.gradient,
    required this.borderColor,
    required this.iconColor,
    required this.iconBg,
    required this.iconData,
  });

  final LinearGradient gradient;
  final Color borderColor;
  final Color iconColor;
  final Color iconBg;
  final IconData iconData;

  static TimeAtmosphereTheme resolve({
    required PrayerName nextPrayer,
    required bool isDark,
  }) {
    switch (nextPrayer) {
      case PrayerName.fajr:
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
        );

      case PrayerName.dhuhr:
      case PrayerName.asr:
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
        );

      case PrayerName.maghrib:
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
        );

      case PrayerName.isha:
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: atmosphere.gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: atmosphere.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x0A059669),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: atmosphere.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              atmosphere.iconData,
              color: atmosphere.iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimaryColor,
                        letterSpacing: -0.3,
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
                const SizedBox(height: 2),
                Text(
                  'Sisa waktu: $countdownStr',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}