import 'package:flutter/material.dart';
import 'app_navigation.dart';

class TvLayout extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final Widget child;

  const TvLayout({
    Key? key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppNavigation(
            currentIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
          ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: const Text('VandCloud'),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
