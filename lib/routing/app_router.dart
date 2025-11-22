import 'package:go_router/go_router.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/planner/weekly_planner/weekly_planner_screen.dart';
import '../features/planner/monthly_planner/monthly_planner_screen.dart';
import '../features/todo/todo_screen.dart';
import '../features/restrictions/restrictions_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/habits/habits_screen.dart';
import '../features/screen_time/screen_time_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/planner',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WeeklyPlannerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/monthly-planner',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MonthlyPlannerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/tasks',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TodoScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/restrictions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RestrictionsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/progress',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProgressScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/habits',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HabitsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/screen-time',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ScreenTimeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
    ],
  );
} 