import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../providers/planner_provider.dart';
import '../../../data/models/planner_task.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import '../../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Planner'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlannerTab(context, 'daily'),
          _buildPlannerTab(context, 'weekly'),
          _buildPlannerTab(context, 'monthly'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final provider = Provider.of<PlannerProvider>(context, listen: false);
          final frequency = ['daily', 'weekly', 'monthly'][_tabController.index];
          final result = await showDialog<PlannerTask>(
            context: context,
            builder: (context) => _AddPlannerTaskDialog(date: _selectedDay, frequency: frequency),
          );
          if (result != null) {
            provider.addTask(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlannerTab(BuildContext context, String frequency) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: frequency == 'monthly'
              ? CalendarFormat.month
              : frequency == 'weekly'
                  ? CalendarFormat.week
                  : CalendarFormat.twoWeeks,
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
              _selectedDay = focusedDay;
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
                  .where((t) => t.frequency == frequency && isSameDay(t.date, _selectedDay))
                  .toList();
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('No tasks for this ${frequency}.', style: AppTheme.glassSubtitle),
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
                      subtitle: Row(
                        children: [
                          Text('Priority: ${['Low', 'Medium', 'High'][task.priority]}', style: const TextStyle(color: Colors.black87)),
                          const SizedBox(width: 12),
                          _TaskStopwatchWidget(taskId: task.id),
                        ],
                      ),
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
    );
  }
}

class _TaskStopwatchWidget extends StatefulWidget {
  final String taskId;
  const _TaskStopwatchWidget({required this.taskId});

  @override
  State<_TaskStopwatchWidget> createState() => _TaskStopwatchWidgetState();
}

class _TaskStopwatchWidgetState extends State<_TaskStopwatchWidget> {
  Stopwatch _stopwatch = Stopwatch();
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick);
  }

  void _onTick(Duration duration) {
    if (_stopwatch.isRunning) {
      setState(() {
        _elapsed = _stopwatch.elapsed;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(_formatDuration(_elapsed), style: const TextStyle(fontSize: 12, color: Colors.black54)),
        IconButton(
          icon: Icon(_stopwatch.isRunning ? Icons.pause : Icons.play_arrow, size: 18),
          onPressed: () {
            setState(() {
              if (_stopwatch.isRunning) {
                _stopwatch.stop();
                _ticker.stop();
              } else {
                _stopwatch.start();
                _ticker.start();
              }
            });
          },
        ),
        if (_stopwatch.isRunning || _elapsed > Duration.zero)
          IconButton(
            icon: const Icon(Icons.stop, size: 18),
            onPressed: () {
              setState(() {
                _stopwatch.reset();
                _elapsed = Duration.zero;
                _ticker.stop();
              });
            },
          ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _AddPlannerTaskDialog extends StatefulWidget {
  final DateTime date;
  final String frequency;
  const _AddPlannerTaskDialog({required this.date, required this.frequency});

  @override
  State<_AddPlannerTaskDialog> createState() => _AddPlannerTaskDialogState();
}

class _AddPlannerTaskDialogState extends State<_AddPlannerTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  int _priority = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.frequency[0].toUpperCase()}${widget.frequency.substring(1)} Task'),
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
                  frequency: widget.frequency,
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