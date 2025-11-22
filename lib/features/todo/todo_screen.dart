import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';
import '../../data/models/todo.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import '../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/notification_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  String _selectedFrequency = 'daily';

  @override
  void initState() {
    super.initState();
    // Schedule motivational nudge at 7pm if no tasks completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TodoProvider>(context, listen: false);
      final now = DateTime.now();
      final nudgeTime = DateTime(now.year, now.month, now.day, 19, 0);
      if (now.isBefore(nudgeTime)) {
        NotificationService.scheduleReminder(
          id: 99999,
          title: 'Stay on Track!',
          body: 'Don\'t forget to complete a task today for your productivity!',
          scheduledTime: nudgeTime,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider()..loadTodos(),
      child: Consumer<TodoProvider>(
        builder: (context, provider, _) {
          final todos = provider.todos;
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text('To-Do List'),
            ),
            body: todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No to-dos yet.', style: AppTheme.glassSubtitle),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: AppTheme.glassBox(),
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(
                              todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: todo.isCompleted ? Colors.green : Colors.grey,
                            ),
                            tooltip: todo.isCompleted ? 'Completed' : 'Mark as completed',
                            onPressed: () async {
                              provider.toggleCompleted(todo.id);
                              if (!todo.isCompleted) {
                                // Only notify when marking as completed
                                await NotificationService.scheduleReminder(
                                  id: todo.id.hashCode,
                                  title: 'Task Completed!',
                                  body: 'Great job! You completed "${todo.title}".',
                                  scheduledTime: DateTime.now().add(const Duration(seconds: 1)),
                                );
                              }
                            },
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text('Frequency: ${todo.frequency[0].toUpperCase()}${todo.frequency.substring(1)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => provider.deleteTodo(todo.id),
                          ),
                          onTap: () async {
                            final newTitle = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Edit To-Do'),
                                content: TextField(
                                  controller: TextEditingController(text: todo.title),
                                  onSubmitted: (value) => Navigator.pop(context, value),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, null),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, todo.title),
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            );
                            if (newTitle != null && newTitle.isNotEmpty) {
                              provider.updateTodo(todo.copyWith(title: newTitle));
                            }
                          },
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                String? title;
                String frequency = 'daily';
                await showDialog(
                  context: context,
                  builder: (context) {
                    String tempTitle = '';
                    String tempFrequency = 'daily';
                    return StatefulBuilder(
                      builder: (context, setState) => AlertDialog(
                        title: const Text('New To-Do'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              autofocus: true,
                              decoration: const InputDecoration(hintText: 'To-Do title'),
                              onChanged: (val) => tempTitle = val,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: tempFrequency,
                              decoration: const InputDecoration(labelText: 'Frequency'),
                              items: const [
                                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                              ],
                              onChanged: (val) => setState(() => tempFrequency = val ?? 'daily'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, null),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              title = tempTitle;
                              frequency = tempFrequency;
                              Navigator.pop(context, true);
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    );
                  },
                );
                if (title != null && title!.isNotEmpty) {
                  provider.addTodo(Todo(id: const Uuid().v4(), title: title!, frequency: frequency));
                }
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
} 