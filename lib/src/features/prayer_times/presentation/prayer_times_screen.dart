import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calendar/hijri_calendar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/shadcn_widgets.dart';
import '../../adhan_reminder/presentation/reminder_controllers.dart';
import '../../adhan_reminder/presentation/reminder_settings_sheet.dart';
import '../domain/daily_prayer_times.dart';
import '../domain/geo_location.dart';
import '../domain/prayer_settings.dart';
import 'prayer_times_controllers.dart';
import 'widgets/modern_settings_sheet.dart';
import 'widgets/next_prayer_hero_card.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Ticker 1 detik agar countdown jam, menit, detik di bawah 1 jam berjalan real-time
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(notificationSyncProvider);

    final locationState = ref.watch(locationProvider);
    final settingsState = ref.watch(prayerSettingsProvider);
    final timesAsync = ref.watch(dailyPrayerTimesProvider);
    final tomorrowAsync = ref.watch(tomorrowPrayerTimesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat'),
        actions: [
          IconButton(
            tooltip: 'Gunakan lokasi GPS',
            icon: const Icon(Icons.my_location, size: 20),
            onPressed: () => ref.read(locationProvider.notifier).useGps(),
          ),
          IconButton(
            tooltip: 'Pengingat Adhan',
            icon: const Icon(Icons.notifications_outlined, size: 20),
            onPressed: () => ReminderSettingsSheet.show(context),
          ),
          IconButton(
            tooltip: 'Pengaturan Jadwal',
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () => _openSettings(settingsState.value),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(locationProvider);
          ref.invalidate(prayerSettingsProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            _LocationBar(state: locationState),
            const SizedBox(height: 12),
            _DateNavigator(),
            const SizedBox(height: 16),
            if (locationState.hasError) _LocationError(state: locationState),
            if (settingsState.hasError)
              const _InlineError(message: 'Gagal memuat pengaturan.'),
            _NextPrayerCard(
              now: _now,
              timesAsync: timesAsync,
              tomorrowAsync: tomorrowAsync,
            ),
            const SizedBox(height: 14),
            // Baris Info Imsak, Terbit/Syuruq, dan Dhuha
            _SunInfoCards(
              timesAsync: timesAsync,
              location: locationState.value,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                'Waktu Sholat Hari Ini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textSecondaryColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            _PrayerList(
              timesAsync: timesAsync,
              nowUtc: _now.toUtc(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _openSettings(PrayerSettings? settings) async {
    if (settings == null) return;
    final next = await showModalBottomSheet<PrayerSettings>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ModernSettingsSheet(current: settings),
    );
    if (next != null) {
      await ref.read(prayerSettingsProvider.notifier).save(next);
    }
  }
}

class _LocationBar extends ConsumerWidget {
  const _LocationBar({required this.state});

  final AsyncValue<GeoLocation> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(locationRepositoryProvider).cities;
    final location = state.value;

    return ShadcnCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => _pickCity(context, ref, cities),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 20,
              color: context.isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  location?.label ?? 'Memuat lokasi…',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  location != null
                      ? '${location.latitude.toStringAsFixed(3)}, ${location.longitude.toStringAsFixed(3)}'
                      : 'Menghubungkan GPS...',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.unfold_more_rounded,
            size: 20,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Future<void> _pickCity(
    BuildContext context,
    WidgetRef ref,
    List<GeoLocation> cities,
  ) async {
    final selected = await showModalBottomSheet<GeoLocation>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Pilih Kota / Wilayah',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimaryColor,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: context.borderColor),
            Expanded(
              child: ListView.separated(
                itemCount: cities.length,
                separatorBuilder: (context, index) => Divider(indent: 20, color: context.borderColor),
                itemBuilder: (context, i) {
                  final city = cities[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(
                      city.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => Navigator.pop(context, city),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await ref.read(locationProvider.notifier).selectCity(selected);
    }
  }
}

class _DateNavigator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    return ShadcnCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Hari sebelumnya',
            icon: const Icon(Icons.chevron_left, size: 22),
            visualDensity: VisualDensity.compact,
            color: context.textSecondaryColor,
            onPressed: () => ref.read(selectedDateProvider.notifier).previous(),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isToday
                  ? null
                  : () => ref.read(selectedDateProvider.notifier).goToday(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDateId(date),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      HijriCalendar.formatHijri(date),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    if (isToday)
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: ShadcnBadge(
                          label: 'Hari Ini',
                          fontSize: 10,
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          'Kembali ke hari ini',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Hari berikutnya',
            icon: const Icon(Icons.chevron_right, size: 22),
            visualDensity: VisualDensity.compact,
            color: context.textSecondaryColor,
            onPressed: () => ref.read(selectedDateProvider.notifier).next(),
          ),
        ],
      ),
    );
  }
}

class _NextPrayerCard extends ConsumerWidget {
  const _NextPrayerCard({
    required this.now,
    required this.timesAsync,
    required this.tomorrowAsync,
  });

  final DateTime now;
  final AsyncValue<DailyPrayerTimes> timesAsync;
  final AsyncValue<DailyPrayerTimes> tomorrowAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = timesAsync.value;
    final tomorrow = tomorrowAsync.value;
    final location = ref.watch(locationProvider).value;

    if (today == null || tomorrow == null || location == null) {
      return const ShadcnCard(
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 14),
            Text('Menghitung sholat berikutnya…'),
          ],
        ),
      );
    }

    final next = nextPrayerAt(now.toUtc(), today, tomorrow);
    final countdown = next.countdownFrom(now.toUtc());
    final timeLabel = formatHhMm(next.time, location.utcOffsetMinutes);

    return NextPrayerHeroCard(
      prayerName: next.name,
      timeLabel: timeLabel,
      countdownStr: _formatCountdown(countdown),
    );
  }
}

