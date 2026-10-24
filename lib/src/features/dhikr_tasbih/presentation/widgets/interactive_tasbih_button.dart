import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shadcn_widgets.dart';

class InteractiveTasbihButton extends StatefulWidget {
  const InteractiveTasbihButton({
    super.key,
    required this.counter,
    required this.targetCount,
    required this.progress,
    required this.onTap,
  });

  final int counter;
  final int targetCount;
  final double progress;
  final VoidCallback onTap;

  @override
  State<InteractiveTasbihButton> createState() => _InteractiveTasbihButtonState();
}

class _InteractiveTasbihButtonState extends State<InteractiveTasbihButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(
        parent: _springController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _springController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _springController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _springController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Center(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Ripple / Aura Ring halus di belakang
              Container(
                width: 228,
                height: 228,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0x0A059669)
                      : const Color(0x0A059669),
                ),
              ),

              // 2. Progress Ring Melingkar
              SizedBox(
                width: 216,
                height: 216,
                child: CircularProgressIndicator(
                  value: widget.progress,
                  strokeWidth: 9,
                  backgroundColor: isDark
                      ? AppColors.darkSurfaceMuted
                      : context.surfaceMutedColor,
                  color: AppColors.primary,
                  strokeCap: StrokeCap.round,
                ),
              ),

              // 3. Tombol Utama Lingkaran Tactile
              Container(
                width: 184,
                height: 184,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.surfaceColor,
                  border: Border.all(
                    color: context.borderColor,
                    width: 1.5,
                  ),
                  boxShadow: isDark
                      ? AppColors.darkCardShadow
                      : const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.counter}',
                      style: TextStyle(
                        fontSize: 58,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimaryColor,
                        letterSpacing: -2.5,
                      ),
                    ),
                    Text(
                      '/ ${widget.targetCount}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryContainerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'KETUK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: isDark
                              ? AppColors.darkOnPrimaryContainer
                              : AppColors.primary,
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
    );
  }
}