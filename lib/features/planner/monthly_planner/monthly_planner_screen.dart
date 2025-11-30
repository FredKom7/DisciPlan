import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/planner_provider.dart';
import '../../../data/models/planner_task.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import 'package:uuid/uuid.dart';
import 'package:table_calendar/table_calendar.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Monthly Planner'),
      ),
      body: Consumer<PlannerProvider>(
        builder: (context, provider, _) {
          final tasksForDay = provider.getTasksForDate(_selectedDay);
          
          return Column(
            children: [
              // Calendar
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: TableCalendar(
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
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      gradient: AppColors.gradientBlue,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),

              // Tasks for selected day
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tasks for ${_selectedDay.day}/${_selectedDay.month}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      '${tasksForDay.length} tasks',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Task list
              Expanded(
                child: tasksForDay.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        itemCount: tasksForDay.length,
                        itemBuilder: (context, index) {
                          final task = tasksForDay[index];
                          return _buildTaskCard(task, provider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: GradientFAB(
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  Widget _buildTaskCard(PlannerTask task, PlannerProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(
          left: BorderSide(
            color: _getCategoryColor(task.category ?? 'Other'),
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => provider.toggleTask(task.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? AppColors.success : AppColors.textTertiary,
                  width: 2,
                ),
                color: task.isCompleted ? AppColors.success : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                ),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (task.category != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getCategoryColor(task.category!).withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                task.category!,
                style: TextStyle(
                  color: _getCategoryColor(task.category!),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 80,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No tasks for this day',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add a task to get started!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return AppColors.primary;
      case 'personal':
        return AppColors.purple;
      case 'health':
        return AppColors.success;
      case 'study':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Work';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Add Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Team Meeting',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add details...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Work', 'Personal', 'Health', 'Study']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          GradientButton(
            text: 'Add',
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final task = PlannerTask(
                  id: const Uuid().v4(),
                  title: titleController.text,
                  description: descController.text.isEmpty ? '' : descController.text,
                  date: _selectedDay,
                  isCompleted: false,
                  category: selectedCategory,
                );
                context.read<PlannerProvider>().addTask(task);
                Navigator.pop(context);
              }
            },
            height: 40,
          ),
        ],
      ),
    );
  }
}