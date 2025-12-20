import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../providers/screen_time_provider.dart';
import '../../data/models/app_restriction.dart';
import '../../core/themes/app_colors.dart';
import '../../services/usage_stats_service.dart';
import 'package:uuid/uuid.dart';

class RestrictionsScreen extends StatefulWidget {
  const RestrictionsScreen({Key? key}) : super(key: key);

  @override
  State<RestrictionsScreen> createState() => _RestrictionsScreenState();
}

class _RestrictionsScreenState extends State<RestrictionsScreen> {
  List<Map<String, dynamic>> _installedApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppsWithUsage();
  }

  Future<void> _loadAppsWithUsage() async {
    setState(() => _isLoading = true);
    
    final provider = Provider.of<ScreenTimeProvider>(context, listen: false);
    await provider.loadTodayUsageStats();
    
    final usageStatsService = UsageStatsService();
    final apps = await usageStatsService.getInstalledApps();
    
    // Merge installed apps with usage stats
    final appsWithUsage = apps.map((app) {
      int usageMinutes = 0;
      final matchingStats = provider.appUsageStats.where(
        (stat) => stat.packageName == app['packageName']
      );
      if (matchingStats.isNotEmpty) {
        usageMinutes = matchingStats.first.usageTimeMinutes;
      }
      
      return {
        ...app,
        'usageTimeMinutes': usageMinutes,
      };
    }).toList();
    
    // Sort by usage (descending)
    appsWithUsage.sort((a, b) => 
      (b['usageTimeMinutes'] as int).compareTo(a['usageTimeMinutes'] as int)
    );
    
    setState(() {
      _installedApps = appsWithUsage;
      _isLoading = false;
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
        title: const Text('Restrictions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppsWithUsage,
          ),
        ],
      ),
      body: Consumer<ScreenTimeProvider>(
        builder: (context, provider, _) {
          if (!provider.hasPermission) {
            return _buildPermissionRequest(context, provider);
          }

          final activeCount = provider.restrictions.where((r) => r.isActive).length;

          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPurple,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(context, '$activeCount', 'Active'),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white30,
                    ),
                    _buildStat(context, '${provider.restrictions.length}', 'Total'),
                  ],
                ),
              ),

              // Apps List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _installedApps.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            itemCount: _installedApps.length,
                            itemBuilder: (context, index) {
                              final app = _installedApps[index];
                              return _buildAppCard(app, provider, context);
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
              'DisciPlan needs access to usage stats to show app usage and manage restrictions.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () async {
                await provider.requestPermission();
                if (provider.hasPermission) {
                  _loadAppsWithUsage();
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

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }

  Widget _buildAppCard(
    Map<String, dynamic> app,
    ScreenTimeProvider provider,
    BuildContext context,
  ) {
    final packageName = app['packageName'] as String;
    final appName = app['appName'] as String;
    final usageMinutes = app['usageTimeMinutes'] as int;
    final appIcon = app['appIcon'] as String?;
    
    final restriction = provider.getRestrictionForPackage(packageName);
    final hasRestriction = restriction != null;
    final isLimitExceeded = provider.isLimitExceeded(packageName);

    final hours = usageMinutes ~/ 60;
    final minutes = usageMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: hasRestriction
            ? Border.all(
                color: isLimitExceeded ? AppColors.error : AppColors.success,
                width: 2,
              )
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // App Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: appIcon != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Image.memory(
                          base64Decode(appIcon),
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
                      appName,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usageMinutes > 0
                          ? 'Used: ${hours > 0 ? "${hours}h " : ""}${minutes}m today'
                          : 'Not used today',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (hasRestriction) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isLimitExceeded ? Icons.warning : Icons.check_circle,
                            size: 14,
                            color: isLimitExceeded ? AppColors.error : AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Limit: ${restriction.limitText}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isLimitExceeded ? AppColors.error : AppColors.success,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Set Restriction Button
              if (!hasRestriction)
                OutlinedButton(
                  onPressed: () => _showSetLimitDialog(context, packageName, appName, provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: const Text('Set Limit'),
                )
              else
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () => _showEditLimitDialog(context, restriction, provider),
                ),
            ],
          ),
          if (hasRestriction) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => provider.deleteRestriction(packageName),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
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
            Icons.apps,
            size: 80,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No apps found',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Grant permission to see installed apps',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showSetLimitDialog(
    BuildContext context,
    String packageName,
    String appName,
    ScreenTimeProvider provider,
  ) {
    int hours = 1;
    int minutes = 0;
    List<int> selectedDays = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text('Set Limit for $appName'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Time Limit:'),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: hours,
                        decoration: const InputDecoration(labelText: 'Hours'),
                        items: List.generate(24, (i) => i)
                            .map((h) => DropdownMenuItem(value: h, child: Text('$h')))
                            .toList(),
                        onChanged: (value) => setState(() => hours = value!),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: minutes,
                        decoration: const InputDecoration(labelText: 'Minutes'),
                        items: [0, 15, 30, 45]
                            .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
                            .toList(),
                        onChanged: (value) => setState(() => minutes = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Restrict on specific days (optional):'),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  children: [
                    for (int i = 1; i <= 7; i++)
                      FilterChip(
                        label: Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i - 1]),
                        selected: selectedDays.contains(i),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDays.add(i);
                            } else {
                              selectedDays.remove(i);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final totalMinutes = (hours * 60) + minutes;
                if (totalMinutes > 0) {
                  final restriction = AppRestriction(
                    id: const Uuid().v4(),
                    packageName: packageName,
                    appName: appName,
                    dailyLimitMinutes: totalMinutes,
                    restrictedDays: selectedDays,
                    createdAt: DateTime.now(),
                  );
                  provider.addRestriction(restriction);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Set Limit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLimitDialog(
    BuildContext context,
    AppRestriction restriction,
    ScreenTimeProvider provider,
  ) {
    int hours = restriction.dailyLimitMinutes ~/ 60;
    int minutes = restriction.dailyLimitMinutes % 60;
    List<int> selectedDays = List.from(restriction.restrictedDays);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text('Edit Limit for ${restriction.appName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Time Limit:'),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: hours,
                        decoration: const InputDecoration(labelText: 'Hours'),
                        items: List.generate(24, (i) => i)
                            .map((h) => DropdownMenuItem(value: h, child: Text('$h')))
                            .toList(),
                        onChanged: (value) => setState(() => hours = value!),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: minutes,
                        decoration: const InputDecoration(labelText: 'Minutes'),
                        items: [0, 15, 30, 45]
                            .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
                            .toList(),
                        onChanged: (value) => setState(() => minutes = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Restrict on specific days (optional):'),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  children: [
                    for (int i = 1; i <= 7; i++)
                      FilterChip(
                        label: Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i - 1]),
                        selected: selectedDays.contains(i),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDays.add(i);
                            } else {
                              selectedDays.remove(i);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final totalMinutes = (hours * 60) + minutes;
                if (totalMinutes > 0) {
                  final updated = restriction.copyWith(
                    dailyLimitMinutes: totalMinutes,
                    restrictedDays: selectedDays,
                  );
                  provider.updateRestriction(updated);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
