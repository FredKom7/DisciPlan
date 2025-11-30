import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

/// Reusable stat card widget matching reference design
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Value
            Text(
              value,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            
            // Label
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            // Subtitle (optional)
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtitle!.contains('+') 
                      ? AppColors.success 
                      : subtitle!.contains('-')
                          ? AppColors.error
                          : AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
