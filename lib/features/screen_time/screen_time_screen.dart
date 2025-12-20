import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../providers/screen_time_provider.dart';
import '../../core/themes/app_colors.dart';

class ScreenTimeScreen extends StatefulWidget {
  const ScreenTimeScreen({Key? key}) : super(key: key);

  @override
  State<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends State<ScreenTimeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ScreenTimeProvider>(context, listen: false);
      provider.loadTodayUsageStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Screen Time'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ScreenTimeProvider>(context, listen: false)
                  .loadTodayUsageStats();
            },
          ),
        ],
      ),
      body: Consumer<ScreenTimeProvider>(
        builder: (context, provider, _) {
          if (!provider.hasPermission) {
            return _buildPermissionRequest(context, provider);
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalMinutes = provider.getTodayTotal();
          final hours = totalMinutes ~/ 60;
          final minutes = totalMinutes % 60;

          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientBlue,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Today\'s Screen Time',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${hours}h ${minutes}m',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 48,
                          ),
                    ),
                  ],
                ),
              ),

              // App Usage List
              Expanded(
                child: provider.appUsageStats.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: provider.appUsageStats.length,
                        itemBuilder: (context, index) {
                          final stat = provider.appUsageStats[index];
                          return _buildAppUsageCard(stat, provider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionRequest(
      BuildContext context, ScreenTimeProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Permission Required',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'DisciPlan needs access to usage stats to show your screen time.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () async {
                await provider.requestPermission();
                if (provider.hasPermission) {
                  provider.loadTodayUsageStats();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppUsageCard(
      dynamic stat, ScreenTimeProvider provider) {
    final hours = stat.usageTimeMinutes ~/ 60;
    final minutes = stat.usageTimeMinutes % 60;
    final hasRestriction = provider.hasRestriction(stat.packageName);
    final isLimitExceeded = provider.isLimitExceeded(stat.packageName);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: isLimitExceeded
            ? Border.all(color: AppColors.error, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // App Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: stat.appIcon != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.memory(
                      base64Decode(stat.appIcon),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.apps, color: AppColors.primary);
                      },
                    ),
                  )
                : const Icon(Icons.apps, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          
          // App Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.appName,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (hasRestriction) ...[
                  Row(
                    children: [
                      Icon(
                        isLimitExceeded ? Icons.warning : Icons.timer,
                        size: 14,
                        color: isLimitExceeded
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.getRestrictionForPackage(stat.packageName)!.limitText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isLimitExceeded
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Usage Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLimitExceeded ? AppColors.error : null,
                    ),
              ),
              if (hasRestriction) ...[
                const SizedBox(height: 4),
                Text(
                  isLimitExceeded ? 'Limit exceeded' : 'Within limit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isLimitExceeded
                            ? AppColors.error
                            : AppColors.success,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            size: 80,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No screen time recorded',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Use your phone and check back later!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}