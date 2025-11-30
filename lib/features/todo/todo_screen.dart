import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';
import '../../data/models/todo.dart';
import '../../core/themes/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import 'package:uuid/uuid.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, _) {
          var todos = provider.todos;
          
          // Apply filter
          if (_filter == 'Active') {
            todos = todos.where((t) => !t.isCompleted).toList();
          } else if (_filter == 'Completed') {
            todos = todos.where((t) => t.isCompleted).toList();
          }

          if (todos.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Stats bar
              _buildStatsBar(context, provider),
              
              // Task list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return _buildTaskCard(context, todo, provider);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: GradientFAB(
        onPressed: () => _showAddTaskDialog(context),
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, TodoProvider provider) {
    final total = provider.todos.length;
    final completed = provider.todos.where((t) => t.isCompleted).length;
    final active = total - completed;
    final progress = total > 0 ? (completed / total * 100).toInt() : 0;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('$total', 'Total'),
              Container(
                width: 1,
                height: 30,
                color: AppColors.divider,
              ),
              _buildStatItem('$active', 'Active'),
              Container(
                width: 1,
                height: 30,
                color: AppColors.divider,
              ),
              _buildStatItem('$completed', 'Done'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, Todo todo, TodoProvider provider) {
    final priorityColor = _getPriorityColor(todo.priority);
    
    return Dismissible(
      key: Key(todo.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => provider.deleteTodo(todo.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border(
            left: BorderSide(color: priorityColor, width: 4),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          leading: GestureDetector(
            onTap: () => provider.toggleTodo(todo.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: todo.isCompleted ? AppColors.success : priorityColor,
                  width: 2,
                ),
                color: todo.isCompleted ? AppColors.success : Colors.transparent,
              ),
              child: todo.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted 
                  ? AppColors.textTertiary 
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: todo.description != null || todo.deadline != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (todo.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        todo.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (todo.deadline != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: _isOverdue(todo.deadline!) 
                                ? AppColors.error 
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDeadline(todo.deadline!),
                            style: TextStyle(
                              fontSize: 12,
                              color: _isOverdue(todo.deadline!)
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                )
              : null,
          trailing: _buildPriorityBadge(todo.priority),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  bool _isOverdue(DateTime deadline) {
    return deadline.isBefore(DateTime.now());
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
    
    if (deadlineDate == today) {
      return 'Today ${deadline.hour}:${deadline.minute.toString().padLeft(2, '0')}';
    } else if (deadlineDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow ${deadline.hour}:${deadline.minute.toString().padLeft(2, '0')}';
    } else {
      return '${deadline.month}/${deadline.day} ${deadline.hour}:${deadline.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add your first task to get started!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All'),
            _buildFilterOption('Active'),
            _buildFilterOption('Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String filter) {
    return RadioListTile<String>(
      title: Text(filter),
      value: filter,
      groupValue: _filter,
      onChanged: (value) {
        setState(() {
          _filter = value!;
        });
        Navigator.pop(context);
      },
      activeColor: AppColors.primary,
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedPriority = 'Medium';
    
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
                  labelText: 'Task Title',
                  hintText: 'e.g., Complete project report',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['High', 'Medium', 'Low']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  selectedPriority = value!;
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
                final todo = Todo(
                  id: const Uuid().v4(),
                  title: titleController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  priority: selectedPriority,
                  createdAt: DateTime.now(),
                  isCompleted: false,
                );
                context.read<TodoProvider>().addTodo(todo);
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