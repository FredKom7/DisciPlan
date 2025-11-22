import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/restriction.dart';
import '../../providers/app_data_provider.dart';

class RestrictionsScreen extends StatelessWidget {
  const RestrictionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => _handleBack(context),
        ),
        title: const Text('Restrictions'),
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, data, _) {
          if (data.restrictions.isEmpty) {
            return _EmptyRestrictions(onAdd: () => _showAddRestrictionDialog(context));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.restrictions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final restriction = data.restrictions[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    child: Icon(_iconForType(restriction.type), color: Colors.redAccent),
                  ),
                  title: Text(restriction.title),
                  subtitle: Text(_subtitleForRestriction(restriction)),
                  trailing: Switch(
                    value: restriction.isActive,
                    onChanged: (_) => context.read<AppDataProvider>().toggleRestriction(restriction.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRestrictionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add limit'),
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

  IconData _iconForType(RestrictionType type) {
    switch (type) {
      case RestrictionType.appLimit:
        return Icons.timer;
      case RestrictionType.explicitContent:
        return Icons.explicit;
      case RestrictionType.shortForm:
        return Icons.video_collection;
    }
  }

  String _subtitleForRestriction(Restriction restriction) {
    final typeLabel = switch (restriction.type) {
      RestrictionType.appLimit => 'App limit',
      RestrictionType.explicitContent => 'Explicit filter',
      RestrictionType.shortForm => 'Short-form limit',
    };
    final limit = restriction.limitMinutes != null ? '${restriction.limitMinutes} min/day' : 'No cap';
    return '$typeLabel • $limit';
  }

  Future<void> _showAddRestrictionDialog(BuildContext context) async {
    RestrictionType selectedType = RestrictionType.appLimit;
    final titleController = TextEditingController();
    final limitController = TextEditingController(text: '30');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add restriction'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<RestrictionType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: RestrictionType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(_subtitleForType(type)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedType = value);
                        }
                      },
                    ),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Label'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Enter a label' : null,
                    ),
                    if (selectedType != RestrictionType.explicitContent)
                      TextFormField(
                        controller: limitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Daily limit (minutes)'),
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
                      final limit = selectedType == RestrictionType.explicitContent
                          ? null
                          : int.tryParse(limitController.text.trim());
                      context.read<AppDataProvider>().addRestriction(
                            type: selectedType,
                            title: titleController.text.trim(),
                            limitMinutes: limit,
                          );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _subtitleForType(RestrictionType type) {
    switch (type) {
      case RestrictionType.appLimit:
        return 'App limit';
      case RestrictionType.explicitContent:
        return 'Explicit filter';
      case RestrictionType.shortForm:
        return 'Short-form limit';
    }
  }
}

class _EmptyRestrictions extends StatelessWidget {
  const _EmptyRestrictions({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No safeguards yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Create app limits or filters to protect your focus.'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add restriction'),
            ),
          ],
        ),
      ),
    );
  }
}
