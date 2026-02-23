import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/booking/presentation/providers/booking_providers.dart';

import 'app_bottom_navbar.dart';
import '../pages/dashboard_page.dart';
import '../pages/favorites_page.dart';
import '../pages/bookings_page.dart';

class CustomerMainNavigation extends ConsumerStatefulWidget {
  const CustomerMainNavigation({super.key});

  @override
  ConsumerState<CustomerMainNavigation> createState() =>
      _CustomerMainNavigationState();
}

class _CustomerMainNavigationState
    extends ConsumerState<CustomerMainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(),
      // Placeholder for MessagesScreen
      Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: Text('Messages will appear here')),
      ),
      FavoritesScreen(),
      BookingsScreen(),
      // Placeholder for ProfileScreen
      Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Profile details will appear here')),
      ),
    ];

    final safeIndex = (_currentIndex < pages.length) ? _currentIndex : 0;
    return Scaffold(
      body: pages[safeIndex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: safeIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Force refresh bookings when Bookings tab is tapped
          if (index == 3) {
            ref.read(bookingViewModelProvider.notifier).loadBookings();
          }
        },
      ),
    );
  }
}
