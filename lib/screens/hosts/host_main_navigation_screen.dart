import 'package:flutter/material.dart';
import '../bottom_screens/guests_nav_bar.dart';
import '../hosts/hosts_dashboard_screen.dart';
import '../hosts/message_page.dart';
import '../hosts/all_properties_page.dart';
import '../hosts/bookings_page.dart';
import '../hosts/profile_page.dart';

class HostMainNavigationScreen extends StatefulWidget {
  const HostMainNavigationScreen({super.key});

  @override
  State<HostMainNavigationScreen> createState() =>
      _HostMainNavigationScreenState();
}

class _HostMainNavigationScreenState extends State<HostMainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HostDashboard(),
    HostMessagesPage(), // previously HostMessagesScreen
    AllPropertiesPage(), // previously HostPropertiesScreen
    BookingsPage(), // previously HostBookingsScreen
    ProfilePage(), // previously HostProfileScreen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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
