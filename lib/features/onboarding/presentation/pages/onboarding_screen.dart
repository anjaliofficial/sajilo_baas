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
  final Color primaryBlue = Colors.blue;

  void _handleNext() {
    if (currentPage == contents.length - 1) {
      Navigator.of(context).pushReplacementNamed('/login');
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
      body: Stack(
        children: [
          // Only show Skip button on first onboarding page
          if (currentPage == 0)
            Positioned(
              top: 40,
              right: 30,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

          // Main onboarding content
          IgnorePointer(
            ignoring: currentPage == 0,
            child: Column(
              children: [
                // PAGEVIEW
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
                          top: 100,
                          left: 40,
                          right: 40,
                          bottom: 20,
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 250,
                              width: 250,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.location_city,
                                size: 100,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 50),
                            Text(
                              contents[i].title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1D2939),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              contents[i].description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
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
                              backgroundColor: primaryBlue,
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
          ),
        ],
      ),
    );
  }

  // DOT indicator
  AnimatedContainer _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: currentPage == index ? primaryBlue : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
