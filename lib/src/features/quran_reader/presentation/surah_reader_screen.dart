import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/shadcn_widgets.dart';
import '../domain/quran_models.dart';
import 'quran_reader_controllers.dart';

class SurahReaderScreen extends ConsumerStatefulWidget {
  const SurahReaderScreen({
    super.key,
    required this.surahNumber,
    this.initialAyah,
  });

  final int surahNumber;
  final int? initialAyah;

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener = ItemPositionsListener.create();

  late int _surah;
  int? _jumpTarget;
  DateTime? _lastSave;

  @override
  void initState() {
    super.initState();
    _surah = widget.surahNumber;
    final ayah = widget.initialAyah ?? 1;
    if (ayah > 1) _jumpTarget = ayah;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(readingPositionProvider.notifier).save(_surah, ayah);
      }
    });
    _positionsListener.itemPositions.addListener(_onPositionsChanged);
  }

  @override
  void dispose() {
    _positionsListener.itemPositions.removeListener(_onPositionsChanged);
    super.dispose();
  }

  void _onPositionsChanged() {
    final positions = _positionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final rawIndex = positions.first.index;
    final ayah = rawIndex == 0 ? 1 : rawIndex;
    _maybeSaveProgress(ayah);
  }

  void _maybeSaveProgress(int ayah) {
    final now = DateTime.now();
    if (_lastSave == null ||
        now.difference(_lastSave!) >= const Duration(seconds: 1)) {
      _lastSave = now;
      ref.read(readingPositionProvider.notifier).save(_surah, ayah);
    }
  }

  void _scheduleJump(int ayahCount) {
    final target = _jumpTarget;
    if (target == null) return;
    _jumpTarget = null;
    final index = target.clamp(1, ayahCount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.isAttached) return;
      _scrollController.jumpTo(index: index);
    });
  }

  void _goToSurah(int number) {
    if (number < 1 || number > 114) return;
    setState(() {
      _surah = number;
      _jumpTarget = 1;
    });
    ref.read(readingPositionProvider.notifier).save(number, 1);
  }

  Future<void> _showJumpSheet(int ayahCount) async {
    final controller = TextEditingController();
    final value = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
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
            Text(
              'Lompat ke Ayat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.textPrimaryColor,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: context.textPrimaryColor),
              decoration: InputDecoration(
                hintText: 'Pilih nomor 1 - $ayahCount',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onSubmitted: (v) => Navigator.of(ctx).pop(int.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () =>
                  Navigator.of(ctx).pop(int.tryParse(controller.text) ?? 0),
              child: const Text('Buka Ayat', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (value == null || value < 1 || value > ayahCount) return;
    _scrollController.jumpTo(index: value);
    ref.read(readingPositionProvider.notifier).save(_surah, value);
  }

  void _showFontSizeSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final currentSize = ref.watch(quranArabicFontSizeProvider);

          return Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                    Text(
                      'Ukuran Huruf Arab',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimaryColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    ShadcnBadge(
                      label: '${currentSize.round()} pt',
                      fontSize: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.surfaceMutedColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: currentSize,
                      color: context.textPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'A',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Slider(
                        value: currentSize,
                        min: 20.0,
                        max: 38.0,
                        divisions: 9,
                        activeColor: AppColors.primary,
                        inactiveColor: context.borderColor,
                        onChanged: (val) {
                          ref
                              .read(quranArabicFontSizeProvider.notifier)
                              .setFontSize(val);
                        },
                      ),
                    ),
                    const Text(
                      'A',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surahAsync = ref.watch(surahProvider(_surah));
    final bookmarks = ref.watch(bookmarksProvider);
    final arabicFontSize = ref.watch(quranArabicFontSizeProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: surahAsync.maybeWhen(
          data: (s) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  s.latin,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ShadcnBadge(
                label: '${s.ayahs.length}',
                fontSize: 10,
              ),
            ],
          ),
          orElse: () => const Text('Memuat…'),
        ),
        actions: [
          IconButton(
            tooltip: 'Ukuran huruf',
            icon: const Icon(Icons.format_size_rounded, size: 20),
            onPressed: _showFontSizeSheet,
          ),
          if (_surah > 1)
            IconButton(
              tooltip: 'Surah sebelumnya',
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              onPressed: () => _goToSurah(_surah - 1),
            ),
          if (_surah < 114)
            IconButton(
              tooltip: 'Surah berikutnya',
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onPressed: () => _goToSurah(_surah + 1),
            ),
          IconButton(
            tooltip: 'Lompat ke ayat',
            icon: const Icon(Icons.format_list_numbered_rounded, size: 20),
            onPressed: () async {
              final data = surahAsync.value;
              if (data != null) await _showJumpSheet(data.ayahs.length);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: surahAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat surah: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ),
        data: (surah) {
          _scheduleJump(surah.ayahs.length);
          final totalCount = surah.ayahs.length + 1;

          return ScrollablePositionedList.separated(
            itemCount: totalCount,
            itemScrollController: _scrollController,
            itemPositionsListener: _positionsListener,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _SurahHeaderBanner(surah: surah);
              }
              final ayah = surah.ayahs[index - 1];
              return _AyahCard(
                ayah: ayah,
                fontSize: arabicFontSize,
                isBookmarked: (bookmarks.value ?? const <(int, int)>{}).contains(
                  (_surah, ayah.number),
                ),
                onToggleBookmark: () => ref
                    .read(bookmarksProvider.notifier)
                    .toggle(_surah, ayah.number),
              );
            },
          );
        },
      ),
    );
  }
}

class _SurahHeaderBanner extends StatelessWidget {
  const _SurahHeaderBanner({required this.surah});

  final SurahWithAyahs surah;

  @override
  Widget build(BuildContext context) {
    final showBasmalah = surah.number != 1 && surah.number != 9;
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: context.primaryContainerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x0A059669),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            surah.name,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            surah.latin,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textPrimaryColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${surah.placeId} · ${surah.ayahs.length} Ayat',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.textSecondaryColor,
            ),
          ),
          if (showBasmalah) ...[
            const SizedBox(height: 18),
            Divider(color: isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0)),
            const SizedBox(height: 14),
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.ayah,
    required this.fontSize,
    required this.isBookmarked,
    required this.onToggleBookmark,
  });

  final Ayah ayah;
  final double fontSize;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    Color cardBorder;
    Color cardBg;

    if (isBookmarked) {
      cardBorder = isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A);
      cardBg = isDark ? const Color(0xFF261D11) : const Color(0xFFFFFBEB);
    } else {
      cardBorder = context.borderColor;
      cardBg = context.surfaceColor;
    }

    return ShadcnCard(
      padding: const EdgeInsets.all(16),
      borderColor: cardBorder,
      backgroundColor: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: isBookmarked
                      ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
                      : context.surfaceMutedColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ayat ${ayah.number}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isBookmarked
                        ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309))
                        : context.textSecondaryColor,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Salin ayat',
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  final textToCopy =
                      '${ayah.arabic}\n\n"${ayah.translation}"\n(QS. Ayat ${ayah.number})';
                  Clipboard.setData(ClipboardData(text: textToCopy));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ayat ${ayah.number} berhasil disalin.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: isBookmarked ? 'Hapus bookmark' : 'Tandai bookmark',
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  size: 20,
                  color: isBookmarked ? const Color(0xFFD97706) : AppColors.textMuted,
                ),
                onPressed: onToggleBookmark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: ayah.arabic),
                const TextSpan(text: ' '),
                TextSpan(
                  text: ' ۝${_toArabicDigits(ayah.number)} ',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: fontSize,
              height: 2.2,
              fontWeight: FontWeight.w500,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            ayah.translation,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  static String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final s = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final code = s.codeUnitAt(i) - 48; // '0' is ASCII 48
      if (code >= 0 && code <= 9) {
        buffer.write(arabicDigits[code]);
      } else {
        buffer.write(s[i]);
      }
    }
    return buffer.toString();
  }
}