import 'package:flutter/material.dart';

import '../bottom_screens/guests_nav_bar.dart';
import '../dashboard_screen.dart';
import '../message_screen.dart';
import '../favroites_screen.dart';
import '../booking_screen.dart';
import '../profile_screen.dart';

class CustomerMainNavigation extends StatefulWidget {
  const CustomerMainNavigation({super.key});

  @override
  State<CustomerMainNavigation> createState() => _CustomerMainNavigationState();
}

class _CustomerMainNavigationState extends State<CustomerMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    MessagesScreen(),
    FavoritesScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
