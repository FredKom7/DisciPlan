import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/app_data_provider.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => _handleBack(context),
        ),
        title: const Text('Habits'),
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, data, _) {
          if (data.habits.isEmpty) {
            return _EmptyHabits(onAdd: () => _showAddHabitDialog(context));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.habits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final habit = data.habits[index];
              return Card(
                child: ListTile(
                  title: Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Streak: ${habit.streak} day${habit.streak == 1 ? '' : 's'}'),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: habit.isActive,
                        onChanged: (_) => context.read<AppDataProvider>().toggleHabitActivity(habit.id),
                      ),
                      Text(
                        habit.isActive ? 'Active' : 'Paused',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  onTap: () => context.read<AppDataProvider>().incrementHabitStreak(habit.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New habit'),
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

  Future<void> _showAddHabitDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create habit'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Habit name'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Enter a habit' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  context.read<AppDataProvider>().addHabit(controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyHabits extends StatelessWidget {
  const _EmptyHabits({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.repeat, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No habits yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Track consistent actions to build momentum.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add habit'),
          ),
        ],
      ),
    );
  }
}