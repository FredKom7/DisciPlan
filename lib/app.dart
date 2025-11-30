import 'package:flutter/material.dart';
import 'core/themes/dark_theme.dart';
import 'routing/app_router.dart';

class DisciPlanApp extends StatelessWidget {
  const DisciPlanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DisciPlan',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}