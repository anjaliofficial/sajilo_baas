import 'package:flutter/material.dart';
import 'package:sajilo_baas/screens/booking_screen.dart';
import 'package:sajilo_baas/screens/dashboard_screen.dart';
import 'package:sajilo_baas/screens/favroites_screen.dart';
import 'package:sajilo_baas/screens/message_screen.dart';
import 'package:sajilo_baas/screens/profile_screen.dart';
// import '../dashboard/dashboard_screen.dart';
// import '../messages/message_screen.dart';
// import '../favorites/favorites_screen.dart';
// import '../bookings/booking_screen.dart';
// import '../profile/profile_screen.dart';
import 'app_bottom_navbar.dart';

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
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
