import 'package:flutter/material.dart';

class AppNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;

  const AppNavigation({
    Key? key,
    required this.currentIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For TV interfaces, make the navigation larger and more visible
    final isTv = MediaQuery.of(context).size.width >= 1920;
    final iconSize = isTv ? 36.0 : 24.0;
    final labelSize = isTv ? 20.0 : 12.0;

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      minWidth: isTv ? 120 : 72,
      minExtendedWidth: isTv ? 200 : 150,
      groupAlignment: 0.0,
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.home, size: iconSize),
          label: Text('Home', style: TextStyle(fontSize: labelSize)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings, size: iconSize),
          label: Text('Settings', style: TextStyle(fontSize: labelSize)),
        ),
      ],
    );
  }
}
