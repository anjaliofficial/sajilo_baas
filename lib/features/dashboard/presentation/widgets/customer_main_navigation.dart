import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/booking/presentation/providers/booking_providers.dart';
import 'package:sajilo_baas/features/dashboard/presentation/pages/messages_screen.dart';

import 'app_bottom_navbar.dart';
import '../pages/dashboard_page.dart';
import '../pages/favorites_page.dart';
import '../pages/bookings_page.dart';
// import '../../message/presentation/pages/Threads page.dart';
import '../pages/profile_screen.dart';

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
      MessagesScreen(), // from Threads page.dart
      FavoritesScreen(),
      BookingsScreen(),
      ProfileScreen(),
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
