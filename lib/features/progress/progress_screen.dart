import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/screen_time_provider.dart';
import '../../core/themes/app_colors.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/custom_bottom_nav.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _currentNavIndex = 3;

  @override
  Widget build(BuildContext context) {
    // Handle navigation changes after build completes
    if (_currentNavIndex != 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentNavIndex == 0) {
          context.go('/dashboard');
        } else if (_currentNavIndex == 1) {
          context.go('/planner');
        } else if (_currentNavIndex == 2) {
          context.go('/habits');
        }
        // Reset to progress index
        setState(() {
          _currentNavIndex = 3;
        });
      });
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            
            // Monthly Stats
            SliverToBoxAdapter(
              child: _buildMonthlyStats(context),
            ),
            
            // Growth Journey
            SliverToBoxAdapter(
              child: _buildGrowthJourney(context),
            ),
            
            // Achievements
            SliverToBoxAdapter(
              child: _buildAchievements(context),
            ),
            
            // Weekly Trend
            SliverToBoxAdapter(
              child: _buildWeeklyTrend(context),
            ),
            
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
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

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final month = ['January', 'February', 'March', 'April', 'May', 'June', 
                   'July', 'August', 'September', 'October', 'November', 'December'][now.month - 1];
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '$month ${now.year}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final screenTimeProvider = context.watch<ScreenTimeProvider>();
    
    final tasksCompleted = todoProvider.todos.where((t) => t.isCompleted).length;
    final activeHabits = habitProvider.habits.length;
    final screenTimeSaved = (screenTimeProvider.getTodayTotal() / 60).toStringAsFixed(0);
    final longestStreak = habitProvider.habits.isNotEmpty
        ? habitProvider.habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b)
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.0,
        children: [
          _buildStatCard(
            icon: Icons.check_circle,
            value: '$tasksCompleted',
            label: 'Tasks\ncompleted',
            color: AppColors.primary,
          ),
          _buildStatCard(
            icon: Icons.track_changes,
            value: '$activeHabits',
            label: 'Habits\nactive',
            color: AppColors.warning,
          ),
          _buildStatCard(
            icon: Icons.access_time,
            value: '${screenTimeSaved}h',
            label: 'Saved\nscreen time',
            color: AppColors.success,
          ),
          _buildStatCard(
            icon: Icons.local_fire_department,
            value: '$longestStreak',
            label: 'Streak\ndays',
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthJourney(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final totalTasks = todoProvider.todos.length;
    final completedTasks = todoProvider.todos.where((t) => t.isCompleted).length;
    final progress = totalTasks > 0 ? (completedTasks / totalTasks * 100).toInt() : 0;

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
            'Growth Journey',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Plant visualization
          Center(
            child: Column(
              children: [
                Text(
                  _getPlantEmoji(progress),
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _getGrowthStage(progress),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$progress%',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Progress bar with milestones
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientProgress,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Milestone markers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMilestone('0%', '🌱'),
              _buildMilestone('33%', '🌿'),
              _buildMilestone('66%', '🌳'),
              _buildMilestone('100%', '🌲'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestone(String label, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  String _getPlantEmoji(int progress) {
    if (progress >= 100) return '🌲';
    if (progress >= 66) return '🌳';
    if (progress >= 33) return '🌿';
    return '🌱';
  }

  String _getGrowthStage(int progress) {
    if (progress >= 100) return 'Mighty Tree';
    if (progress >= 66) return 'Growing Tree';
    if (progress >= 33) return 'Young Plant';
    return 'Sprout';
  }

  Widget _buildAchievements(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final habitProvider = context.watch<HabitProvider>();
    
    final completedTasks = todoProvider.todos.where((t) => t.isCompleted).length;
    final maxStreak = habitProvider.habits.isNotEmpty
        ? habitProvider.habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b)
        : 0;
    
    // Achievement checks
    final firstTask = todoProvider.todos.any((t) => t.isCompleted);
    final sevenDayStreak = habitProvider.habits.any((h) => h.streak >= 7);
    final thirtyDayStreak = habitProvider.habits.any((h) => h.streak >= 30);
    final hundredTasks = completedTasks >= 100;
    final habitMaster = habitProvider.habits.where((h) => h.streak >= 14).isNotEmpty;
    final disciplineKing = completedTasks >= 50 && maxStreak >= 14;
    
    final unlockedCount = [firstTask, sevenDayStreak, thirtyDayStreak, hundredTasks, habitMaster, disciplineKing]
        .where((achieved) => achieved)
        .length;
    
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🏆 Achievements',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '$unlockedCount/6',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _buildAchievementBadge('🎯', 'First Task', firstTask),
              _buildAchievementBadge('🔥', '7 Day Streak', sevenDayStreak),
              _buildAchievementBadge('💪', '30 Days', thirtyDayStreak),
              _buildAchievementBadge('⭐', '100 Tasks', hundredTasks),
              _buildAchievementBadge('🏅', 'Habit Master', habitMaster),
              _buildAchievementBadge('👑', 'Discipline King', disciplineKing),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String emoji, String label, bool unlocked) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: unlocked 
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: unlocked ? AppColors.primary : AppColors.divider,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 32,
              color: unlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: unlocked ? AppColors.textPrimary : AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrend(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    
    // Calculate daily completion counts for the last 7 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekData = List<int>.filled(7, 0);
    
    for (var todo in todoProvider.todos) {
      if (todo.completedAt != null) {
        final completedDate = DateTime(
          todo.completedAt!.year,
          todo.completedAt!.month,
          todo.completedAt!.day,
        );
        final daysDiff = today.difference(completedDate).inDays;
        if (daysDiff >= 0 && daysDiff < 7) {
          weekData[6 - daysDiff]++;
        }
      }
    }
    
    // Calculate max for scaling
    final maxCount = weekData.reduce((a, b) => a > b ? a : b);
    final hasData = maxCount > 0;
    
    // Calculate improvement (compare this week vs last week if we had that data)
    // For now, just show if there's any activity
    
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
            'Weekly Trend',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Simple bar chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildDayBar('M', weekData[0], maxCount),
              _buildDayBar('T', weekData[1], maxCount),
              _buildDayBar('W', weekData[2], maxCount),
              _buildDayBar('T', weekData[3], maxCount),
              _buildDayBar('F', weekData[4], maxCount),
              _buildDayBar('S', weekData[5], maxCount),
              _buildDayBar('S', weekData[6], maxCount),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          if (hasData)
            Center(
              child: Text(
                'Keep up the great work! 🎉',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Center(
              child: Text(
                'Complete tasks to see your weekly trend',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayBar(String day, int count, int maxCount) {
    // Calculate height based on count (min 20 for visibility, max 135)
    final height = count == 0 ? 20.0 : (count / (maxCount > 0 ? maxCount : 1) * 115 + 20);
    
    return Column(
      children: [
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            gradient: count > 0 ? AppColors.gradientBlue : null,
            color: count == 0 ? AppColors.surfaceLight : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}