import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/auth/presentation/pages/login_page.dart';

// Data model for onboarding content
class OnboardContent {
  final String title;
  final String description;

  OnboardContent({required this.title, required this.description});
}

// Onboarding slides data
final List<OnboardContent> contents = [
  OnboardContent(
    title: "Find Your Perfect Home",
    description:
        "Browse thousands of verified listings tailored to your preferences and budget in any city.",
  ),
  OnboardContent(
    title: "Secure & Easy Booking",
    description:
        "Book viewings and secure your dream property with our seamless and secure platform.",
  ),
  OnboardContent(
    title: "Expert Advice & Support",
    description:
        "Get assistance from our experienced real estate professionals every step of the way, 24/7.",
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _controller = PageController();
  final Color accentColor = Color(0xFF2196F3); // Splash screen blue
  final Color iconBgColor = Colors.blue.shade50;

  void _handleNext() {
    if (currentPage == contents.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Always visible Skip button
            Positioned(
              top: 40,
              right: 30,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  elevation: 5,
                  shadowColor: accentColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Main onboarding content
            Column(
              children: [
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: contents.length,
                    onPageChanged: (index) =>
                        setState(() => currentPage = index),
                    itemBuilder: (_, i) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 80,
                          left: 30,
                          right: 30,
                          bottom: 20,
                        ),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                              height: 180,
                              width: 180,
                              decoration: BoxDecoration(
                                color: iconBgColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(child: _getOnboardingIcon(i)),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              contents[i].title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              contents[i].description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Bottom Section
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        // DOTS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            contents.length,
                            (index) => _buildDot(index),
                          ),
                        ),
                        const Spacer(),
                        // BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _handleNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              elevation: 5,
                              shadowColor: accentColor.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              currentPage == contents.length - 1
                                  ? "Get Started"
                                  : "Next",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Get icon for each onboarding slide
  Widget _getOnboardingIcon(int index) {
    switch (index) {
      case 0:
        return Icon(Icons.home_rounded, size: 80, color: accentColor);
      case 1:
        return Icon(Icons.lock_rounded, size: 80, color: accentColor);
      case 2:
        return Icon(Icons.support_agent, size: 80, color: accentColor);
      default:
        return Icon(Icons.location_city, size: 80, color: accentColor);
    }
  }

  // DOT indicator
  AnimatedContainer _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: currentPage == index ? accentColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
