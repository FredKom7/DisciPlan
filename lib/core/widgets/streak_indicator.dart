import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

/// Streak indicator with fire icon and day count
class StreakIndicator extends StatelessWidget {
  final int days;
  final double size;
  final bool showLabel;

  const StreakIndicator({
    Key? key,
    required this.days,
    this.size = 24,
    this.showLabel = true,
  }) : super(key: key);

  Color get _streakColor {
    if (days >= 30) return AppColors.warning;
    if (days >= 7) return Colors.orange;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fire icon
        Icon(
          Icons.local_fire_department,
          color: _streakColor,
          size: size,
        ),
        const SizedBox(width: 4),
        
        // Day count
        Text(
          '$days ${showLabel ? "days" : ""}',
          style: TextStyle(
            color: _streakColor,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Compact streak badge
class StreakBadge extends StatelessWidget {
  final int days;

  const StreakBadge({Key? key, required this.days}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: StreakIndicator(
        days: days,
        size: 16,
        showLabel: false,
      ),
    );
  }
}
