import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Styled card container matching the web's --c-card aesthetic.
class KCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool hasBorder;
  final Color? color;

  const KCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.hasBorder = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.bgCard,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: hasBorder
            ? Border.all(color: AppColors.border, width: 1)
            : null,
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

/// Gradient card for featured/balance sections.
class KGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const KGradientCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.all(AppRadius.xl),
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}
