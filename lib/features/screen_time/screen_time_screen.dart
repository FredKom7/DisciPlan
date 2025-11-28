import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/screen_time_provider.dart';
import '../../data/models/screen_time_entry.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

const categories = ['Productive', 'Neutral', 'Distracting'];

class ScreenTimeScreen extends StatefulWidget {
  const ScreenTimeScreen({Key? key}) : super(key: key);

  @override
  State<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends State<ScreenTimeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScreenTimeProvider>(context, listen: false).loadEntriesForDate(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 0,
        title: const Text('Screen Time', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.black87),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      Provider.of<ScreenTimeProvider>(context, listen: false)
                          .loadEntriesForDate(picked);
                    }
                  },
                ),
              ],
            ),
          ),
          Consumer<ScreenTimeProvider>(
            builder: (context, provider, _) {
              final summary = provider.getCategorySummary();
              if (summary.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 48.0),
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
                        child: Icon(Icons.timelapse, size: 72, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 24),
                      Text('No screen time data for this day!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Text('Tap + to add your first entry.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                );
              }
              return SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: summary.entries.map((e) {
                      final color = e.key == 'Productive'
                          ? Colors.green
                          : e.key == 'Neutral'
                              ? Colors.blue
                              : Colors.red;
                      return PieChartSectionData(
                        color: color,
                        value: e.value.toDouble(),
                        title: '${e.key}\n${e.value} min',
                        radius: 60,
                        titleStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const Divider(),
          Expanded(
            child: Consumer<ScreenTimeProvider>(
              builder: (context, provider, _) {
                final entries = provider.entries;
                if (entries.isEmpty) {
                  return Center(
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
                          child: Icon(Icons.timelapse, size: 72, color: Colors.grey.shade400),
                        ),
                        const SizedBox(height: 24),
                        Text('No entries!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Text('Tap + to add your first entry.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
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
                        title: Text(entry.appName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                        subtitle: Text('${entry.duration} min | ${entry.category}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          tooltip: 'Delete',
                          onPressed: () => provider.deleteEntry(entry.id, _selectedDate),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () async {
            final provider = Provider.of<ScreenTimeProvider>(context, listen: false);
            final result = await showDialog<ScreenTimeEntry>(
              context: context,
              builder: (context) => _AddScreenTimeEntryDialog(date: _selectedDate),
            );
            if (result != null) {
              provider.addEntry(result);
            }
          },
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: 'Add Entry',
        ),
      ),
    );
  }
}

class _AddScreenTimeEntryDialog extends StatefulWidget {
  final DateTime date;
  const _AddScreenTimeEntryDialog({required this.date});

  @override
  State<_AddScreenTimeEntryDialog> createState() => _AddScreenTimeEntryDialogState();
}

class _AddScreenTimeEntryDialogState extends State<_AddScreenTimeEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  String _appName = '';
  String _category = categories[0];
  int _duration = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Screen Time Entry', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'App/Site Name'),
              validator: (val) => val == null || val.isEmpty ? 'Enter a name' : null,
              onSaved: (val) => _appName = val ?? '',
            ),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val ?? categories[0]),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              keyboardType: TextInputType.number,
              validator: (val) {
                final n = int.tryParse(val ?? '');
                if (n == null || n <= 0) return 'Enter a valid duration';
                return null;
              },
              onSaved: (val) => _duration = int.tryParse(val ?? '') ?? 0,
            ),
          ],
        ),
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
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              Navigator.pop(
                context,
                ScreenTimeEntry(
                  id: const Uuid().v4(),
                  appName: _appName,
                  category: _category,
                  duration: _duration,
                  date: widget.date,
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