import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/splash_screen.dart';
import 'screens/obboarding_page.dart';
import 'screens/signup_page.dart';
import 'screens/dashboard_screen.dart';
import 'screens/hosts/hosts_dashboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBook App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routes: {
        '/': (context) => const SplashScreen(),
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const DashboardScreen(),
        '/hosts_dashboard_screen': (context) => const HostDashboard(),
      },
      initialRoute: '/hosts_dashboard_screen',
    );
  }
}
