import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Colors.blue.shade700;
    const Color buttonColor = Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Spacer(flex: 1),

              _buildLogo(),

              const Spacer(flex: 2),

              _buildImageCollagePlaceholder(primaryBlue),

              const Spacer(flex: 3),

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
                      "Get the opportunity to claim your dream property at an affordable price",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed('/onboarding'),
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

  // LOGO
  Widget _buildLogo() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.asset(
        'assets/images/logo.png',
        height: 200,
        width: 200,
        fit: BoxFit.cover,
      ),
    );
  }

  // IMAGE COLLAGE
  Widget _buildImageCollagePlaceholder(Color primaryBlue) {
    return SizedBox(
      height: 300,
      width: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: _buildImageCircle(
              size: 180,
              icon: Icons.home_rounded,
              color: Colors.teal.shade100,
              iconColor: primaryBlue,
            ),
          ),
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
