import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/progress_entry.dart';
import '../../providers/app_data_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => _handleBack(context),
        ),
        title: const Text('Progress'),
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, data, _) {
          if (data.progressEntries.isEmpty) {
            return const _EmptyProgress();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.progressEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = data.progressEntries[index];
              return _ProgressCard(entry: entry);
            },
          );
        },
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.entry});

  final ProgressEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = switch (entry.trend) {
      Trend.up => Colors.green,
      Trend.steady => Colors.orange,
      Trend.down => Colors.redAccent,
    };
    final icon = switch (entry.trend) {
      Trend.up => Icons.trending_up,
      Trend.steady => Icons.trending_flat,
      Trend.down => Icons.trending_down,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  entry.metric,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                const Spacer(),
                Text('${(entry.percentage * 100).round()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: entry.percentage,
              color: color,
              backgroundColor: color.withOpacity(0.15),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProgress extends StatelessWidget {
  const _EmptyProgress();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insights, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No insights yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('As you complete tasks and habits, insights will appear here.'),
        ],
      ),
    );
  }
}
