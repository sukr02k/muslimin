import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shadcn_widgets.dart';

class QiblaCompassDial extends StatelessWidget {
  const QiblaCompassDial({
    super.key,
    required this.deviceHeading,
    required this.qiblaBearing,
    required this.isAligned,
  });

  final double deviceHeading;
  final double qiblaBearing;
  final bool isAligned;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final compassRotation = -deviceHeading * (math.pi / 180.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 320.0);

        final dialBg = isDark ? AppColors.darkSurface : AppColors.surface;
        final dialBorder = isDark ? AppColors.darkBorder : AppColors.border;

        final centerCircleBg = isAligned
            ? (isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer)
            : (isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted);

        final centerCircleBorder = isAligned
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.border);

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Piringan luar & border glowing saat sejajar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dialBg,
                    border: Border.all(
                      color: isAligned ? const Color(0xFF10B981) : dialBorder,
                      width: isAligned ? 3.0 : 1.5,
                    ),
                    boxShadow: isAligned
                        ? [
                            const BoxShadow(
                              color: Color(0x3310B981),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ]
                        : (isDark ? AppColors.darkCardShadow : AppColors.cardShadow),
                  ),
                ),

                // 2. Dial kompas (N, E, S, W dan ticks)
                Transform.rotate(
                  angle: compassRotation,
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: _CompassTicksPainter(isDark: isDark),
                  ),
                ),

                // 3. Lingkaran pusat kompas
                Container(
                  width: size * 0.45,
                  height: size * 0.45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: centerCircleBg,
                    border: Border.all(
                      color: centerCircleBorder,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAligned ? Icons.check_circle_rounded : Icons.explore_rounded,
                          size: 28,
                          color: isAligned
                              ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary)
                              : context.textSecondaryColor,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${deviceHeading.round()}°',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          isAligned ? 'Tepat Kiblat' : 'Arah Device',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isAligned
                                ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary)
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Jarum penunjuk Kiblat (Ka'bah pointer)
                Transform.rotate(
                  angle: compassRotation + (qiblaBearing * (math.pi / 180.0)),
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 14,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isAligned
                                      ? const Color(0xFF059669)
                                      : (isDark ? const Color(0xFF27272A) : const Color(0xFF0F172A)),
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x20000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.navigation_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isAligned
                                      ? (isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer)
                                      : (isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isAligned
                                        ? AppColors.primary
                                        : (isDark ? AppColors.darkBorder : AppColors.border),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "Ka'bah",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: isAligned
                                        ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary)
                                        : context.textPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompassTicksPainter extends CustomPainter {
  const _CompassTicksPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = isDark ? const Color(0xFF3F3F46) : const Color(0xFFCBD5E1)
      ..strokeWidth = 1.0;

    final majorTickPaint = Paint()
      ..color = isDark ? const Color(0xFF71717A) : const Color(0xFF64748B)
      ..strokeWidth = 2.0;

    for (int i = 0; i < 360; i += 10) {
      final isMajor = i % 30 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;
      final rad = i * (math.pi / 180.0);

      final startX = center.dx + (radius - 10) * math.sin(rad);
      final startY = center.dy - (radius - 10) * math.cos(rad);

      final endX = center.dx + (radius - 10 - tickLength) * math.sin(rad);
      final endY = center.dy - (radius - 10 - tickLength) * math.cos(rad);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        isMajor ? majorTickPaint : tickPaint,
      );
    }

    final mutedCardinalColor = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B);

    _drawCardinalText(canvas, center, radius - 34, 'U', const Color(0xFFDC2626), 0);
    _drawCardinalText(canvas, center, radius - 34, 'T', mutedCardinalColor, 90);
    _drawCardinalText(canvas, center, radius - 34, 'S', mutedCardinalColor, 180);
    _drawCardinalText(canvas, center, radius - 34, 'B', mutedCardinalColor, 270);
  }

  void _drawCardinalText(
    Canvas canvas,
    Offset center,
    double radius,
    String text,
    Color color,
    double degree,
  ) {
    final rad = degree * (math.pi / 180.0);
    final x = center.dx + radius * math.sin(rad);
    final y = center.dy - radius * math.cos(rad);

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassTicksPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}