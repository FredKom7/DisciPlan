import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/screen_time_provider.dart';
import '../../data/models/screen_time_entry.dart';
import '../../core/themes/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import 'package:uuid/uuid.dart';

class ScreenTimeScreen extends StatefulWidget {
  const ScreenTimeScreen({Key? key}) : super(key: key);

  @override
  State<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends State<ScreenTimeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScreenTimeProvider>(context, listen: false)
          .loadEntriesForDate(_selectedDate);
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
      ),
      body: Consumer<ScreenTimeProvider>(
        builder: (context, provider, _) {
          final entries = provider.entries;
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

              // Category Summary
              if (entries.isNotEmpty) _buildCategorySummary(provider),

              // Entries List
              Expanded(
                child: entries.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return _buildEntryCard(entry, provider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: GradientFAB(
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  Widget _buildCategorySummary(ScreenTimeProvider provider) {
    final summary = provider.getCategorySummary();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'By Category',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ...summary.entries.map((entry) {
            final hours = entry.value ~/ 60;
            final minutes = entry.value % 60;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(entry.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(entry.key),
                    ],
                  ),
                  Text(
                    '${hours}h ${minutes}m',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEntryCard(ScreenTimeEntry entry, ScreenTimeProvider provider) {
    final hours = entry.durationMinutes ~/ 60;
    final minutes = entry.durationMinutes % 60;

    return Dismissible(
      key: Key(entry.id),
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
      onDismissed: (_) => provider.deleteEntry(entry.id, _selectedDate),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border(
            left: BorderSide(
              color: _getCategoryColor(entry.category),
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
                color: _getCategoryColor(entry.category).withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                _getCategoryIcon(entry.category),
                color: _getCategoryColor(entry.category),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.appName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.category,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              '${hours}h ${minutes}m',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
            'Add your first entry!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'productive':
        return AppColors.success;
      case 'neutral':
        return AppColors.warning;
      case 'distracting':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'productive':
        return Icons.work;
      case 'neutral':
        return Icons.apps;
      case 'distracting':
        return Icons.games;
      default:
        return Icons.phone_android;
    }
  }

  void _showAddDialog(BuildContext context) {
    final appNameController = TextEditingController();
    final durationController = TextEditingController();
    String selectedCategory = 'Productive';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Add Screen Time'),
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
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  hintText: 'e.g., 30',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Productive', 'Neutral', 'Distracting']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
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
              if (appNameController.text.isNotEmpty &&
                  durationController.text.isNotEmpty) {
                final entry = ScreenTimeEntry(
                  id: const Uuid().v4(),
                  appName: appNameController.text,
                  category: selectedCategory,
                  durationMinutes: int.parse(durationController.text),
                  date: _selectedDate,
                );
                context.read<ScreenTimeProvider>().addEntry(entry);
                Navigator.pop(context);
              }
            },
            height: 40,
          ),
        ],
      ),
    );
  }
}