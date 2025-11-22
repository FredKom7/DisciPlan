import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../data/models/habit.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import '../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

const defaultHabits = [
  'Meditation',
  'Workouts',
  'Manifesting',
  'Journaling',
];

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HabitProvider()..loadHabits(),
      child: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          final habits = provider.habits;
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                onPressed: () => context.pop(),
              ),
              backgroundColor: Colors.white.withOpacity(0.85),
              elevation: 0,
              title: const Text('Habits', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
              centerTitle: true,
            ),
            body: habits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(Icons.hourglass_empty, size: 72, color: Colors.grey.shade400),
                        ),
                        const SizedBox(height: 24),
                        Text('No habits yet!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Text('Tap the + button to add your first habit.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          title: Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                tooltip: 'Edit',
                                onPressed: () async {
                                  final newName = await showDialog<String>(
                                    context: context,
                                    builder: (context) => _HabitDialog(
                                      title: 'Edit Habit',
                                      initialValue: habit.name,
                                      confirmText: 'Save',
                                    ),
                                  );
                                  if (newName != null && newName.isNotEmpty) {
                                    provider.updateHabit(habit.copyWith(name: newName));
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Delete',
                                onPressed: () => provider.deleteHabit(habit.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () async {
                final name = await showDialog<String>(
                  context: context,
                  builder: (context) => _HabitDialog(
                    title: 'New Habit',
                    initialValue: '',
                    confirmText: 'Add',
                  ),
                );
                if (name != null && name.isNotEmpty) {
                  provider.addHabit(Habit(id: const Uuid().v4(), name: name));
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Add Habit',
            ),
            backgroundColor: Colors.grey[100],
          );
        },
      ),
    );
  }
}

class _HabitDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final String confirmText;
  const _HabitDialog({required this.title, required this.initialValue, required this.confirmText});

  @override
  State<_HabitDialog> createState() => _HabitDialogState();
}

class _HabitDialogState extends State<_HabitDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Habit name'),
        onSubmitted: (value) => Navigator.pop(context, value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
} 