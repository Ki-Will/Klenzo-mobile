import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum KBadgeVariant { success, warning, danger, info, neutral }

/// Status badge chip used across transaction lists, KYC status, etc.
class KBadge extends StatelessWidget {
  final String label;
  final KBadgeVariant variant;
  final bool dot;

  const KBadge({
    super.key,
    required this.label,
    this.variant = KBadgeVariant.neutral,
    this.dot = false,
  });

  Color get _bg => switch (variant) {
        KBadgeVariant.success => AppColors.successLight,
        KBadgeVariant.warning => AppColors.warningLight,
        KBadgeVariant.danger  => AppColors.dangerLight,
        KBadgeVariant.info    => AppColors.accentLight,
        KBadgeVariant.neutral => AppColors.bgElevated,
      };

  Color get _fg => switch (variant) {
        KBadgeVariant.success => AppColors.success,
        KBadgeVariant.warning => AppColors.warning,
        KBadgeVariant.danger  => AppColors.danger,
        KBadgeVariant.info    => AppColors.accent,
        KBadgeVariant.neutral => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.all(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: _fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: _fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
