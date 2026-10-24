import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/prayer_name.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/shadcn_widgets.dart';
import '../../../core/theme/weekly_calendar_strip.dart';
import '../domain/prayer_status.dart';
import 'prayer_tracker_controllers.dart';

class PrayerTrackerScreen extends ConsumerWidget {
  const PrayerTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker Sholat'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: const [
          _TrackerDateNavigator(),
          SizedBox(height: 16),
          _SummaryCard(),
          SizedBox(height: 20),
          _DailyTrackerList(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TrackerDateNavigator extends ConsumerWidget {
  const _TrackerDateNavigator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(trackerDateProvider);
    final summaryAsync = ref.watch(trackerSummaryProvider);

    // Ambil data progres sholat 7 hari untuk ditampilkan langsung di kalender atas
    final summary = summaryAsync.value;
    final countsMap = <DateTime, int>{};
    if (summary != null) {
      for (final p in summary.weeklyProgress) {
        countsMap[DateTime(p.date.year, p.date.month, p.date.day)] = p.doneCount;
      }
    }

    return WeeklyCalendarStrip(
      selectedDate: date,
      completedCountsByDate: countsMap,
      onDateSelected: (newDate) {
        ref.read(trackerDateProvider.notifier).setDate(newDate);
      },
      onPreviousWeek: () {
        ref
            .read(trackerDateProvider.notifier)
            .setDate(date.subtract(const Duration(days: 7)));
      },
      onNextWeek: () {
        ref
            .read(trackerDateProvider.notifier)
            .setDate(date.add(const Duration(days: 7)));
      },
      onGoToday: () {
        ref.read(trackerDateProvider.notifier).goToday();
      },
    );
  }
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(trackerSummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShadcnCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: summary.when(
        loading: () => const SizedBox(
          height: 52,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (e, _) => Text(
          'Gagal memuat: $e',
          style: const TextStyle(fontSize: 13, color: AppColors.danger),
        ),
        data: (s) => Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFEA580C),
                iconBg: isDark
                    ? const Color(0xFF451A03)
                    : const Color(0xFFFFF7ED),
                value: '${s.streak}',
                unit: 'hari',
                label: 'Streak Sholat',
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
            ),
            Expanded(
              child: _StatTile(
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.primary,
                iconBg: isDark
                    ? AppColors.darkPrimaryContainer
                    : AppColors.primaryContainer,
                value: '${s.doneLast7Days}',
                unit: '/35',
                label: '7 Hari Terakhir',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.unit,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
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

class _DailyTrackerList extends ConsumerWidget {
  const _DailyTrackerList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusesAsync = ref.watch(trackerStatusesProvider);

    return statusesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dangerBorder),
        ),
        child: Text(
          'Gagal memuat status: $e',
          style: const TextStyle(color: AppColors.danger),
        ),
      ),
      data: (statuses) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              '5 Waktu Sholat',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: -0.2,
              ),
            ),
          ),
          for (final name in PrayerName.values) ...[
            _PrayerItemCard(
              name: name,
              status: statuses[name],
              onSelect: (s) =>
                  ref.read(trackerStatusesProvider.notifier).set(name, s),
              onClear: () =>
                  ref.read(trackerStatusesProvider.notifier).clear(name),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PrayerItemCard extends StatelessWidget {
  const _PrayerItemCard({
    required this.name,
    required this.status,
    required this.onSelect,
    required this.onClear,
  });

  final PrayerName name;
  final PrayerStatus? status;
  final void Function(PrayerStatus) onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDone = status == PrayerStatus.done;

    final doneBorder = isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0);
    final defaultBorder = isDark ? AppColors.darkBorder : AppColors.border;

    return ShadcnCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderColor: isDone ? doneBorder : defaultBorder,
      borderWidth: isDone ? 1.5 : 1.0,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDone
                  ? (isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer)
                  : (isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _prayerIcon(name),
              size: 20,
              color: isDone
                  ? AppColors.primary
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name.labelId,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? AppColors.primary
                        : theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  _statusSubtitle(status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDone
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _ShadcnSegmentedControl(
            current: status,
            onSelect: onSelect,
            onClear: onClear,
          ),
        ],
      ),
    );
  }

  static IconData _prayerIcon(PrayerName p) => switch (p) {
        PrayerName.fajr => Icons.wb_twilight_rounded,
        PrayerName.dhuhr => Icons.wb_sunny_rounded,
        PrayerName.asr => Icons.wb_cloudy_rounded,
        PrayerName.maghrib => Icons.nights_stay_rounded,
        PrayerName.isha => Icons.bedtime_rounded,
      };

  static String _statusSubtitle(PrayerStatus? s) => switch (s) {
        PrayerStatus.done => 'Terlaksana',
        PrayerStatus.missed => 'Terlewat',
        PrayerStatus.qada => 'Qada',
        null => 'Belum ditandai',
      };
}

class _ShadcnSegmentedControl extends StatelessWidget {
  const _ShadcnSegmentedControl({
    required this.current,
    required this.onSelect,
    required this.onClear,
  });

  final PrayerStatus? current;
  final void Function(PrayerStatus) onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackBg = isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;
    final activeBtnBg = isDark ? AppColors.darkSurface : AppColors.surface;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmentButton(
            label: 'Sudah',
            icon: Icons.check_rounded,
            isSelected: current == PrayerStatus.done,
            activeColor: AppColors.primary,
            activeBg: activeBtnBg,
            onTap: () {
              HapticFeedback.lightImpact();
              if (current == PrayerStatus.done) {
                onClear();
              } else {
                onSelect(PrayerStatus.done);
              }
            },
          ),
          const SizedBox(width: 4),
          _SegmentButton(
            label: 'Lewat',
            icon: Icons.close_rounded,
            isSelected: current == PrayerStatus.missed,
            activeColor: AppColors.danger,
            activeBg: activeBtnBg,
            onTap: () {
              HapticFeedback.selectionClick();
              if (current == PrayerStatus.missed) {
                onClear();
              } else {
                onSelect(PrayerStatus.missed);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.activeBg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final Color activeBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedText = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: isSelected
                ? (isDark ? AppColors.darkCardShadow : const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ])
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? activeColor : AppColors.textMuted,
              ),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? activeColor : unselectedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}