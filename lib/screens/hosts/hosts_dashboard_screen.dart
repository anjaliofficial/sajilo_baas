import 'package:flutter/material.dart';

import 'all_properties_page.dart';
import 'bookings_page.dart';
import 'profile_page.dart';
import 'message_page.dart';

import '../bottom_screens/host_nav_bar.dart';

class HostDashboard extends StatefulWidget {
  const HostDashboard({super.key});

  @override
  State<HostDashboard> createState() => _HostDashboardState();
}

class _HostDashboardState extends State<HostDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(), // Dashboard content
    const HostMessagesPage(),
    const AllPropertiesPage(),
    const BookingsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: HostBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ================= Dashboard Content =================
class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});
  final Color primaryBlue = const Color(0xFF007BFF);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hello, Anjali',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/peacevilla.jpeg'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  'Total Properties',
                  '5',
                  Colors.lightBlue.shade100,
                ),
                _buildStatCard('Active Bookings', '8', Colors.green.shade100),
                _buildStatCard('Pending Requests', '3', Colors.orange.shade100),
              ],
            ),
            const SizedBox(height: 20),

            // Action Required
            const Text(
              'Action Required (3)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 10),
            _buildActionCard(
              'Maintenance',
              'Leaky faucet in Shreshna Apartment',
            ),

            const SizedBox(height: 20),
            // My Properties
            const Text(
              'My Properties',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPropertyCard(
              'Shreshna Apartment',
              'Nagarkot, Bhaktapur',
              '+List Property',
            ),
            const SizedBox(height: 10),
            _buildPropertyCard(
              'Thamel House',
              'Fully occupied (2/2 units)',
              'Rs.10,000 Due\nRs.1,000 Due',
            ),

            const SizedBox(height: 20),
            // Recent Bookings
            const Text(
              'Recent Bookings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildBookingCard(
              guestName: 'Sita Sharma',
              property: 'Shreshna Apartment',
              date: 'Dec 20 - Dec 22',
            ),
            const SizedBox(height: 10),
            _buildBookingCard(
              guestName: 'Ram Thapa',
              property: 'Thamel House',
              date: 'Dec 18 - Dec 19',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String description) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: description,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              child: const Text('Quick send'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(String title, String subtitle, String info) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              info,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard({
    required String guestName,
    required String property,
    required String date,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guestName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(property, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}
