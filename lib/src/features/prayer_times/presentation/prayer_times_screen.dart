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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          children: [
            // 1. Header Terpadu Ringkas: Lokasi & Tanggal + Kalender Picker (Hemat Ruang Vertikal)
            _UnifiedLocationDateBar(locationState: locationState),
            const SizedBox(height: 10),

            if (locationState.hasError) _LocationError(state: locationState),
            if (settingsState.hasError)
              const _InlineError(message: 'Gagal memuat pengaturan.'),

            // 2. Kartu Hero Menjelang Sholat Ramping
            _NextPrayerCard(
              now: _now,
              timesAsync: timesAsync,
              tomorrowAsync: tomorrowAsync,
            ),
            const SizedBox(height: 10),

            // 3. Mini Bar Imsak, Terbit, Dhuha Ramping
            _SunInfoCards(
              timesAsync: timesAsync,
              location: locationState.value,
            ),
            const SizedBox(height: 14),

            // 4. Tabel 5 Waktu Sholat Utama (Tampil Utuh Tanpa Terpotong)
            _PrayerList(
              timesAsync: timesAsync,
              nowUtc: _now.toUtc(),
            ),
            const SizedBox(height: 16),
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

/// Header terpadu yang menyatukan pemilih lokasi & kalender tanggal dalam 1 baris elegan
class _UnifiedLocationDateBar extends ConsumerWidget {
  const _UnifiedLocationDateBar({required this.locationState});

  final AsyncValue<GeoLocation> locationState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = locationState.value;
    final date = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    final cities = ref.watch(locationRepositoryProvider).cities;
    final isDark = context.isDark;

    return ShadcnCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => _pickCity(context, ref, cities),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          location?.label ?? 'Memuat lokasi…',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimaryColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              if (!isToday) ...[
                InkWell(
                  onTap: () => ref.read(selectedDateProvider.notifier).goToday(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.primaryContainerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Hari Ini',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Pilih Tanggal',
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                color: context.textSecondaryColor,
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    ref.read(selectedDateProvider.notifier).setDate(picked);
                  }
                },
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Hari Sebelumnya',
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                color: context.textSecondaryColor,
                onPressed: () => ref.read(selectedDateProvider.notifier).previous(),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Hari Berikutnya',
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                color: context.textSecondaryColor,
                onPressed: () => ref.read(selectedDateProvider.notifier).next(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                _formatFullDate(date),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: context.textSecondaryColor,
                ),
              ),
              const Spacer(),
              Text(
                HijriCalendar.formatHijri(date),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
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

  static const _weekdayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static String _formatFullDate(DateTime d) {
    return '${_weekdayNames[d.weekday - 1]}, ${d.day} ${_monthNames[d.month - 1]} ${d.year}';
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
            iconColor: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SunInfoTile(
            label: 'Terbit',
            time: syuruqStr,
            icon: Icons.wb_twilight_rounded,
            iconColor: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SunInfoTile(
            label: 'Dhuha',
            time: dhuhaStr,
            icon: Icons.wb_sunny_rounded,
            iconColor: const Color(0xFF10B981),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: context.textSecondaryColor,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimaryColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
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
                  if (i > 0) Divider(height: 1, indent: 56, color: context.borderColor),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: isUpcoming ? highlightBg : Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isUpcoming
                  ? (isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer)
                  : context.surfaceMutedColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _prayerIcon(name),
              size: 17,
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
                fontSize: 14,
                fontWeight: isUpcoming ? FontWeight.w700 : FontWeight.w500,
                color: isUpcoming ? AppColors.primary : context.textPrimaryColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Text(
            formatHhMm(time, offset),
            style: TextStyle(
              fontSize: 15,
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