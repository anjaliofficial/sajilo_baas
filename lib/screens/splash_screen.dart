import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Colors.blue.shade700;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // --- Top Section: Logo ---
              _buildLogo(primaryBlue),
              const Spacer(flex: 1),

              // --- Middle Section: Image Grid (Simplified) ---
              _buildImageCollagePlaceholder(primaryBlue),
              const Spacer(flex: 2),

              // --- Text and Button Section ---
              Column(
                children: <Widget>[
                  const Text(
                    "Let's Find Your Sweet & Favorite Place",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Get the opportunity to claim their true dream of at an affordable price",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the Login Page
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Let's Go",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildLogo(Color primaryBlue) {
    // Placeholder for the custom logo (SB icon)
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.green, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        'SB',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: primaryBlue,
        ),
      ),
    );
  }

  Widget _buildImageCollagePlaceholder(Color primaryBlue) {
    // Simplified Stack to replicate the circular overlapping images
    return SizedBox(
      height: 300,
      width: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center Placeholder (House)
          Positioned(
            child: _buildImageCircle(size: 180, color: Colors.teal.shade100),
          ),
          // Top Left
          Positioned(
            top: 20,
            left: 0,
            child: _buildImageCircle(size: 100, color: Colors.blue.shade100),
          ),
          // Bottom Right
          Positioned(
            bottom: 10,
            right: 10,
            child: _buildImageCircle(size: 120, color: Colors.orange.shade100),
          ),
          // Center-Right
          Positioned(
            top: 100,
            right: 0,
            child: _buildImageCircle(size: 80, color: Colors.purple.shade100),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
    );
  }
}
