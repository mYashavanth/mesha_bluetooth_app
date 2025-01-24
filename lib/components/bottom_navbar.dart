import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex; // Active page index
  final Function(int) onTap; // Callback for navigation

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Current selected index
      onTap: onTap, // Handle navigation
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Colors.blue, // Color of the selected item
      unselectedItemColor: Colors.grey, // Color of the unselected items
      showUnselectedLabels: true, // Show labels for unselected items
    );
  }
}
