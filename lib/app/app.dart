import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/auth/presentation/pages/login_page.dart';
import 'package:sajilo_baas/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:sajilo_baas/features/splash/presentation/pages/splash_screen.dart';
import 'package:sajilo_baas/screens/guests/main_navigation.dart';
import 'package:sajilo_baas/screens/signup_page.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SmartBook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const CustomerMainNavigation(),
      },
      builder: (context, child) {
        // You can do global widgets here if needed
        return child!;
      },
    );
  }
}
