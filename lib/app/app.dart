import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/auth/presentation/pages/login_page.dart';
import 'package:sajilo_baas/features/message/presentation/pages/chat_page.dart';
import 'package:sajilo_baas/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:sajilo_baas/features/splash/presentation/pages/splash_screen.dart';
import 'package:sajilo_baas/features/auth/presentation/pages/register_page.dart';
import 'package:sajilo_baas/features/dashboard/presentation/widgets/customer_main_navigation.dart';
import 'package:sajilo_baas/core/utils/navigator_key.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SmartBook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      navigatorKey: navigatorKey,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const RegisterPage(),
        '/dashboard': (context) => const CustomerMainNavigation(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ChatPage(
              otherUserId: args['hostId'],
              listingId: args['listingId'],
            ),
          );
        }
        return null;
      },
      builder: (context, child) {
        // You can do global widgets here if needed
        return child!;
      },
    );
  }
}
