import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/restriction_provider.dart';
import '../../data/models/restriction.dart';
import '../../core/themes/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import 'package:uuid/uuid.dart';

class RestrictionsScreen extends StatelessWidget {
  const RestrictionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RestrictionProvider>(
      builder: (context, provider, _) {
        final restrictions = provider.restrictions;
        final activeCount = provider.activeRestrictions.length;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/dashboard'),
            ),
            title: const Text('Restrictions'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
          body: Column(
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
                    _buildStat(context, '${restrictions.length}', 'Total'),
                  ],
                ),
              ),

              // Restrictions List
              Expanded(
                child: restrictions.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        itemCount: restrictions.length,
                        itemBuilder: (context, index) {
                          final restriction = restrictions[index];
                          return _buildRestrictionCard(restriction, provider, context);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: GradientFAB(
            onPressed: () => _showAddDialog(context),
          ),
        );
      },
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

  Widget _buildRestrictionCard(
    Restriction restriction,
    RestrictionProvider provider,
    BuildContext context,
  ) {
    return Dismissible(
      key: Key(restriction.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => provider.deleteRestriction(restriction.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border(
            left: BorderSide(
              color: restriction.isActive ? AppColors.success : AppColors.textTertiary,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: restriction.isActive
                    ? AppColors.success.withOpacity(0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.block,
                color: restriction.isActive ? AppColors.success : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restriction.appName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${restriction.startTime} - ${restriction.endTime}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (restriction.days.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      restriction.days.join(', '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.purple,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: restriction.isActive,
              onChanged: (value) {
                provider.toggleRestriction(restriction.id);
              },
              activeColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block,
            size: 80,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No restrictions set',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add restrictions to block distracting apps!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('About Restrictions'),
        content: const Text(
          'Restrictions help you stay focused by blocking access to specific apps during certain times. '
          'Set up time-based restrictions to improve your productivity!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final appNameController = TextEditingController();
    String startTime = '09:00';
    String endTime = '17:00';
    List<String> selectedDays = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text('Add Restriction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: appNameController,
                  decoration: const InputDecoration(
                    labelText: 'App Name',
                    hintText: 'e.g., Instagram',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: startTime,
                        decoration: const InputDecoration(labelText: 'Start Time'),
                        onChanged: (value) => startTime = value,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        initialValue: endTime,
                        decoration: const InputDecoration(labelText: 'End Time'),
                        onChanged: (value) => endTime = value,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Active Days:'),
                Wrap(
                  spacing: 8,
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((day) => FilterChip(
                            label: Text(day),
                            selected: selectedDays.contains(day),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedDays.add(day);
                                } else {
                                  selectedDays.remove(day);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            GradientButton(
              text: 'Add',
              onPressed: () {
                if (appNameController.text.isNotEmpty) {
                  final restriction = Restriction(
                    id: const Uuid().v4(),
                    appName: appNameController.text,
                    startTime: startTime,
                    endTime: endTime,
                    days: selectedDays,
                    isActive: true,
                  );
                  context.read<RestrictionProvider>().addRestriction(restriction);
                  Navigator.pop(context);
                }
              },
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}