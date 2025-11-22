import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'providers/planner_provider.dart';
import 'providers/todo_provider.dart';
import 'providers/restriction_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/screen_time_provider.dart';
import 'providers/theme_provider.dart';
import 'data/models/todo.dart';
import 'data/models/planner_task.dart';
import 'data/models/habit.dart';
import 'data/models/screen_time_entry.dart';
import 'data/models/restriction.dart';
import 'data/models/progress_entry.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  Hive.registerAdapter(PlannerTaskAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(ScreenTimeEntryAdapter());
  Hive.registerAdapter(RestrictionAdapter());
  Hive.registerAdapter(ProgressEntryAdapter());
  // Register other adapters here as needed
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => PlannerProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => RestrictionProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => ScreenTimeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const DisciPlanApp(),
    ),
  );
} 