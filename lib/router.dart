import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mummymap/domain/repositories/auth_repository.dart';
import 'package:mummymap/presentation/pages/intro/splashscreen.dart';
import 'package:mummymap/presentation/pages/intro/onboardingscreen.dart';
import 'package:mummymap/presentation/pages/intro/getstarted.dart';
import 'package:mummymap/presentation/pages/auth/signin.dart';
import 'package:mummymap/presentation/pages/auth/signup.dart';
import 'package:mummymap/presentation/pages/auth/forgot_password.dart';
import 'package:mummymap/presentation/pages/auth/verify_otp.dart';
import 'package:mummymap/presentation/pages/profile_setup/profile_setup.dart';
import 'package:mummymap/presentation/pages/mainnav/main_nav.dart';
import 'package:mummymap/presentation/pages/side/settings/settings_screen.dart';
import 'package:mummymap/main.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    redirect: (context, state) async {
      const storage = FlutterSecureStorage();
      final refreshToken =
          await storage.read(key: AuthStorageKeys.refreshToken);
      final loggedIn = refreshToken != null && refreshToken.isNotEmpty;
      final location = state.matchedLocation;
      // Public routes that don't require auth
      const publicRoutes = [
        '/',
        '/onboarding',
        '/get-started',
        '/signin',
        '/signup',
        '/verify-otp',
        '/forgot-password',
      ];
      const authRoutes = [
        '/signin',
        '/signup',
        '/get-started',
        '/onboarding',
        '/verify-otp',
        '/forgot-password',
      ];
      // Splash handles initial routing; don't redirect from '/'
      if (location == '/') return null;
      if (!loggedIn && !publicRoutes.contains(location)) {
        return '/signin';
      }
      if (loggedIn && authRoutes.contains(location)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/get-started',
        builder: (context, state) => const Getstarted(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignIn(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUp(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return VerifyOtp(
            email: extra['email'] as String? ?? '',
            password: extra['password'] as String? ?? '',
            isSignup: extra['isSignup'] as bool? ?? true,
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPassword(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetup(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNav(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
