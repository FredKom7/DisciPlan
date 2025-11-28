import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../providers/planner_provider.dart';
import '../../../data/models/planner_task.dart';
import 'package:uuid/uuid.dart';
import '../../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text('Planner', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? Colors.white : Colors.black87,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      backgroundColor: isDark ? Colors.grey[850] : Colors.grey[100],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlannerTab(context, 'daily', isDark),
          _buildPlannerTab(context, 'weekly', isDark),
          _buildPlannerTab(context, 'monthly', isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPlannerTab(BuildContext context, String frequency, bool isDark) {
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
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
            weekendTextStyle: TextStyle(color: isDark ? Colors.orange.shade300 : Colors.orange.shade700),
            outsideTextStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black87),
            rightChevronIcon: Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.black87),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            weekendStyle: TextStyle(color: isDark ? Colors.orange.shade300 : Colors.orange.shade700),
          ),
        ),
        const Divider(height: 1),
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
                      Icon(Icons.event_busy, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks for this day.',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add a task',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final priorityColors = [Colors.green, Colors.orange, Colors.red];
                  final priorityColor = priorityColors[task.priority];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: task.isCompleted 
                            ? (isDark ? Colors.green.shade700 : Colors.green.shade300)
                            : (isDark ? Colors.white12 : Colors.grey.shade200),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (val) {
                          provider.updateTask(
                            task.copyWith(isCompleted: val ?? false),
                          );
                        },
                        activeColor: Colors.green,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: priorityColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              ['Low', 'Med', 'High'][task.priority],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 4),
                          _TaskStopwatchWidget(taskId: task.id, isDark: isDark),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: isDark ? Colors.red.shade300 : Colors.redAccent),
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
  final bool isDark;
  const _TaskStopwatchWidget({required this.taskId, required this.isDark});

  @override
  State<_TaskStopwatchWidget> createState() => _TaskStopwatchWidgetState();
}

class _TaskStopwatchWidgetState extends State<_TaskStopwatchWidget> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Stopwatch _stopwatch = Stopwatch();
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick);
    _ticker.start();
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
        Icon(Icons.timer, size: 14, color: widget.isDark ? Colors.white54 : Colors.black54),
        const SizedBox(width: 4),
        Text(
          _formatDuration(_elapsed),
          style: TextStyle(
            fontSize: 12,
            color: widget.isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: Icon(
            _stopwatch.isRunning ? Icons.pause_circle : Icons.play_circle,
            size: 20,
            color: _stopwatch.isRunning ? Colors.orange : (widget.isDark ? Colors.green.shade300 : Colors.green),
          ),
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
            icon: Icon(Icons.stop_circle, size: 20, color: widget.isDark ? Colors.red.shade300 : Colors.red),
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
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _priority = 1;
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.accentColor],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.add_task, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add ${widget.frequency[0].toUpperCase()}${widget.frequency.substring(1)} Task',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              _formatDate(widget.date),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                      hintText: 'e.g., Complete project report',
                      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                      prefixIcon: Icon(Icons.title, color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                      hintText: 'Add details about this task...',
                      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                      prefixIcon: Icon(Icons.description, color: AppTheme.accentColor),
                      filled: true,
                      fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Time Picker
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.accentColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: AppTheme.primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Task Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _selectedTime.format(context),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppTheme.primaryColor,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() => _selectedTime = time);
                            }
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Change'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Priority Selector
                  Text(
                    'Priority Level',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _PriorityChip(
                          label: 'Low',
                          icon: Icons.arrow_downward,
                          color: Colors.green,
                          isSelected: _priority == 0,
                          onTap: () => setState(() => _priority = 0),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PriorityChip(
                          label: 'Medium',
                          icon: Icons.remove,
                          color: Colors.orange,
                          isSelected: _priority == 1,
                          onTap: () => setState(() => _priority = 1),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PriorityChip(
                          label: 'High',
                          icon: Icons.arrow_upward,
                          color: Colors.red,
                          isSelected: _priority == 2,
                          onTap: () => setState(() => _priority = 2),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: isDark ? Colors.white30 : Colors.black26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _saveTask,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Add Task',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final taskDateTime = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      Navigator.of(context).pop(
        PlannerTask(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _priority,
          isCompleted: false,
          date: taskDateTime,
          createdAt: DateTime.now(),
          frequency: widget.frequency,
        ),
      );
    }
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _PriorityChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : (isDark ? Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.white12 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : (isDark ? Colors.white54 : Colors.black54),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}