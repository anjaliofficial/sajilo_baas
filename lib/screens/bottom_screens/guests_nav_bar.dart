import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/dashboard/presentation/widgets/app_bottom_navbar.dart';
import 'package:sajilo_baas/features/profile/presentation/pages/profile_page.dart';
import 'package:sajilo_baas/features/profile/presentation/providers/profile_provider.dart';

import '../dashboard_screen.dart';
import '../message_screen.dart';
import '../favroites_screen.dart';
import '../booking_screen.dart';

class CustomerMainNavigation extends ConsumerStatefulWidget {
  const CustomerMainNavigation({super.key});

  @override
  ConsumerState<CustomerMainNavigation> createState() =>
      _CustomerMainNavigationState();
}

class _CustomerMainNavigationState
    extends ConsumerState<CustomerMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    MessagesScreen(),
    FavoritesScreen(),
    BookingsScreen(),
    ProfileScreen(), // ✅ Profile tab
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // ✅ Trigger profile fetch when Profile tab is selected
          if (index == 4) {
            ref.read(profileViewModelProvider.notifier).fetchProfile();
          }
        },
      ),
    );
  }
}
