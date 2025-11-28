import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../providers/planner_provider.dart';
import '../../../data/models/planner_task.dart';
import 'package:uuid/uuid.dart';
import '../../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

class MonthlyPlannerScreen extends StatefulWidget {
  const MonthlyPlannerScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyPlannerScreen> createState() => _MonthlyPlannerScreenState();
}

class _MonthlyPlannerScreenState extends State<MonthlyPlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Monthly Planner'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Consumer<PlannerProvider>(
              builder: (context, provider, _) {
                final tasks = provider.tasks
                    .where((t) => t.frequency == 'monthly' && isSameDay(t.date, _selectedDay))
                    .toList();
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No tasks for this day.', style: AppTheme.glassSubtitle),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: AppTheme.glassBox(),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (val) {
                            provider.updateTask(
                              task.copyWith(isCompleted: val ?? false),
                            );
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text('Priority: ${['Low', 'Medium', 'High'][task.priority]}', style: const TextStyle(color: Colors.black87)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => provider.deleteTask(task.id, _focusedDay),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final provider = Provider.of<PlannerProvider>(context, listen: false);
          final result = await showDialog<PlannerTask>(
            context: context,
            builder: (context) => _AddMonthlyTaskDialog(date: _selectedDay),
          );
          if (result != null) {
            provider.addTask(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddMonthlyTaskDialog extends StatefulWidget {
  final DateTime date;
  const _AddMonthlyTaskDialog({required this.date});

  @override
  State<_AddMonthlyTaskDialog> createState() => _AddMonthlyTaskDialogState();
}

class _AddMonthlyTaskDialogState extends State<_AddMonthlyTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  int _priority = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Monthly Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (val) => val == null || val.isEmpty ? 'Enter a title' : null,
              onSaved: (val) => _title = val ?? '',
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (val) => _description = val ?? '',
            ),
            DropdownButtonFormField<int>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Low')),
                DropdownMenuItem(value: 1, child: Text('Medium')),
                DropdownMenuItem(value: 2, child: Text('High')),
              ],
              onChanged: (val) => setState(() => _priority = val ?? 1),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              Navigator.of(context).pop(
                PlannerTask(
                  id: const Uuid().v4(),
                  title: _title,
                  description: _description,
                  priority: _priority,
                  isCompleted: false,
                  date: widget.date,
                  createdAt: DateTime.now(),
                  frequency: 'monthly',
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}