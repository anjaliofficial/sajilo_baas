import 'package:flutter/material.dart';

// --- Data Model for Onboarding Content (Integrated) ---

class ObboardContent {
  final String title;
  final String description;
  // Note: Since only Icon placeholders are used, the image field is omitted.
  ObboardContent({required this.title, required this.description});
}

// Dummy data for the three onboarding slides
List<ObboardContent> contents = [
  ObboardContent(
    title: "Find Your Perfect Home",
    description:
        "Browse thousands of verified listings tailored to your preferences and budget in any city.",
  ),
  ObboardContent(
    title: "Secure & Easy Booking",
    description:
        "Book viewings and secure your dream property with our seamless and secure platform.",
  ),
  ObboardContent(
    title: "Expert Advice & Support",
    description:
        "Get assistance from our experienced real estate professionals every step of the way, 24/7.",
  ),
];

// --- Onboarding Screen Widget ---

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _controller = PageController();
  final Color primaryBlue = Colors.blue.shade700;

  // Function to handle the button press (Next/Get Started)
  void _handleNext() {
    if (currentPage == contents.length - 1) {
      // Last page: Navigate to the Login Screen using the named route
      // Assumes '/login' is defined in the MaterialApp routes.
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      // Not last page: Go to the next slide
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- PageView (Slidable Content) ---
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.only(
                    top: 100.0,
                    left: 40.0,
                    right: 40.0,
                    bottom: 20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Image Placeholder
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
                          Icons.location_city, // Placeholder icon
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          contents[i].description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // --- Bottom Navigation (Dots and Button) ---
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 40.0,
              ),
              child: Column(
                children: [
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const Spacer(),
                  // Next/Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        elevation: 5,
                        shadowColor: primaryBlue.withOpacity(0.5),
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
    );
  }

  // Helper function for building the animated dot indicator
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
