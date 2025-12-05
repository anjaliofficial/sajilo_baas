import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/splash_screen.dart'; // New Import
import 'screens/onboarding_screen.dart'; // New Import

// --- PLACEHOLDER SCREENS for demonstration ---
// These are kept here for now, as in your previous file.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Welcome to the Dashboard!')),
    );
  }
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: const Center(child: Text('Sign Up Screen')),
    );
  }
}
// ---------------------------------------------

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBook App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Define all named routes used in the application
      routes: {
        '/': (context) => const SplashScreen(), // Changed to start here
        '/splash': (context) => const SplashScreen(), // New route
        '/onboarding': (context) => const OnboardingScreen(), // New route
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const DashboardScreen(),
      },
      initialRoute: '/splash', // Start the app on the splash screen
    );
  }
}
