import 'package:flutter/material.dart';

import 'app_theme.dart';

extension ThemeContextX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimaryColor =>
      isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

  Color get textSecondaryColor =>
      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

  Color get surfaceColor =>
      isDark ? AppColors.darkSurface : AppColors.surface;

  Color get surfaceMutedColor =>
      isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;

  Color get borderColor =>
      isDark ? AppColors.darkBorder : AppColors.border;

  Color get primaryContainerColor =>
      isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer;

  Color get onPrimaryContainerColor =>
      isDark ? AppColors.darkOnPrimaryContainer : AppColors.onPrimaryContainer;
}

/// Card bergaya Shadcn: border 1px Slate 200 / Zinc 800, radius 16, shadow sangat subtil.
class ShadcnCard extends StatelessWidget {
  const ShadcnCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 16.0,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.surface);
    final border = borderColor ?? (isDark ? AppColors.darkBorder : AppColors.border);

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: borderWidth),
        boxShadow: isDark ? AppColors.darkCardShadow : AppColors.cardShadow,
      ),
      child: child,
    );

    if (onTap == null) return cardContent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      ),
    );
  }
}

/// Badge / Pill kecil bergaya Shadcn untuk status, tag, countdown, atau informasi singkat.
class ShadcnBadge extends StatelessWidget {
  const ShadcnBadge({
    super.key,
    required this.label,
    this.icon,
    this.textColor,
    this.backgroundColor,
    this.fontSize = 11.0,
  });

  final String label;
  final IconData? icon;
  final Color? textColor;
  final Color? backgroundColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer);
    final text = textColor ??
        (isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: text,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}