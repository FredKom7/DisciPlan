import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restriction_provider.dart';
import '../../data/models/restriction.dart';
import 'package:uuid/uuid.dart';
import '../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

class RestrictionsScreen extends StatelessWidget {
  const RestrictionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RestrictionProvider>(
      builder: (context, provider, _) {
        final allRestrictions = provider.restrictions;
        final activeRestrictions = provider.activeRestrictions;
        
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
              onPressed: () => context.go('/dashboard'),
            ),
            backgroundColor: Colors.white.withOpacity(0.85),
            elevation: 0,
            title: const Text('Restrictions', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.black87),
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
          backgroundColor: Colors.grey[100],
          body: allRestrictions.isEmpty
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
                        child: Icon(Icons.block, size: 72, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 24),
                      Text('No restrictions set!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Text('Tap + to add your first restriction.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (activeRestrictions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade400, Colors.red.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Active Restrictions',
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${activeRestrictions.length} app${activeRestrictions.length == 1 ? '' : 's'} currently blocked',
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: allRestrictions.length,
                        itemBuilder: (context, index) {
                          final restriction = allRestrictions[index];
                          final isActive = restriction.isCurrentlyActive();
                          final timeRemaining = restriction.getTimeRemainingMinutes();
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isActive ? Colors.red.shade300 : Colors.grey.shade300,
                                width: isActive ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.red.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getIconForType(restriction.type),
                                  color: isActive ? Colors.red.shade600 : Colors.grey.shade600,
                                  size: 24,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      restriction.target,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'ACTIVE',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    _getScheduleDescription(restriction),
                                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                                  ),
                                  if (isActive && timeRemaining != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.timer, size: 14, color: Colors.red.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_formatTimeRemaining(timeRemaining)} remaining',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red.shade600,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: restriction.isActive,
                                    onChanged: (val) {
                                      provider.toggleRestriction(restriction.id, val);
                                    },
                                    activeColor: Colors.red.shade600,
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditDialog(context, provider, restriction);
                                      } else if (value == 'delete') {
                                        _showDeleteConfirmation(context, provider, restriction);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 20, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.black,
            onPressed: () => _showAddRestrictionDialog(context, provider),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Restriction', style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'app_limit':
        return Icons.apps;
      case 'explicit_content':
        return Icons.explicit;
      case 'short_form':
        return Icons.video_collection;
      default:
        return Icons.block;
    }
  }

  String _getScheduleDescription(Restriction restriction) {
    switch (restriction.scheduleType) {
      case 'once':
        if (restriction.startTime != null && restriction.endTime != null) {
          final start = _formatDateTime(restriction.startTime!);
          final end = _formatDateTime(restriction.endTime!);
          return 'Once: $start - $end';
        }
        return 'One-time restriction';
      
      case 'duration':
        if (restriction.durationMinutes != null) {
          return 'Duration: ${_formatTimeRemaining(restriction.durationMinutes!)}';
        }
        return 'Duration-based';
      
      case 'daily':
        if (restriction.dailyStartTime != null && restriction.dailyEndTime != null) {
          return 'Daily: ${restriction.dailyStartTime} - ${restriction.dailyEndTime}';
        }
        return 'Daily restriction';
      
      case 'weekly':
        if (restriction.activeDays != null && restriction.dailyStartTime != null) {
          final days = restriction.activeDays!.map((d) => _getDayName(d)).join(', ');
          return 'Weekly: $days (${restriction.dailyStartTime} - ${restriction.dailyEndTime})';
        }
        return 'Weekly restriction';
      
      default:
        return 'Custom restriction';
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeRemaining(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    } else {
      final days = minutes ~/ 1440;
      final hours = (minutes % 1440) ~/ 60;
      return hours > 0 ? '${days}d ${hours}h' : '${days}d';
    }
  }

  String _getDayName(int day) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[day];
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Restrictions'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Restrictions help you stay focused by limiting access to distracting apps.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                '📱 Android: True app blocking with overlay',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                'Requires accessibility permissions',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                '💻 Other Platforms: Monitoring & accountability',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                'Tracks usage and shows reports',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAddRestrictionDialog(BuildContext context, RestrictionProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AddRestrictionScreen(provider: provider),
        fullscreenDialog: true,
      ),
    );
  }

  void _showEditDialog(BuildContext context, RestrictionProvider provider, Restriction restriction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AddRestrictionScreen(provider: provider, editingRestriction: restriction),
        fullscreenDialog: true,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, RestrictionProvider provider, Restriction restriction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Restriction'),
        content: Text('Are you sure you want to delete the restriction for "${restriction.target}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteRestriction(restriction.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Separate screen for adding/editing restrictions
class _AddRestrictionScreen extends StatefulWidget {
  final RestrictionProvider provider;
  final Restriction? editingRestriction;

  const _AddRestrictionScreen({required this.provider, this.editingRestriction});

  @override
  State<_AddRestrictionScreen> createState() => _AddRestrictionScreenState();
}

class _AddRestrictionScreenState extends State<_AddRestrictionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _appNameController;
  late TextEditingController _packageNameController;
  
  String _scheduleType = 'duration';
  int _durationValue = 1;
  String _durationUnit = 'hours';
  TimeOfDay _dailyStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _dailyEndTime = const TimeOfDay(hour: 17, minute: 0);
  Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Weekdays
  DateTime _onceStartTime = DateTime.now();
  DateTime _onceEndTime = DateTime.now().add(const Duration(hours: 2));

  @override
  void initState() {
    super.initState();
    _appNameController = TextEditingController(text: widget.editingRestriction?.target ?? '');
    _packageNameController = TextEditingController(text: widget.editingRestriction?.packageName ?? '');
    
    if (widget.editingRestriction != null) {
      _scheduleType = widget.editingRestriction!.scheduleType;
      // Load other fields based on schedule type
    }
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _packageNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingRestriction == null ? 'Add Restriction' : 'Edit Restriction'),
        actions: [
          TextButton(
            onPressed: _saveRestriction,
            child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _appNameController,
              decoration: const InputDecoration(
                labelText: 'App Name *',
                hintText: 'e.g., Instagram, YouTube',
                prefixIcon: Icon(Icons.apps),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Enter app name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _packageNameController,
              decoration: const InputDecoration(
                labelText: 'Package Name (Android)',
                hintText: 'e.g., com.instagram.android',
                prefixIcon: Icon(Icons.android),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Schedule Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildScheduleTypeSelector(),
            const SizedBox(height: 24),
            _buildScheduleConfiguration(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTypeSelector() {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Duration'),
          selected: _scheduleType == 'duration',
          onSelected: (selected) => setState(() => _scheduleType = 'duration'),
        ),
        ChoiceChip(
          label: const Text('Daily'),
          selected: _scheduleType == 'daily',
          onSelected: (selected) => setState(() => _scheduleType = 'daily'),
        ),
        ChoiceChip(
          label: const Text('Weekly'),
          selected: _scheduleType == 'weekly',
          onSelected: (selected) => setState(() => _scheduleType = 'weekly'),
        ),
        ChoiceChip(
          label: const Text('One-time'),
          selected: _scheduleType == 'once',
          onSelected: (selected) => setState(() => _scheduleType = 'once'),
        ),
      ],
    );
  }

  Widget _buildScheduleConfiguration() {
    switch (_scheduleType) {
      case 'duration':
        return _buildDurationConfig();
      case 'daily':
        return _buildDailyConfig();
      case 'weekly':
        return _buildWeeklyConfig();
      case 'once':
        return _buildOnceConfig();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDurationConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Block for:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Duration'),
                    controller: TextEditingController(text: _durationValue.toString()),
                    onChanged: (val) => _durationValue = int.tryParse(val) ?? 1,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _durationUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: const [
                      DropdownMenuItem(value: 'minutes', child: Text('Minutes')),
                      DropdownMenuItem(value: 'hours', child: Text('Hours')),
                      DropdownMenuItem(value: 'days', child: Text('Days')),
                    ],
                    onChanged: (val) => setState(() => _durationUnit = val ?? 'hours'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Quick presets:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildPresetChip('30 min', 30, 'minutes'),
                _buildPresetChip('1 hour', 1, 'hours'),
                _buildPresetChip('2 hours', 2, 'hours'),
                _buildPresetChip('1 day', 1, 'days'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, int value, String unit) {
    return ActionChip(
      label: Text(label),
      onPressed: () => setState(() {
        _durationValue = value;
        _durationUnit = unit;
      }),
    );
  }

  Widget _buildDailyConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Block daily between:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Start Time'),
              trailing: Text(_dailyStartTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _dailyStartTime);
                if (time != null) setState(() => _dailyStartTime = time);
              },
            ),
            ListTile(
              title: const Text('End Time'),
              trailing: Text(_dailyEndTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _dailyEndTime);
                if (time != null) setState(() => _dailyEndTime = time);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyConfig() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select days:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                return FilterChip(
                  label: Text(days[index]),
                  selected: _selectedDays.contains(index),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(index);
                      } else {
                        _selectedDays.remove(index);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Time'),
              trailing: Text(_dailyStartTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _dailyStartTime);
                if (time != null) setState(() => _dailyStartTime = time);
              },
            ),
            ListTile(
              title: const Text('End Time'),
              trailing: Text(_dailyEndTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _dailyEndTime);
                if (time != null) setState(() => _dailyEndTime = time);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnceConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Block from:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Start'),
              subtitle: Text(_formatDateTime(_onceStartTime)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _onceStartTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_onceStartTime),
                  );
                  if (time != null) {
                    setState(() {
                      _onceStartTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                    });
                  }
                }
              },
            ),
            ListTile(
              title: const Text('End'),
              subtitle: Text(_formatDateTime(_onceEndTime)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _onceEndTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_onceEndTime),
                  );
                  if (time != null) {
                    setState(() {
                      _onceEndTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _saveRestriction() {
    if (!_formKey.currentState!.validate()) return;

    int? durationMinutes;
    DateTime? startTime;
    DateTime? endTime;
    String? dailyStart;
    String? dailyEnd;
    List<int>? activeDays;

    switch (_scheduleType) {
      case 'duration':
        startTime = DateTime.now();
        durationMinutes = _durationValue * (_durationUnit == 'minutes' ? 1 : _durationUnit == 'hours' ? 60 : 1440);
        break;
      case 'daily':
        dailyStart = '${_dailyStartTime.hour.toString().padLeft(2, '0')}:${_dailyStartTime.minute.toString().padLeft(2, '0')}';
        dailyEnd = '${_dailyEndTime.hour.toString().padLeft(2, '0')}:${_dailyEndTime.minute.toString().padLeft(2, '0')}';
        break;
      case 'weekly':
        activeDays = _selectedDays.toList();
        dailyStart = '${_dailyStartTime.hour.toString().padLeft(2, '0')}:${_dailyStartTime.minute.toString().padLeft(2, '0')}';
        dailyEnd = '${_dailyEndTime.hour.toString().padLeft(2, '0')}:${_dailyEndTime.minute.toString().padLeft(2, '0')}';
        break;
      case 'once':
        startTime = _onceStartTime;
        endTime = _onceEndTime;
        break;
    }

    final restriction = Restriction(
      id: widget.editingRestriction?.id ?? const Uuid().v4(),
      type: 'app_limit',
      target: _appNameController.text.trim(),
      packageName: _packageNameController.text.trim().isEmpty ? null : _packageNameController.text.trim(),
      scheduleType: _scheduleType,
      durationMinutes: durationMinutes,
      startTime: startTime,
      endTime: endTime,
      dailyStartTime: dailyStart,
      dailyEndTime: dailyEnd,
      activeDays: activeDays,
      isActive: true,
    );

    if (widget.editingRestriction == null) {
      widget.provider.addRestriction(restriction);
    } else {
      widget.provider.updateRestriction(restriction);
    }

    Navigator.pop(context);
  }
}