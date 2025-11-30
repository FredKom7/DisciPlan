import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/habit_provider.dart';
import '../../data/models/habit.dart';
import '../../core/themes/app_colors.dart';
import '../../core/widgets/streak_indicator.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/custom_bottom_nav.dart';
import 'package:uuid/uuid.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  int _currentNavIndex = 2;

  @override
  Widget build(BuildContext context) {
    // Handle navigation changes after build completes
    if (_currentNavIndex != 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentNavIndex == 0) {
          context.go('/dashboard');
        } else if (_currentNavIndex == 1) {
          context.go('/planner');
        } else if (_currentNavIndex == 3) {
          context.go('/progress');
        }
        // Reset to habits index
        setState(() {
          _currentNavIndex = 2;
        });
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Consumer<HabitProvider>(
          builder: (context, provider, _) {
            final habits = provider.habits;
            final completedToday = habits.where((h) => h.isCompletedToday()).length;
            final totalHabits = habits.length;
            final todayProgress = totalHabits > 0 
                ? ((completedToday / totalHabits) * 100).toInt()
                : 0;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context, provider),
                ),
                
                SliverToBoxAdapter(
                  child: _buildTodayProgress(context, todayProgress, habits),
                ),
                
                if (habits.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: Text(
                        'Daily Habits',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final habit = habits[index];
                        return _buildHabitItem(context, habit, provider);
                      },
                      childCount: habits.length,
                    ),
                  ),
                ],
                
                SliverToBoxAdapter(
                  child: _buildWeeklyStats(context, habits),
                ),
                
                if (habits.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context),
                  ),
                
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: GradientFAB(
        onPressed: () => _showAddDialog(context),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HabitProvider provider) {
    final longestStreak = provider.habits.isNotEmpty
        ? provider.habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b)
        : 0;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Habits',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${provider.habits.where((h) => h.isCompletedToday()).length} of ${provider.habits.length} completed',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          if (longestStreak > 0)
            StreakIndicator(days: longestStreak),
        ],
      ),
    );
  }

  Widget _buildTodayProgress(BuildContext context, int progress, List<Habit> habits) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Progress',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                '$progress%',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32,
                ),
              ),
              const Spacer(),
              if (habits.isNotEmpty)
                StreakIndicator(
                  days: habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitItem(BuildContext context, Habit habit, HabitProvider provider) {
    final isCompleted = habit.isCompletedToday();
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text(
                _getHabitEmoji(habit.name),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                StreakBadge(days: habit.currentStreak),
              ],
            ),
          ),
          
          GestureDetector(
            onTap: () {
              if (!isCompleted) {
                provider.markCompleted(habit);
              }
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isCompleted ? AppColors.gradientGreen : null,
                border: !isCompleted
                    ? Border.all(color: AppColors.textTertiary, width: 2)
                    : null,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle_outlined,
                color: isCompleted ? Colors.white : AppColors.textTertiary,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats(BuildContext context, List<Habit> habits) {
    if (habits.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Overview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final day = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];
              final isToday = DateTime.now().weekday == index + 1;
              
              return Column(
                children: [
                  Text(
                    day,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isToday ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday 
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.surfaceLight,
                    ),
                    child: Center(
                      child: Text(
                        '${habits.length}',
                        style: TextStyle(
                          color: isToday ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
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
            Icons.track_changes,
            size: 80,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start building better habits today!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getHabitEmoji(String habitName) {
    final name = habitName.toLowerCase();
    if (name.contains('water') || name.contains('drink')) return '💧';
    if (name.contains('exercise') || name.contains('workout')) return '💪';
    if (name.contains('read')) return '📚';
    if (name.contains('meditate') || name.contains('meditation')) return '🧘';
    if (name.contains('sleep')) return '😴';
    if (name.contains('code') || name.contains('program')) return '💻';
    if (name.contains('write') || name.contains('journal')) return '✍️';
    if (name.contains('walk')) return '🚶';
    return '⭐';
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Add Habit'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Habit Name',
            hintText: 'e.g., Drink 8 glasses of water',
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
              if (nameController.text.isNotEmpty) {
                final habit = Habit(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  createdAt: DateTime.now(),
                  streak: 0,
                );
                context.read<HabitProvider>().addHabit(habit);
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