import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = 'User';
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: AppTheme.glassBox(),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_circle, size: 120, color: AppTheme.primaryColor),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _name,
                          decoration: const InputDecoration(labelText: 'Name'),
                          onSaved: (val) => _name = val ?? '',
                          validator: (val) => val == null || val.isEmpty ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _email,
                          decoration: const InputDecoration(labelText: 'Email'),
                          onSaved: (val) => _email = val ?? '',
                          validator: (val) => val == null || val.isEmpty ? 'Enter your email' : null,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _formKey.currentState?.save();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile saved!')),
                              );
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 