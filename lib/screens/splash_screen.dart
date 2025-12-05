import 'package:flutter/material.dart';

// Import the next screen (e.g., the Login Page)
// import 'login_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // Placeholder for the custom logo and grid images
  // In a real app, you would load these from your assets folder.
  final String _appLogo = 'assets/logo.png';
  final List<String> _imageAssets = const [
    'assets/house1.jpg',
    'assets/house2.jpg',
    'assets/house3.jpg',
    'assets/house4.jpg',
    'assets/house5.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // --- Top Section: Logo ---
              Image.asset(_appLogo, height: 80),

              // --- Middle Section: Image Grid ---
              // This is a simplified representation of your circular image layout
              _buildImageGrid(),

              // --- Text and Button Section ---
              Column(
                children: <Widget>[
                  const Text(
                    "Let's Find Your Sweet & Favorite Place",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Get the opportunity to claim their true dream of at an affordable price",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the next screen
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Let's Go",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    // This is a simplified container. For the exact circular/overlapping design,
    // you would need a more complex layout, likely using the 'Stack' widget
    // with specific positioning and 'ClipOval' for each image.
    return Container(
      height: 250,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        "Image Collage Placeholder\n(Use Stack & ClipOval for design)",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
