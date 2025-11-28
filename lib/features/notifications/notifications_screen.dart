import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/habit_provider.dart';
import '../../providers/todo_provider.dart';
import '../../providers/planner_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDark ? Colors.grey[850] : Colors.grey[50],
      body: Consumer3<HabitProvider, TodoProvider, PlannerProvider>(
        builder: (context, habitProvider, todoProvider, plannerProvider, _) {
          final notifications = _buildNotificationsList(
            habitProvider,
            todoProvider,
            plannerProvider,
          );

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete tasks and habits to see updates here',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationCard(
                icon: notification['icon'] as IconData,
                title: notification['title'] as String,
                subtitle: notification['subtitle'] as String,
                time: notification['time'] as String,
                color: notification['color'] as Color,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _buildNotificationsList(
    HabitProvider habitProvider,
    TodoProvider todoProvider,
    PlannerProvider plannerProvider,
  ) {
    final List<Map<String, dynamic>> notifications = [];

    // Add completed habits
    for (final habit in habitProvider.habits.where((h) => h.isCompleted)) {
      notifications.add({
        'icon': Icons.check_circle,
        'title': 'Habit Completed',
        'subtitle': '${habit.name} - ${habit.streak} day streak! 🔥',
        'time': _formatTime(habit.lastCompleted ?? DateTime.now()),
        'color': Colors.green,
      });
    }

    // Add completed todos
    for (final todo in todoProvider.todos.where((t) => t.isCompleted)) {
      notifications.add({
        'icon': Icons.task_alt,
        'title': 'To-Do Completed',
        'subtitle': todo.title,
        'time': _formatTime(todo.createdAt),
        'color': Colors.blue,
      });
    }

    // Add completed tasks
    for (final task in plannerProvider.tasks.where((t) => t.isCompleted)) {
      notifications.add({
        'icon': Icons.event_available,
        'title': 'Task Completed',
        'subtitle': task.title,
        'time': _formatTime(task.date),
        'color': Colors.orange,
      });
    }

    // Sort by time (most recent first)
    notifications.sort((a, b) {
      // This is a simple sort, in production you'd want actual timestamps
      return 0;
    });

    return notifications.take(20).toList(); // Show last 20 notifications
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final bool isDark;

  const _NotificationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
