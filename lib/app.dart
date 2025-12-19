import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/obboarding_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';

// Navigation controllers
import 'screens/guests/main_navigation.dart';
import 'screens/hosts/host_main_navigation_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      initialRoute: '/splash',
      routes: {
        '/': (context) => const SplashScreen(),
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),

        // ✅ Bottom Navigation Entrypoints
        '/customer': (context) => const CustomerMainNavigation(),
        '/host': (context) =>
            const HostMainNavigationScreen(), // corrected here
      },
    );
  }
}
