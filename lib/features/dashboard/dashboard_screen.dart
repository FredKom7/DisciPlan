import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/screen_time_provider.dart';
import '../../core/themes/app_colors.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/circular_progress.dart';
import '../../core/widgets/streak_indicator.dart';
import '../../core/widgets/custom_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekday = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][now.weekday % 7];
    final month = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][now.month - 1];
    return '$weekday, $month ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    // Handle navigation changes after build completes
    if (_currentNavIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentNavIndex == 1) {
          context.go('/planner');
        } else if (_currentNavIndex == 2) {
          context.go('/habits');
        } else if (_currentNavIndex == 3) {
          context.go('/progress');
        }
        // Reset to dashboard index
        setState(() {
          _currentNavIndex = 0;
        });
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            
            // Stats Grid
            SliverToBoxAdapter(
              child: _buildStatsGrid(context),
            ),
            
            // Active Streaks
            SliverToBoxAdapter(
              child: _buildActiveStreaks(context),
            ),
            
            // Today's Schedule
            SliverToBoxAdapter(
              child: _buildTodaysSchedule(context),
            ),
            
            // Bottom Stats
            SliverToBoxAdapter(
              child: _buildBottomStats(context),
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu icon
          IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          
          // Greeting and date
          Expanded(
            child: Column(
              children: [
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _getFormattedDate(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Profile avatar
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.gradientBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final screenTimeProvider = context.watch<ScreenTimeProvider>();
    
    final activeTasks = todoProvider.todos.where((t) => !t.isCompleted).length;
    final completedToday = todoProvider.todos.where((t) => 
      t.isCompleted && 
      t.createdAt.day == DateTime.now().day
    ).length;
    
    final activeHabits = habitProvider.habits.length;
    final completedHabitsToday = habitProvider.habits.where((h) => 
      h.isCompletedToday()
    ).length;
    
    final todayScreenTime = screenTimeProvider.getTodayTotal();
    final screenTimeHours = (todayScreenTime / 60).toStringAsFixed(1);
    
    // Calculate progress percentage
    final totalTasks = todoProvider.todos.length;
    final progress = totalTasks > 0 
        ? ((todoProvider.todos.where((t) => t.isCompleted).length / totalTasks) * 100).toInt()
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.1,
        children: [
          StatCard(
            icon: Icons.check_circle_outline,
            value: '$activeTasks',
            label: 'Active Tasks',
            subtitle: '$completedToday completed',
            iconColor: AppColors.primary,
            onTap: () => context.push('/tasks'),
          ),
          StatCard(
            icon: Icons.track_changes,
            value: '$activeHabits',
            label: 'Active Habits',
            subtitle: '+$completedHabitsToday this week',
            iconColor: AppColors.warning,
            onTap: () => context.push('/habits'),
          ),
          StatCard(
            icon: Icons.access_time,
            value: '${screenTimeHours}h',
            label: 'Screen Time',
            subtitle: '↓ 1.2h today',
            iconColor: AppColors.success,
            onTap: () => context.push('/screen-time'),
          ),
          StatCard(
            icon: Icons.trending_up,
            value: '$progress%',
            label: 'Progress',
            subtitle: '+12% monthly',
            iconColor: AppColors.purple,
            onTap: () => context.push('/progress'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStreaks(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final habits = habitProvider.habits.take(5).toList();

    if (habits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Streaks',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () => context.push('/habits'),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final completion = habit.isCompletedToday() ? 100.0 : 0.0;
              
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgress(
                      percentage: completion,
                      size: 70,
                      color: AppColors.primary,
                      child: Text(
                        completion == 100 ? '✓' : '',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    StreakIndicator(
                      days: habit.currentStreak,
                      size: 16,
                      showLabel: false,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysSchedule(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final todayTasks = todoProvider.todos.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Schedule',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '${todayTasks.length} tasks',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: todayTasks.length,
          itemBuilder: (context, index) {
            final task = todayTasks[index];
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      todoProvider.toggleTodo(task.id);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted 
                              ? AppColors.success 
                              : AppColors.textTertiary,
                          width: 2,
                        ),
                        color: task.isCompleted 
                            ? AppColors.success 
                            : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            decoration: task.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                            color: task.isCompleted 
                                ? AppColors.textTertiary 
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (task.deadline != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${task.deadline!.hour.toString().padLeft(2, '0')}:${task.deadline!.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomStats(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final habitProvider = context.watch<HabitProvider>();
    
    final tasksCompleted = todoProvider.todos.where((t) => t.isCompleted).length;
    final longestStreak = habitProvider.habits.isNotEmpty
        ? habitProvider.habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b)
        : 0;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomStatItem(
            context,
            value: '$tasksCompleted',
            label: 'Tasks Done',
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
          ),
          _buildBottomStatItem(
            context,
            value: '$longestStreak',
            label: 'Day Streak',
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
          ),
          _buildBottomStatItem(
            context,
            value: '24h',
            label: 'Time Saved',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStatItem(BuildContext context, {
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.gradientBlue,
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'DisciPlan',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Master Your Discipline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/dashboard');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_today,
                    title: 'Planner',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/planner');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.check_circle,
                    title: 'To-Do List',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/tasks');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.track_changes,
                    title: 'Habits',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/habits');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.trending_up,
                    title: 'Progress',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/progress');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.access_time,
                    title: 'Screen Time',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/screen-time');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.block,
                    title: 'Restrictions',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/restrictions');
                    },
                  ),
                  const Divider(height: 32),
                  _buildDrawerItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/notifications');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
    );
  }
}