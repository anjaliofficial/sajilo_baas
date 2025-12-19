import 'package:flutter/material.dart';

// ---------------- DASHBOARD SCREEN ----------------
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final Color primaryBlue = const Color(0xFF007BFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: _buildHeader(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 30),
            _buildSectionHeader(
              context: context,
              title: 'Nearby your location',
              actionText: 'See all',
              onActionTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NearbyPage()),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildNearbyPropertyList(),
            const SizedBox(height: 40),
            _buildSectionHeader(title: 'Popular Destination', context: context),
            const SizedBox(height: 15),
            _buildPopularDestinationList(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
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
                Icon(Icons.location_on, size: 18, color: Colors.black),
                SizedBox(width: 4),
                Text(
                  'Kathmandu, Pepsicola',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
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

  // ================= SEARCH BAR =================
  Widget _buildSearchBar() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Start Your Search',
        hintStyle: const TextStyle(color: Colors.grey),
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryBlue),
        ),
      ),
    );
  }

  // ================= SECTION HEADER =================
  Widget _buildSectionHeader({
    required String title,
    String? actionText,
    VoidCallback? onActionTap,
    required BuildContext context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: 14,
                color: primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // ================= NEARBY PROPERTY LIST =================
  Widget _buildNearbyPropertyList() {
    final List<Map<String, String>> nearbyList = [
      {
        'name': 'Shreshna Apartment',
        'location': 'Nagarkot, Bhaktapur',
        'rent': '20K/Day',
        'image': 'assets/images/shreshaApartment.jpeg',
      },
      {
        'name': 'Himalaya Residence',
        'location': 'Bhaktapur, Kathmandu',
        'rent': '18K/Day',
        'image': 'assets/images/himalayan.jpeg',
      },
      {
        'name': 'Peace Villa',
        'location': 'Lalitpur, Kathmandu',
        'rent': '22K/Day',
        'image': 'assets/images/peacevilla.jpeg',
      },
    ];

    return Column(
      children: nearbyList.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildNearbyPropertyCard(
            name: item['name']!,
            location: item['location']!,
            rent: item['rent']!,
            image: item['image']!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNearbyPropertyCard({
    required String name,
    required String location,
    required String rent,
    required String image,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    SizedBox(width: 4),
                    Text('5.0', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(location, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text: 'RENT - ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: rent,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= POPULAR DESTINATION =================
  Widget _buildPopularDestinationList(BuildContext context) {
    final List<Map<String, String>> popularList = [
      {
        'title': 'Sindhupalchok',
        'address': 'Helambu 34, Sindhupalchok',
        'rent': '5.5K',
        'image': 'assets/images/SindhupalchockImageIndashbaord.jpg',
      },
      {
        'title': 'Nagarkot Hills',
        'address': 'Nagarkot, Bhaktapur',
        'rent': '6K',
        'image': 'assets/images/nagarkothills.jpg',
      },
      {
        'title': 'Bhaktapur Old Town',
        'address': 'Bhaktapur, Kathmandu',
        'rent': '7K',
        'image': 'assets/images/bhaktapurOldVibe.jpg',
      },
    ];

    return Column(
      children: [
        ...popularList.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildPopularDestinationItem(
              title: item['title']!,
              address: item['address']!,
              rent: item['rent']!,
              image: item['image']!,
            ),
          );
        }).toList(),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PopularDestinationPage(),
              ),
            );
          },
          child: Text(
            'NEXT',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularDestinationItem({
    required String title,
    required String address,
    required String rent,
    required String image,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'RENT - ',
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: rent,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(address, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Row(
                children: List.generate(
                  5,
                  (index) =>
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- NEARBY PAGE ----------------
class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Properties')),
      body: const Center(child: Text('Nearby Properties List Page')),
    );
  }
}

// ---------------- POPULAR DESTINATION PAGE ----------------
class PopularDestinationPage extends StatelessWidget {
  const PopularDestinationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Destinations')),
      body: const Center(child: Text('Popular Destinations List Page')),
    );
  }
}
