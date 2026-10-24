import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'shadcn_widgets.dart';

/// Modal dialog kustom bergaya Shadcn: border halus, sudut 20px, tanpa material elevation default.
class ShadcnDialog extends StatelessWidget {
  const ShadcnDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.actions,
    this.actionButtonText = 'Tutup',
    this.onActionPressed,
  });

  final String title;
  final Widget content;
  final IconData? icon;
  final List<Widget>? actions;
  final String actionButtonText;
  final VoidCallback? onActionPressed;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    IconData? icon,
    List<Widget>? actions,
    String actionButtonText = 'Tutup',
    VoidCallback? onActionPressed,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => ShadcnDialog(
        title: title,
        content: content,
        icon: icon,
        actions: actions,
        actionButtonText: actionButtonText,
        onActionPressed: onActionPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor, width: 1.0),
          boxShadow: isDark
              ? AppColors.darkCardShadow
              : const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.primaryContainerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimaryColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 22),
            if (actions != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              )
            else
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onActionPressed ?? () => Navigator.pop(context),
                child: Text(
                  actionButtonText,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}