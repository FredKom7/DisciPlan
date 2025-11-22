import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/todo/todo_screen.dart';
import '../features/habits/habits_screen.dart';
import '../features/planner/weekly_planner_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/restrictions/restrictions_screen.dart';
import '../features/screen_time/screen_time_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/planner',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const WeeklyPlannerScreen(),
        ),
      ),
      GoRoute(
        path: '/tasks',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const TodoScreen(),
        ),
      ),
      GoRoute(
        path: '/habits',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HabitsScreen(),
        ),
      ),
      GoRoute(
        path: '/progress',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProgressScreen(),
        ),
      ),
      GoRoute(
        path: '/restrictions',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RestrictionsScreen(),
        ),
      ),
      GoRoute(
        path: '/screen-time',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ScreenTimeScreen(),
        ),
      ),
    ],
  );
}


