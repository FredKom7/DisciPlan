import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/app_data_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppDataProvider(),
      child: const DisciPlanApp(),
    ),
  );
}
