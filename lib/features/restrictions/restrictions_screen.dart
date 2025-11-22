import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restriction_provider.dart';
import '../../data/models/restriction.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import '../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

class RestrictionsScreen extends StatelessWidget {
  const RestrictionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RestrictionProvider()..loadRestrictions(),
      child: Consumer<RestrictionProvider>(
        builder: (context, provider, _) {
          final appLimits = provider.restrictions.where((r) => r.type == 'app_limit').toList();
          final explicit = provider.restrictions.where((r) => r.type == 'explicit_content').toList();
          final shortForm = provider.restrictions.where((r) => r.type == 'short_form').toList();
          final isEmpty = appLimits.isEmpty && explicit.isEmpty && shortForm.isEmpty;
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                onPressed: () => context.pop(),
              ),
              backgroundColor: Colors.white.withOpacity(0.85),
              elevation: 0,
              title: const Text('Restrictions', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
              centerTitle: true,
            ),
            backgroundColor: Colors.grey[100],
            body: isEmpty
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
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _RestrictionCard(title: 'App Limits', count: appLimits.length, icon: Icons.timer, color: Colors.blueAccent),
                      _RestrictionCard(title: 'Explicit Content', count: explicit.length, icon: Icons.explicit, color: Colors.redAccent),
                      _RestrictionCard(title: 'Short-Form Content', count: shortForm.length, icon: Icons.video_collection, color: Colors.purpleAccent),
                    ],
                  ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () async {
                final type = await showDialog<String>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Add Restriction', style: TextStyle(fontWeight: FontWeight.bold)),
                    children: [
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, 'app_limit'),
                        child: const Text('App Limit'),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, 'explicit_content'),
                        child: const Text('Explicit Content'),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, 'short_form'),
                        child: const Text('Short-Form Content'),
                      ),
                    ],
                  ),
                );
                if (type != null) {
                  provider.addRestriction(Restriction(id: const Uuid().v4(), type: type, target: ''));
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Add Restriction',
            ),
          );
        },
      ),
    );
  }
}

class _RestrictionCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  const _RestrictionCard({required this.title, required this.count, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
        subtitle: Text('$count restriction${count == 1 ? '' : 's'}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
      ),
    );
  }
}

class _AddRestrictionDialog extends StatefulWidget {
  final String type;
  const _AddRestrictionDialog({required this.type});

  @override
  State<_AddRestrictionDialog> createState() => _AddRestrictionDialogState();
}

class _AddRestrictionDialogState extends State<_AddRestrictionDialog> {
  final _formKey = GlobalKey<FormState>();
  String _target = '';
  int? _limitMinutes;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${_typeLabel(widget.type)} Restriction'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: widget.type == 'app_limit' ? 'App Name' : 'Target'),
              validator: (val) => val == null || val.isEmpty ? 'Enter a value' : null,
              onSaved: (val) => _target = val ?? '',
            ),
            if (widget.type == 'app_limit')
              TextFormField(
                decoration: const InputDecoration(labelText: 'Daily Limit (minutes)'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter a limit';
                  final n = int.tryParse(val);
                  if (n == null || n <= 0) return 'Enter a valid number';
                  return null;
                },
                onSaved: (val) => _limitMinutes = int.tryParse(val ?? ''),
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
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              Navigator.of(context).pop(
                Restriction(
                  id: const Uuid().v4(),
                  type: widget.type,
                  target: _target,
                  limitMinutes: _limitMinutes,
                  isActive: true,
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'app_limit':
        return 'App Limit';
      case 'explicit_content':
        return 'Explicit Content';
      case 'short_form':
        return 'Short-form Content';
      default:
        return '';
    }
  }
} 