import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(child: Text('DisciPlan')),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text('Home'),
                  onTap: null, // Navigation handled by GoRouter
                ),
                ListTile(
                  title: Text('Planner'),
                  onTap: null,
                ),
                ListTile(
                  title: Text('Monthly Planner'),
                  onTap: null,
                ),
                ListTile(
                  title: Text('Tasks'),
                  onTap: null,
                ),
                ListTile(
                  title: Text('Habits'),
                  onTap: null,
                ),
                ListTile(
                  title: Text('Screen Time'),
                  onTap: null,
                ),
                ListTile(
                  title: Text('Restrictions'),
                  onTap: null,
                ),
                ListTile(
                  title: Text('Progress'),
                  onTap: null,
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.brightness_6),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (val) => themeProvider.toggleTheme(),
            ),
          ),
        ],
      ),
    );
  }
} 