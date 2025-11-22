import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  const ResponsiveScaffold({
    Key? key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
  }) : super(key: key);

  bool get isMobile => true; // Replace with actual logic if needed

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    if (isMobile) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations,
        ),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: d.icon,
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }
  }
} 