class _SunInfoCards extends StatelessWidget {
  const _SunInfoCards({
    required this.timesAsync,
    required this.location,
  });

  final AsyncValue<DailyPrayerTimes> timesAsync;
  final GeoLocation? location;

  @override
  Widget build(BuildContext context) {
    final times = timesAsync.value;
    final offset = location?.utcOffsetMinutes ?? 0;

    if (times == null) return const SizedBox.shrink();

    final imsakStr = formatHhMm(times.imsak, offset);
    final syuruqStr = formatHhMm(times.sunrise, offset);
    final dhuhaStr = formatHhMm(times.dhuha, offset);

    return Row(
      children: [
        Expanded(
          child: _SunInfoTile(
            label: 'Imsak',
            time: imsakStr,
            icon: Icons.nightlight_round,
            iconColor: const Color(0xFF6366F1), // Indigo 500
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SunInfoTile(
            label: 'Terbit',
            time: syuruqStr,
            icon: Icons.wb_twilight_rounded,
            iconColor: const Color(0xFFF59E0B), // Amber 500
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SunInfoTile(
            label: 'Dhuha',
            time: dhuhaStr,
            icon: Icons.wb_sunny_rounded,
            iconColor: const Color(0xFF10B981), // Emerald 500
          ),
        ),
      ],
    );
  }
}

class _SunInfoTile extends StatelessWidget {
  const _SunInfoTile({
    required this.label,
    required this.time,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String time;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ShadcnCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textPrimaryColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerList extends ConsumerWidget {
  const _PrayerList({required this.timesAsync, required this.nowUtc});

  final AsyncValue<DailyPrayerTimes> timesAsync;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider).value;

    return timesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => _InlineError(message: 'Gagal menghitung jadwal: $e'),
      data: (times) {
        final offset = location?.utcOffsetMinutes ?? 0;
        final upcoming = _upcomingPrayer(times, nowUtc);

        return ShadcnCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                for (int i = 0; i < times.ordered.length; i++) ...[
                  if (i > 0) Divider(height: 1, indent: 60, color: context.borderColor),
                  _PrayerRow(
                    name: times.ordered[i].$1,
                    time: times.ordered[i].$2,
                    offset: offset,
                    isUpcoming: upcoming == times.ordered[i].$1,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.name,
    required this.time,
    required this.offset,
    required this.isUpcoming,
  });

  final PrayerName name;
  final DateTime time;
  final int offset;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final highlightBg = isDark
        ? AppColors.darkPrimaryContainer.withValues(alpha: 0.5)
        : AppColors.primaryContainer.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: isUpcoming ? highlightBg : Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isUpcoming
                  ? (isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer)
                  : context.surfaceMutedColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _prayerIcon(name),
              size: 18,
              color: isUpcoming
                  ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary)
                  : context.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name.labelId,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isUpcoming ? FontWeight.w700 : FontWeight.w500,
                color: isUpcoming ? AppColors.primary : context.textPrimaryColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Text(
            formatHhMm(time, offset),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isUpcoming ? AppColors.primary : context.textPrimaryColor,
              letterSpacing: -0.3,
            ),
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
}

class _LocationError extends StatelessWidget {
  const _LocationError({required this.state});

  final AsyncValue<GeoLocation> state;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dangerBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 20, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.error?.toString() ?? 'Gagal memuat lokasi.',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Gunakan GPS dengan izin aktif, atau pilih kota manual.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF991B1B),
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

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dangerBorder),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: AppColors.danger),
      ),
    );
  }
}

PrayerName? _upcomingPrayer(DailyPrayerTimes times, DateTime nowUtc) {
  for (final (name, time) in times.ordered) {
    if (time.isAfter(nowUtc)) return name;
  }
  return null;
}

String _formatCountdown(Duration d) {
  if (d.isNegative) return 'segera';
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;

  // Jika di bawah 1 jam, tampilkan hitungan detik real-time agar interaktif
  if (h == 0) {
    if (m > 0) {
      final mm = m.toString().padLeft(2, '0');
      final ss = s.toString().padLeft(2, '0');
      return '$mm menit $ss dtk';
    }
    return '$s detik';
  }

  return '$h jam $m mnt';
}

const _monthNamesId = [
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

const _weekdayNamesId = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

String _formatDateId(DateTime date) {
  final weekday = _weekdayNamesId[date.weekday - 1];
  return '$weekday, ${date.day} ${_monthNamesId[date.month - 1]} ${date.year}';
}