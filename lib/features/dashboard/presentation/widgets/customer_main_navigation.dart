import 'package:flutter/material.dart';
// import 'package:sajilo_baas/screens/booking_screen.dart';
// import 'package:sajilo_baas/screens/favroites_screen.dart';
// import 'package:sajilo_baas/screens/hosts/hosts_dashboard_screen.dart';
// import 'package:sajilo_baas/screens/message_screen.dart';
// import 'package:sajilo_baas/screens/profile_screen.dart';
import 'app_bottom_navbar.dart';
import '../pages/dashboard_page.dart';

class CustomerMainNavigation extends StatefulWidget {
  const CustomerMainNavigation({super.key});

  @override
  State<CustomerMainNavigation> createState() => _CustomerMainNavigationState();
}

class _CustomerMainNavigationState extends State<CustomerMainNavigation> {
  int _currentIndex = 0;

  // Remove 'const' because some screens might use providers or runtime data
  final List<Widget> _pages = [
    DashboardScreen(),
    // MessagesScreen(),
    // FavoritesScreen(),
    // BookingsScreen(),
    // ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final safeIndex = (_currentIndex < _pages.length) ? _currentIndex : 0;
    return Scaffold(
      body: _pages[safeIndex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: safeIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
