import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shadcn_dialog.dart';
import '../../../../core/theme/shadcn_widgets.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../domain/prayer_settings.dart';

class ModernSettingsSheet extends StatefulWidget {
  const ModernSettingsSheet({super.key, required this.current});

  final PrayerSettings current;

  @override
  State<ModernSettingsSheet> createState() => _ModernSettingsSheetState();
}

class _ModernSettingsSheetState extends State<ModernSettingsSheet> {
  late PrayerMethod _method = widget.current.method;
  late PrayerMadhab _madhab = widget.current.madhab;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = context.surfaceColor;
    final textTitleColor = context.textPrimaryColor;
    final borderColor = context.borderColor;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
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
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textTitleColor,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: borderColor),

              // Area Scrollable Fleksibel
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. TEMA TAMPILAN (3 Horizontal Grid Cards)
                      const Text(
                        'TEMA TAMPILAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, _) {
                          final themeMode = ref.watch(appThemeModeProvider);
                          return Row(
                            children: [
                              Expanded(
                                child: _ThemeModeCard(
                                  label: 'Sistem',
                                  icon: Icons.brightness_auto_rounded,
                                  isSelected: themeMode == ThemeMode.system,
                                  onTap: () => ref
                                      .read(appThemeModeProvider.notifier)
                                      .setThemeMode(ThemeMode.system),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ThemeModeCard(
                                  label: 'Terang',
                                  icon: Icons.light_mode_rounded,
                                  isSelected: themeMode == ThemeMode.light,
                                  onTap: () => ref
                                      .read(appThemeModeProvider.notifier)
                                      .setThemeMode(ThemeMode.light),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ThemeModeCard(
                                  label: 'OLED Gelap',
                                  icon: Icons.dark_mode_rounded,
                                  isSelected: themeMode == ThemeMode.dark,
                                  onTap: () => ref
                                      .read(appThemeModeProvider.notifier)
                                      .setThemeMode(ThemeMode.dark),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // 2. MAZHAB WAKTU ASHAR (2 Segmented Pills)
                      const Text(
                        'MAZHAB (WAKTU ASHAR)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _MadhabOptionCard(
                              title: 'Syafi\'i / Maliki / Hanbali',
                              badge: 'Standar Indonesia',
                              desc: 'Bayangan 1x — Waktu ashar masuk lebih awal',
                              isSelected: _madhab == PrayerMadhab.shafi,
                              onTap: () => setState(() => _madhab = PrayerMadhab.shafi),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MadhabOptionCard(
                              title: 'Hanafi',
                              badge: 'Asia Selatan / Turki',
                              desc: 'Bayangan 2x — Waktu ashar mundur ~45 menit',
                              isSelected: _madhab == PrayerMadhab.hanafi,
                              onTap: () => setState(() => _madhab = PrayerMadhab.hanafi),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 3. METODE KALKULASI SUBTITLED LIST
                      const Text(
                        'METODE KALKULASI ASTRONOMI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            _MethodOptionTile(
                              title: 'Kemenag RI',
                              subtitle: 'Standar Kementerian Agama RI (Subuh 20°, Isya 18°)',
                              isRecommended: true,
                              isSelected: _method == PrayerMethod.kemenag,
                              onTap: () => setState(() => _method = PrayerMethod.kemenag),
                            ),
                            Divider(height: 1, color: borderColor),
                            _MethodOptionTile(
                              title: 'Muslim World League (MWL)',
                              subtitle: 'Standar internasional Eropa, Amerika, & global (18°/17°)',
                              isSelected: _method == PrayerMethod.muslimWorldLeague,
                              onTap: () => setState(() => _method = PrayerMethod.muslimWorldLeague),
                            ),
                            Divider(height: 1, color: borderColor),
                            _MethodOptionTile(
                              title: 'Otoritas Mesir (Egyptian)',
                              subtitle: 'Otoritas Umum Survei Mesir & Afrika Utara (19.5°/17.5°)',
                              isSelected: _method == PrayerMethod.egyptian,
                              onTap: () => setState(() => _method = PrayerMethod.egyptian),
                            ),
                            Divider(height: 1, color: borderColor),
                            _MethodOptionTile(
                              title: 'Umm al-Qura (Makkah)',
                              subtitle: 'Standar Arab Saudi (Isya 90 menit setelah Maghrib)',
                              isSelected: _method == PrayerMethod.ummAlQura,
                              onTap: () => setState(() => _method = PrayerMethod.ummAlQura),
                            ),
                            Divider(height: 1, color: borderColor),
                            _MethodOptionTile(
                              title: 'Karachi (Pakistan)',
                              subtitle: 'Universitas Ilmu Islam Karachi (18°/18°)',
                              isSelected: _method == PrayerMethod.karachi,
                              onTap: () => setState(() => _method = PrayerMethod.karachi),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Tombol Info & Tentang Aplikasi
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showAboutDialog(context),
                          icon: const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMuted),
                          label: const Text(
                            'Tentang Muslimin v1.0.0',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
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
                onPressed: () => Navigator.pop(
                  context,
                  PrayerSettings(method: _method, madhab: _madhab),
                ),
                child: const Text(
                  'Simpan Pengaturan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    ShadcnDialog.show<void>(
      context: context,
      icon: Icons.mosque_rounded,
      title: 'Muslimin',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Versi 1.0.0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aplikasi pengingat jadwal sholat, arah kiblat, Al-Qur\'an, dan tasbih digital yang mengutamakan privasi pengguna.',
            style: TextStyle(fontSize: 13, color: context.textSecondaryColor, height: 1.4),
          ),
          const SizedBox(height: 14),
          Text(
            '• Bebas iklan dan dapat digunakan tanpa koneksi internet.\n'
            '• Data lokasi dan riwayat ibadah tersimpan di perangkat Anda.\n'
            '• Perhitungan jadwal sholat berdasar kriteria Kementerian Agama RI & Adhan Library.\n'
            '• Teks Al-Qur\'an Uthmani & Terjemahan resmi Kementerian Agama RI.',
            style: TextStyle(
              fontSize: 12,
              color: context.textPrimaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isSelected
        ? (isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer)
        : context.surfaceMutedColor;

    final border = isSelected
        ? AppColors.primary
        : context.borderColor;

    final textColor = isSelected
        ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary)
        : context.textPrimaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: textColor),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MadhabOptionCard extends StatelessWidget {
  const _MadhabOptionCard({
    required this.title,
    required this.badge,
    required this.desc,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String badge;
  final String desc;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isSelected
        ? (isDark ? AppColors.darkPrimaryContainer.withValues(alpha: 0.6) : AppColors.primaryContainer)
        : context.surfaceMutedColor;

    final border = isSelected ? AppColors.primary : context.borderColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary)
                            : context.textPrimaryColor,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 4),
              ShadcnBadge(label: badge, fontSize: 9),
              const SizedBox(height: 6),
              Text(
                desc,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodOptionTile extends StatelessWidget {
  const _MethodOptionTile({
    required this.title,
    required this.subtitle,
    this.isRecommended = false,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isRecommended;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: onTap,
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : context.textPrimaryColor,
            ),
          ),
          if (isRecommended) ...[
            const SizedBox(width: 8),
            const ShadcnBadge(label: 'Indonesia', fontSize: 10),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
          : null,
    );
  }
}