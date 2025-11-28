import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/planner_provider.dart';
import '../../core/themes/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DisciPlan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _buildDashboardBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'DisciPlan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Master Your Discipline',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: '/dashboard',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_view_week,
                  title: 'Weekly Planner',
                  route: '/planner',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_view_month,
                  title: 'Monthly Planner',
                  route: '/monthly-planner',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.check_circle_outline,
                  title: 'To-Do List',
                  route: '/tasks',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.repeat,
                  title: 'Habits',
                  route: '/habits',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.screen_rotation,
                  title: 'Screen Time',
                  route: '/screen-time',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.block,
                  title: 'Restrictions',
                  route: '/restrictions',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.trending_up,
                  title: 'Progress',
                  route: '/progress',
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon!')),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & Support coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      onTap: onTap ?? () => context.go(route!),
      hoverColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }

  Widget _buildDashboardBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(context),
          const SizedBox(height: 24),
          _buildQuickStats(context),
          const SizedBox(height: 24),
          _buildFeatureCards(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      decoration: AppTheme.glassBox(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(Icons.rocket_launch, size: 80, color: AppTheme.primaryColor),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome to DisciPlan!', style: AppTheme.glassTitle),
                  const SizedBox(height: 8),
                  Text('Master your discipline and boost your productivity with a futuristic dashboard.', style: AppTheme.glassSubtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            return Consumer<PlannerProvider>(
              builder: (context, plannerProvider, child) {
                final todos = todoProvider.todos;
                final habits = habitProvider.habits;
                final tasks = plannerProvider.tasks;

                final completedTodos = todos.where((todo) => todo.isCompleted).length;
                final activeHabits = habits.where((habit) => habit.isActive).length;
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final todayTasks = tasks.where((task) {
                  final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
                  return taskDate.isAtSameMomentAs(today);
                }).length;

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.check_circle,
                        title: 'Tasks Done',
                        value: '$completedTodos/${todos.length}',
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.repeat,
                        title: 'Active Habits',
                        value: '$activeHabits',
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Today\'s Tasks',
                        value: '$todayTasks',
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCards(BuildContext context) {
    final features = [
      {'icon': Icons.calendar_month, 'label': 'Planner', 'route': '/planner'},
      {'icon': Icons.checklist, 'label': 'To-Do', 'route': '/tasks'},
      {'icon': Icons.repeat, 'label': 'Habits', 'route': '/habits'},
      {'icon': Icons.screen_lock_portrait, 'label': 'Screen Time', 'route': '/screen-time'},
      {'icon': Icons.block, 'label': 'Restrictions', 'route': '/restrictions'},
      {'icon': Icons.trending_up, 'label': 'Progress', 'route': '/progress'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: features.length,
      itemBuilder: (context, i) {
        final f = features[i];
        return GestureDetector(
          onTap: () => context.go(f['route'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            decoration: AppTheme.glassBox(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor.withOpacity(0.25), AppTheme.accentColor.withOpacity(0.18)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(f['icon'] as IconData, size: 48, color: AppTheme.primaryColor),
                const SizedBox(height: 12),
                Text(f['label'] as String, style: AppTheme.glassSubtitle.copyWith(fontSize: 20)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMotivationalQuote() {
    final quotes = [
      "The only way to do great work is to love what you do.",
      "Success is not final, failure is not fatal: it is the courage to continue that counts.",
      "Discipline is the bridge between goals and accomplishment.",
      "Small progress is still progress.",
      "Your future self is watching you right now through memories.",
    ];
    return quotes[DateTime.now().millisecondsSinceEpoch % quotes.length];
  }
} 