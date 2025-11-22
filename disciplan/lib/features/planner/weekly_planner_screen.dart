import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/planner_task.dart';
import '../../providers/app_data_provider.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  TaskFrequency _selectedFrequency = TaskFrequency.daily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => _handleBack(context),
        ),
        title: const Text('Planner'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<TaskFrequency>(
              segments: const [
                ButtonSegment(value: TaskFrequency.daily, label: Text('Daily')),
                ButtonSegment(value: TaskFrequency.weekly, label: Text('Weekly')),
                ButtonSegment(value: TaskFrequency.monthly, label: Text('Monthly')),
              ],
              showSelectedIcon: false,
              selected: {_selectedFrequency},
              onSelectionChanged: (selection) {
                setState(() => _selectedFrequency = selection.first);
              },
            ),
          ),
          Expanded(
            child: Consumer<AppDataProvider>(
              builder: (context, data, _) {
                final tasks = data.plannerTasks
                    .where((task) => task.frequency == _selectedFrequency)
                    .toList()
                  ..sort((a, b) => a.date.compareTo(b.date));

                if (tasks.isEmpty) {
                  return _EmptyPlannerState(
                    frequency: _selectedFrequency,
                    onAdd: () => _showAddTaskSheet(context),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => context.read<AppDataProvider>().togglePlannerTask(task.id),
                        ),
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formattedDate(task.date)),
                            if (task.notes != null && task.notes!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(task.notes!),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => context.read<AppDataProvider>().removePlannerTask(task.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Schedule task'),
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

  Future<void> _showAddTaskSheet(BuildContext context) async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    TaskFrequency frequency = _selectedFrequency;
    DateTime date = DateTime.now();
    final formKey = GlobalKey<FormState>();

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
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text('New task', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Enter a title' : null,
                    ),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes (optional)'),
                      minLines: 1,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskFrequency>(
                      value: frequency,
                      items: TaskFrequency.values
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f.name[0].toUpperCase() + f.name.substring(1)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => frequency = value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Cadence'),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Scheduled for'),
                      subtitle: Text(_formattedDate(date)),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setSheetState(() => date = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            context.read<AppDataProvider>().addPlannerTask(
                                  title: titleController.text.trim(),
                                  date: date,
                                  frequency: frequency,
                                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                                );
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Save task'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EmptyPlannerState extends StatelessWidget {
  const _EmptyPlannerState({required this.frequency, required this.onAdd});

  final TaskFrequency frequency;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final label = frequency.name[0].toUpperCase() + frequency.name.substring(1);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No $label tasks yet', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Keep your schedule intentional by adding a $label focus.'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Plan task'),
            ),
          ],
        ),
      ),
    );
  }
}
