import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/app_data_provider.dart';

class ScreenTimeScreen extends StatelessWidget {
  const ScreenTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => _handleBack(context),
        ),
        title: const Text('Screen Time'),
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, data, _) {
          final entries = data.screenTimeEntries;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _ScreenTimeSummary(minutes: data.todaysScreenMinutes),
              ),
              Expanded(
                child: entries.isEmpty
                    ? _EmptyScreenTime(onAdd: () => _showLogSheet(context))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.withOpacity(0.1),
                                child: const Icon(Icons.phone_android, color: Colors.indigo),
                              ),
                              title: Text(entry.appName),
                              subtitle: Text('${entry.minutes} minutes • ${_formatDate(entry.loggedAt)}'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogSheet(context),
        icon: const Icon(Icons.timelapse),
        label: const Text('Log usage'),
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

  Future<void> _showLogSheet(BuildContext context) async {
    final controller = TextEditingController();
    int minutes = 15;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'App or activity',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Minutes'),
                      Expanded(
                        child: Slider(
                          value: minutes.toDouble(),
                          min: 5,
                          max: 120,
                          divisions: 23,
                          label: '$minutes',
                          onChanged: (value) =>
                              setSheetState(() => minutes = value.toInt()),
                        ),
                      ),
                      Text('$minutes'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final name = controller.text.trim().isEmpty ? 'Unlabeled' : controller.text.trim();
                        context.read<AppDataProvider>().logScreenTime(
                              name,
                              minutes,
                              DateTime.now(),
                            );
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save entry'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ScreenTimeSummary extends StatelessWidget {
  const _ScreenTimeSummary({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final hours = (minutes / 60).floor();
    final remaining = minutes % 60;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '$hours h $remaining m',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Keep screen time intentional to stay on track.'),
        ],
      ),
    );
  }
}

class _EmptyScreenTime extends StatelessWidget {
  const _EmptyScreenTime({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.screen_lock_portrait, size: 72, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('No usage logged yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Track distracting apps to understand your patterns.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.timelapse),
            label: const Text('Log screen time'),
          ),
        ],
      ),
    );
  }
}

