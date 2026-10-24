import 'package:flutter/material.dart';

import '../calendar/hijri_calendar.dart';
import 'app_theme.dart';
import 'shadcn_widgets.dart';

class WeeklyCalendarStrip extends StatelessWidget {
  const WeeklyCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onGoToday,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onGoToday;

  static const _weekdayAbbr = ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isViewingToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    final isDark = context.isDark;

    // Hitung hari Senin pada minggu dari selectedDate
    // weekday di Dart: 1 = Senin, 7 = Minggu
    final monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    return ShadcnCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        children: [
          // Header Bar: Bulan Masehi & Hijriah + Navigasi Minggu & Badge Hari Ini
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatMonthYear(selectedDate),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimaryColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      HijriCalendar.formatHijri(selectedDate),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isViewingToday) ...[
                InkWell(
                  onTap: onGoToday,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.primaryContainerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Hari Ini',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Minggu sebelumnya',
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                color: context.textSecondaryColor,
                onPressed: onPreviousWeek,
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Minggu berikutnya',
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                color: context.textSecondaryColor,
                onPressed: onNextWeek,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: context.borderColor),
          const SizedBox(height: 12),

          // Deretan 7 Pill Hari (Senin - Minggu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final date in weekDays)
                _DayPill(
                  date: date,
                  isSelected: date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day,
                  isToday: date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day,
                  weekdayLabel: _weekdayAbbr[date.weekday - 1],
                  onTap: () => onDateSelected(date),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static const _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String _formatMonthYear(DateTime d) {
    return '${_monthNames[d.month - 1]} ${d.year}';
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.weekdayLabel,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final String weekdayLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    Color pillBg;
    Color borderColor;
    Color dayTextColor;
    Color numTextColor;

    if (isSelected) {
      pillBg = AppColors.primary;
      borderColor = AppColors.primary;
      dayTextColor = Colors.white.withValues(alpha: 0.85);
      numTextColor = Colors.white;
    } else if (isToday) {
      pillBg = isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer;
      borderColor = isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0);
      dayTextColor = isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary;
      numTextColor = isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary;
    } else {
      pillBg = isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceSubtle;
      borderColor = context.borderColor;
      dayTextColor = context.textSecondaryColor;
      numTextColor = context.textPrimaryColor;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isToday && !isSelected ? 1.5 : 1.0),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x25059669),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weekdayLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: dayTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: numTextColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}