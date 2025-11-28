import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Initialize notification channels
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null, // No iOS setup for web
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  // ==================== TASK NOTIFICATIONS ====================
  
  static Future<void> notifyTaskAdded(String taskTitle, DateTime taskTime) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '📝 New Task Added',
      body: '$taskTitle scheduled for ${_formatTime(taskTime)}',
    );
  }

  static Future<void> notifyTaskCompleted(String taskTitle) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '✅ Task Completed!',
      body: 'Great job! You completed: $taskTitle',
    );
  }

  // ==================== HABIT NOTIFICATIONS ====================

  static Future<void> notifyHabitCompleted(String habitName, int streak) async {
    String message = streak > 1 
        ? '🔥 $streak day streak! Keep it up!'
        : 'Great start! Keep building your streak!';
    
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '✨ Habit Completed: $habitName',
      body: message,
    );
  }

  static Future<void> notifyHabitStreak(String habitName, int streak) async {
    if (streak % 7 == 0) {
      await _showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '🎉 Amazing Streak!',
        body: '$habitName: $streak days strong! You\'re doing great!',
      );
    }
  }

  // ==================== TODO NOTIFICATIONS ====================

  static Future<void> notifyTodoAdded(String todoTitle) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '📋 New To-Do Added',
      body: todoTitle,
    );
  }

  static Future<void> notifyTodoCompleted(String todoTitle) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '✅ To-Do Completed!',
      body: 'Nice work on: $todoTitle',
    );
  }

  // ==================== CORE METHODS ====================

  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
      ),
    );
  }

  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
    
    // For web, we'll use a simple notification without scheduling
    // since scheduled notifications might not be fully supported on web
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Channel for reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
      ),
    );
  }

  static Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }

  // Helper method to format time
  static String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}