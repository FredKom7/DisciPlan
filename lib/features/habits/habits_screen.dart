import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../data/models/habit.dart';
import 'package:uuid/uuid.dart';
import '../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Habits'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDark ? Colors.grey[850] : Colors.grey[50],
      body: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          final habits = provider.habits;
          
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.self_improvement,
                    size: 80,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No habits yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start building good habits today!',
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
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final lastCompleted = habit.lastCompleted;
              final isCompletedToday = lastCompleted != null &&
                  DateTime(lastCompleted.year, lastCompleted.month, lastCompleted.day)
                      .isAtSameMomentAs(today);

              return _HabitCard(
                habit: habit,
                isCompletedToday: isCompletedToday,
                isDark: isDark,
                onToggle: () {
                  if (!isCompletedToday) {
                    provider.markCompleted(habit);
                  }
                },
                onEdit: () => _showEditDialog(context, habit, provider),
                onDelete: () => _showDeleteConfirmation(context, habit, provider),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Habit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddEditHabitDialog(
        onSave: (name) {
          final provider = Provider.of<HabitProvider>(context, listen: false);
          provider.addHabit(Habit(
            id: const Uuid().v4(),
            name: name,
            isCompleted: false,
            streak: 0,
            createdAt: DateTime.now(),
          ));
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Habit habit, HabitProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _AddEditHabitDialog(
        habit: habit,
        onSave: (name) {
          provider.updateHabit(Habit(
            id: habit.id,
            name: name,
            isCompleted: habit.isCompleted,
            streak: habit.streak,
            lastCompleted: habit.lastCompleted,
            createdAt: habit.createdAt,
          ));
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Habit habit, HabitProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"? This will reset your ${habit.streak} day streak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteHabit(habit.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompletedToday;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HabitCard({
    required this.habit,
    required this.isCompletedToday,
    required this.isDark,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompletedToday
              ? [Colors.green.shade400, Colors.green.shade600]
              : isDark
                  ? [Colors.grey[800]!, Colors.grey[850]!]
                  : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isCompletedToday
                ? Colors.green.withOpacity(0.3)
                : isDark
                    ? Colors.black26
                    : Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onToggle,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompletedToday
                              ? Colors.white
                              : isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[100],
                          border: Border.all(
                            color: isCompletedToday ? Colors.white : AppTheme.primaryColor,
                            width: 3,
                          ),
                        ),
                        child: isCompletedToday
                            ? Icon(Icons.check, color: Colors.green.shade700, size: 32)
                            : Icon(Icons.self_improvement, color: AppTheme.primaryColor, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isCompletedToday ? Colors.white : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 18,
                                color: habit.streak > 0
                                    ? Colors.orange
                                    : (isCompletedToday ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${habit.streak} day streak',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isCompletedToday ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: isCompletedToday ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                    ),
                  ],
                ),
                if (habit.streak > 0) ...[
                  const SizedBox(height: 16),
                  _StreakVisualization(streak: habit.streak, isCompletedToday: isCompletedToday, isDark: isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StreakVisualization extends StatelessWidget {
  final int streak;
  final bool isCompletedToday;
  final bool isDark;

  const _StreakVisualization({
    required this.streak,
    required this.isCompletedToday,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final displayDays = streak > 7 ? 7 : streak;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 7 days',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isCompletedToday ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(7, (index) {
            final isActive = index < displayDays;
            return Expanded(
              child: Container(
                height: 8,
                margin: EdgeInsets.only(right: index < 6 ? 4 : 0),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isCompletedToday ? Colors.white : Colors.orange)
                      : (isCompletedToday ? Colors.white30 : (isDark ? Colors.white12 : Colors.grey.shade300)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _AddEditHabitDialog extends StatefulWidget {
  final Habit? habit;
  final Function(String name) onSave;

  const _AddEditHabitDialog({this.habit, required this.onSave});

  @override
  State<_AddEditHabitDialog> createState() => _AddEditHabitDialogState();
}

class _AddEditHabitDialogState extends State<_AddEditHabitDialog> {
  late TextEditingController _nameController;
  final List<String> _suggestions = [
    'Meditation',
    'Exercise',
    'Reading',
    'Journaling',
    'Drink Water',
    'Early Wake Up',
    'Healthy Eating',
    'Gratitude Practice',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                      child: const Icon(Icons.self_improvement, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.habit == null ? 'Add New Habit' : 'Edit Habit',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Habit Name
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Habit Name',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    hintText: 'e.g., Morning Meditation',
                    hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                    prefixIcon: Icon(Icons.fitness_center, color: AppTheme.primaryColor),
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
                ),
                const SizedBox(height: 20),
                
                // Suggestions
                Text(
                  'Popular Habits',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions.map((suggestion) {
                    return ActionChip(
                      label: Text(suggestion),
                      onPressed: () => setState(() => _nameController.text = suggestion),
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
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
                        onPressed: () {
                          if (_nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a habit name')),
                            );
                            return;
                          }
                          widget.onSave(_nameController.text.trim());
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              widget.habit == null ? 'Add Habit' : 'Save Changes',
                              style: const TextStyle(
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
    );
  }
}