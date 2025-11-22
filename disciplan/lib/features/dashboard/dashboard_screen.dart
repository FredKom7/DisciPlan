import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import '../../providers/app_data_provider.dart';

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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
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
                _buildDrawerItem(context, Icons.dashboard, 'Dashboard', route: '/dashboard'),
                _buildDrawerItem(context, Icons.calendar_view_week, 'Weekly Planner', route: '/planner'),
                _buildDrawerItem(context, Icons.check_circle_outline, 'To-Do List', route: '/tasks'),
                _buildDrawerItem(context, Icons.repeat, 'Habits', route: '/habits'),
                _buildDrawerItem(context, Icons.screen_rotation, 'Screen Time', route: '/screen-time'),
                _buildDrawerItem(context, Icons.block, 'Restrictions', route: '/restrictions'),
                _buildDrawerItem(context, Icons.trending_up, 'Progress', route: '/progress'),
                const Divider(),
                _buildDrawerItem(context, Icons.settings, 'Settings'),
                _buildDrawerItem(context, Icons.help_outline, 'Help & Support'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, {String? route}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (route != null) {
          context.go(route);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title coming soon!')),
          );
        }
      },
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.rocket_launch, size: 80, color: Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to DisciPlan!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Master your discipline and boost your productivity with a futuristic dashboard.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<AppDataProvider>(
      builder: (context, data, _) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.check_circle,
                title: 'Tasks Done',
                value: '${data.completedTodos}/${data.totalTodos}',
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.repeat,
                title: 'Active Habits',
                value: '${data.activeHabits}',
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.calendar_today,
                title: 'Today\'s Tasks',
                value: '${data.todayTaskCount}',
                color: AppTheme.warningColor,
              ),
            ),
          ],
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
      elevation: 4,
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
        return Card(
          elevation: 4,
          child: InkWell(
            onTap: () => context.go(f['route'] as String),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(f['icon'] as IconData, size: 48, color: AppTheme.primaryColor),
                const SizedBox(height: 12),
                Text(
                  f['label'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

