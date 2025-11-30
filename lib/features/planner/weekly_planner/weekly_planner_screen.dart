import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/planner_provider.dart';
import '../../../data/models/planner_task.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/custom_bottom_nav.dart';
import 'package:uuid/uuid.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  int _currentNavIndex = 1;
  DateTime _selectedDate = DateTime.now();
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = _getWeekStart(_selectedDate);
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentNavIndex == 0) {
      context.go('/dashboard');
      return const SizedBox.shrink();
    } else if (_currentNavIndex == 2) {
      context.go('/habits');
      return const SizedBox.shrink();
    } else if (_currentNavIndex == 3) {
      context.go('/progress');
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            
            // Week selector
            SliverToBoxAdapter(
              child: _buildWeekSelector(context),
            ),
            
            // Upcoming events
            SliverToBoxAdapter(
              child: _buildUpcomingEvents(context),
            ),
            
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: GradientFAB(
        onPressed: () => _showAddEventDialog(context),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final month = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'][now.month - 1];
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Planner',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '$month ${now.year}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Week'),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => context.push('/monthly-planner'),
                child: const Text('Month'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _weekStart = _weekStart.subtract(const Duration(days: 7));
                  });
                },
              ),
              Text(
                '${_formatDate(_weekStart)} - ${_formatDate(_weekStart.add(const Duration(days: 6)))}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _weekStart = _weekStart.add(const Duration(days: 7));
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = _weekStart.add(Duration(days: index));
              final isSelected = date.day == _selectedDate.day &&
                                date.month == _selectedDate.month;
              final isToday = date.day == DateTime.now().day &&
                             date.month == DateTime.now().month;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    children: [
                      Text(
                        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected 
                              ? Colors.white 
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Colors.white 
                              : isToday
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                        ),
                      ),
                      if (_hasEventsOnDate(date))
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context) {
    final provider = context.watch<PlannerProvider>();
    final events = provider.tasks.where((task) {
      return task.date.day == _selectedDate.day &&
             task.date.month == _selectedDate.month;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Text(
            'Upcoming',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 48,
                    color: AppColors.textTertiary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No events scheduled',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(event);
            },
          ),
      ],
    );
  }

  Widget _buildEventCard(PlannerTask event) {
    final categoryColor = _getCategoryColor(event.category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(
          left: BorderSide(color: categoryColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'work':
        return AppColors.primary;
      case 'personal':
        return AppColors.purple;
      case 'health':
        return AppColors.success;
      case 'learning':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  bool _hasEventsOnDate(DateTime date) {
    final provider = context.read<PlannerProvider>();
    return provider.tasks.any((task) =>
      task.date.day == date.day &&
      task.date.month == date.month &&
      task.date.year == date.year
    );
  }

  String _formatDate(DateTime date) {
    final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
    return '$month ${date.day}';
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    String selectedCategory = 'Work';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Add Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                hintText: 'e.g., Team Meeting',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['Work', 'Personal', 'Health', 'Learning']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                selectedCategory = value!;
              },
            ),
          ],
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
                  date: _selectedDate,
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