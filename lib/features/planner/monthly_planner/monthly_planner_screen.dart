import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/planner_provider.dart';
import '../../../data/models/planner_task.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import '../../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

class MonthlyPlannerScreen extends StatefulWidget {
  const MonthlyPlannerScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyPlannerScreen> createState() => _MonthlyPlannerScreenState();
}

class _MonthlyPlannerScreenState extends State<MonthlyPlannerScreen> {
  late DateTime _monthStart;

  @override
  void initState() {
    super.initState();
    _monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlannerProvider>(context, listen: false).loadTasksForMonth(_monthStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        final tasks = provider.tasks.where((t) => t.date.month == _monthStart.month && t.date.year == _monthStart.year).toList();
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No tasks for this month.', style: AppTheme.glassSubtitle),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: const Text('Monthly Planner'),
          ),
          body: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: AppTheme.glassBox(),
                      child: ListTile(
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text(task.date.toIso8601String()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => provider.deleteTask(task.id, _monthStart),
                        ),
                        onTap: () async {
                          final newTitle = await showDialog<String>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Edit Task'),
                              content: TextField(
                                controller: TextEditingController(text: task.title),
                                onSubmitted: (value) => Navigator.pop(context, value),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, null),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, task.title),
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                          if (newTitle != null && newTitle.isNotEmpty) {
                            provider.updateTask(task.copyWith(title: newTitle));
                          }
                        },
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final title = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('New Task'),
                  content: const TextField(
                    autofocus: true,
                    decoration: InputDecoration(hintText: 'Task title'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, ''),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              );
              if (title != null && title.isNotEmpty) {
                provider.addTask(PlannerTask(id: const Uuid().v4(), title: title, date: _monthStart));
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
} 