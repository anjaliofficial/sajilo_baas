import 'package:flutter/material.dart';
import './bottom_screens/guests_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color primaryBlue = const Color(0xFF007BFF);
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: _buildHeader(),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 30),
            _buildSectionHeader(
              title: 'Nearby your location',
              actionText: 'See all',
            ),
            const SizedBox(height: 15),
            _buildNearbyPropertyCard(),
            const SizedBox(height: 40),
            _buildSectionHeader(title: 'Popular Destination'),
            const SizedBox(height: 15),
            _buildPopularDestinationList(),
          ],
        ),
      ),

      // ✅ Using extracted Bottom Nav
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Navigation logic (later you can route pages)
          // Example:
          // if (index == 1) Navigator.push(...)
        },
      ),
    );
  }

  // ---------------- UI BUILDERS ----------------

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current location',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 18),
                Text(
                  'Kathmandu, Pepsicola',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_none, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Start Your Search',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, String? actionText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (actionText != null)
          Text(actionText, style: TextStyle(color: primaryBlue)),
      ],
    );
  }

  Widget _buildNearbyPropertyCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: Colors.blue.shade100,
            ),
            child: Image.asset(
              'assets/images/shreshaApartment.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Shreshna Apartment\nNagarkot, Bhaktapur\nRENT - 20K/Day',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDestinationList() {
    return Column(
      children: [
        _buildPopularDestinationItem(
          title: 'SindhuPalchock',
          address: 'Helambu 34, Sindhupalchock',
          rent: '5.5K',
        ),
        TextButton(
          onPressed: () {},
          child: Text('NEXT', style: TextStyle(color: primaryBlue)),
        ),
      ],
    );
  }

  Widget _buildPopularDestinationItem({
    required String title,
    required String address,
    required String rent,
  }) {
    return Row(
      children: [
        Image.asset(
          'assets/images/SindhupalchockImageIndashbaord.jpg',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(address, style: const TextStyle(color: Colors.grey)),
              Text('RENT - $rent'),
            ],
          ),
        ),
      ],
    );
  }
}
