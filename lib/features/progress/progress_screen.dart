import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/progress_provider.dart';
import '../../data/models/progress_entry.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import '../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressProvider()..loadEntriesForMonth(DateTime.now()),
      child: Consumer<ProgressProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                onPressed: () => context.pop(),
              ),
              backgroundColor: Colors.white.withOpacity(0.85),
              elevation: 0,
              title: const Text('Progress', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
              centerTitle: true,
            ),
            backgroundColor: Colors.grey[100],
            body: provider.totalCompletedTasks == 0 && provider.totalCompletedHabits == 0 && provider.totalScreenTime == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(Icons.insights, size: 72, color: Colors.grey.shade400),
                        ),
                        const SizedBox(height: 24),
                        Text('No progress data yet!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Text('Complete tasks, habits, or track screen time to see your progress.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text('Tasks Completed: ${provider.totalCompletedTasks}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                              const SizedBox(height: 8),
                              Text('Habits Completed: ${provider.totalCompletedHabits}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                              const SizedBox(height: 8),
                              Text('Screen Time (min): ${provider.totalScreenTime}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                      _GrowthVisual(total: provider.totalCompletedTasks + provider.totalCompletedHabits),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('$value', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class _GrowthVisual extends StatelessWidget {
  final int total;
  const _GrowthVisual({required this.total});

  @override
  Widget build(BuildContext context) {
    // Use a static icon as a placeholder for growth visual
    final stage = total < 5
        ? 'Seed'
        : total < 10
            ? 'Sprout'
            : total < 20
                ? 'Bud'
                : 'Flower';
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(
            stage == 'Seed'
                ? Icons.grass
                : stage == 'Sprout'
                    ? Icons.eco
                    : stage == 'Bud'
                        ? Icons.local_florist
                        : Icons.filter_vintage,
            size: 64,
            color: Colors.green,
          ),
          Text('Growth Stage: $stage'),
        ],
      ),
    );
  }
} 