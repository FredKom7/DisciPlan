import 'package:flutter/material.dart';
import '../../core/widgets/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Welcome to DisciPlan Dashboard!')),
    );
  }
} 