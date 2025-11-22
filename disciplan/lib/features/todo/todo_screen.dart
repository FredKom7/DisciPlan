import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/themes/app_theme.dart';
import '../../providers/app_data_provider.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => _handleBack(context),
        ),
        title: const Text('To-Do List'),
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, data, _) {
          if (data.todos.isEmpty) {
            return _EmptyState(onAddTap: () => _showAddTodoDialog(context));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final todo = data.todos[index];
              return Dismissible(
                key: ValueKey(todo.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.redAccent),
                ),
                onDismissed: (_) => context.read<AppDataProvider>().removeTodo(todo.id),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (_) => context.read<AppDataProvider>().toggleTodo(todo.id),
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todo.note != null && todo.note!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(todo.note!),
                          ),
                        Text(
                          'Added ${_formatDate(todo.createdAt)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.drag_handle_rounded, color: Colors.grey),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: data.todos.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(context),
        icon: const Icon(Icons.add_task),
        label: const Text('New task'),
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

  Future<void> _showAddTodoDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add task'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Enter a task title' : null,
                ),
                TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  minLines: 1,
                  maxLines: 3,
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
                if (formKey.currentState?.validate() ?? false) {
                  context.read<AppDataProvider>().addTodo(
                        titleController.text.trim(),
                        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                      );
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist_rounded, size: 84, color: AppTheme.primaryColor.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text(
              'No tasks yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first task to start tracking your discipline journey.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddTap,
              icon: const Icon(Icons.add),
              label: const Text('Add a task'),
            ),
          ],
        ),
      ),
    );
  }
}