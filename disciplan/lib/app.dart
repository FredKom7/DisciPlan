import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'routing/app_router.dart';

class DisciPlanApp extends StatelessWidget {
  const DisciPlanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DisciPlan',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
} 