import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/shadcn_widgets.dart';
import '../domain/dhikr_models.dart';
import 'widgets/interactive_tasbih_button.dart';

class DhikrTasbihScreen extends StatefulWidget {
  const DhikrTasbihScreen({super.key});

  @override
  State<DhikrTasbihScreen> createState() => _DhikrTasbihScreenState();
}

class _DhikrTasbihScreenState extends State<DhikrTasbihScreen> {
  int _activeSegment = 0; // 0 = Tasbih Digital, 1 = Doa Harian
  int _selectedDhikrIndex = 0;
  int _counter = 0;
  int _totalCompletedLoops = 0;

  DhikrItem get _currentDhikr => dailyDhikrList[_selectedDhikrIndex];

  Future<void> _vibrateClick() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 45, amplitude: 128);
        return;
      }
    } catch (_) {}

    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> _vibrateComplete() async {
    try {
      final hasCustom = await Vibration.hasCustomVibrationsSupport();
      if (hasCustom == true) {
        await Vibration.vibrate(pattern: [0, 100, 80, 150]);
        return;
      } else {
        await Vibration.vibrate(duration: 250);
        return;
      }
    } catch (_) {}

    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  void _increment() {
    _vibrateClick();
    setState(() {
      _counter++;
      if (_counter >= _currentDhikr.targetCount) {
        _totalCompletedLoops++;
        _counter = 0;
        _vibrateComplete();
      }
    });
  }

  void _reset() {
    setState(() {
      _counter = 0;
      _totalCompletedLoops = 0;
    });
  }

  void _selectDhikr(int index) {
    setState(() {
      _selectedDhikrIndex = index;
      _counter = 0;
      _totalCompletedLoops = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dzikir & Doa'),
        actions: [
          if (_activeSegment == 0)
            IconButton(
              tooltip: 'Reset hitungan',
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () {
                if (_counter > 0 || _totalCompletedLoops > 0) {
                  _reset();
                }
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Segmented Switcher: Tasbih Digital vs Doa Harian
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.surfaceMutedColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Tasbih Digital',
                      icon: Icons.fingerprint_rounded,
                      isSelected: _activeSegment == 0,
                      onTap: () => setState(() => _activeSegment = 0),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _TabButton(
                      label: 'Doa Harian',
                      icon: Icons.auto_stories_rounded,
                      isSelected: _activeSegment == 1,
                      onTap: () => setState(() => _activeSegment = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _activeSegment == 0 ? _buildTasbihView(context) : _buildDailyDuaView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTasbihView(BuildContext context) {
    final dhikr = _currentDhikr;
    final progress = _counter / dhikr.targetCount;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // 1. Selector Pilihan Dzikir
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dailyDhikrList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = dailyDhikrList[index];
              final isSelected = index == _selectedDhikrIndex;
              return InkWell(
                onTap: () => _selectDhikr(index),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : context.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : context.borderColor,
                    ),
                  ),
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : context.textPrimaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // 2. Kartu Teks Bacaan Dzikir
        ShadcnCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    dhikr.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimaryColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  ShadcnBadge(
                    label: 'Target: ${dhikr.targetCount}x',
                    fontSize: 11,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                dhikr.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 28,
                  height: 2.0,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                dhikr.latin,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dhikr.translation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondaryColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // 3. Tombol Tasbih Digital Tactile Spring
        InteractiveTasbihButton(
          counter: _counter,
          targetCount: dhikr.targetCount,
          progress: progress,
          onTap: _increment,
        ),
        const SizedBox(height: 24),
        if (_totalCompletedLoops > 0)
          Center(
            child: ShadcnBadge(
              label:
                  'Selesai $_totalCompletedLoops putaran (${_totalCompletedLoops * dhikr.targetCount} kali)',
              icon: Icons.check_circle_rounded,
              fontSize: 12,
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDailyDuaView(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: dailyDuaList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final dua = dailyDuaList[index];
        return ShadcnCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dua.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimaryColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShadcnBadge(label: dua.category, fontSize: 10),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Salin doa',
                    icon: const Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {
                      final textToCopy =
                          '${dua.title}\n\n${dua.arabic}\n\n"${dua.translation}"\n(${dua.source})';
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${dua.title} berhasil disalin.'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                dua.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  height: 2.1,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                dua.latin,
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dua.translation,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondaryColor,
                  height: 1.4,
                ),
              ),
              if (dua.source.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  dua.source,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkSurface : AppColors.surface)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? (isDark
                    ? AppColors.darkCardShadow
                    : const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ])
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? context.textPrimaryColor : context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}