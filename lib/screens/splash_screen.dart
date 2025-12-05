import 'package:flutter/material.dart';

// Note: This file assumes the necessary navigation routes (like '/onboarding')
// are defined in the parent MaterialApp/context.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Defined a specific blue color for consistency
    final Color primaryBlue = Colors.blue.shade700;
    const Color buttonColor = Color(0xFF2196F3); // Consistent Blue

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Spacer(flex: 1),

              // --- Top Section: Logo ---
              _buildLogo(primaryBlue),
              const Spacer(flex: 2),

              // --- Middle Section: Image Grid (Simplified) ---
              _buildImageCollagePlaceholder(primaryBlue),
              const Spacer(flex: 3),

              // --- Text and Button Section ---
              Column(
                children: <Widget>[
                  const Text(
                    "Let's Find Your Sweet & Favorite Place",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Get the opportunity to claim their true dream of at an affordable price",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the Onboarding Screen using named route
                        Navigator.of(
                          context,
                        ).pushReplacementNamed('/onboarding');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        elevation: 5,
                        shadowColor: buttonColor.withOpacity(0.5),
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
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for the logo
  Widget _buildLogo(Color primaryBlue) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'SB',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  // Helper function for the image collage placeholder
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
            child: _buildImageCircle(
              size: 180,
              icon: Icons.home_rounded,
              color: Colors.teal.shade100,
              iconColor: primaryBlue,
            ),
          ),
          // Top Left
          Positioned(
            top: 20,
            left: 0,
            child: _buildImageCircle(
              size: 100,
              icon: Icons.apartment,
              color: Colors.blue.shade100,
              iconColor: primaryBlue,
            ),
          ),
          // Bottom Right
          Positioned(
            bottom: 10,
            right: 10,
            child: _buildImageCircle(
              size: 120,
              icon: Icons.location_city,
              color: Colors.orange.shade100,
              iconColor: primaryBlue,
            ),
          ),
          // Center-Right
          Positioned(
            top: 100,
            right: 0,
            child: _buildImageCircle(
              size: 80,
              icon: Icons.map,
              color: Colors.purple.shade100,
              iconColor: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function for building a circular element
  Widget _buildImageCircle({
    required double size,
    required Color color,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.4, color: iconColor),
    );
  }
}
