import 'package:flutter/material.dart';
import 'package:mesha_bluetooth_data_retrieval/views/home_bluetooth.dart';
import 'package:mesha_bluetooth_data_retrieval/components/bottom_navbar.dart';
import 'package:mesha_bluetooth_data_retrieval/views/profile.dart';
import 'package:mesha_bluetooth_data_retrieval/views/reports.dart';

class Navigation extends StatefulWidget {
  final int currentIndex;
  const Navigation({
    required this.currentIndex,
    super.key,
  });

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  late int _currentIndex; // Active page index

  // List of pages
  final List<Widget> _pages = [
    BluetoothDeviceManager(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the current page
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the active page index
          });
        },
      ),
    );
  }
}
