import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sajilo_baas/features/auth/presentation/pages/login_page.dart';
import 'package:sajilo_baas/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:sajilo_baas/features/splash/presentation/pages/splash_screen.dart';
import 'package:sajilo_baas/screens/guests/main_navigation.dart';
import 'package:sajilo_baas/screens/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Open boxes for onboarding & auth
  await Hive.openBox('onboardingBox');
  await Hive.openBox('authBox');

  runApp(const App());
}

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
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const CustomerMainNavigation(),
      },
    );
  }
}
