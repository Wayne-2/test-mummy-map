import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mummymap/domain/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    const storage = FlutterSecureStorage();
    final refreshToken =
        await storage.read(key: AuthStorageKeys.refreshToken);
    final hasSession = refreshToken != null && refreshToken.isNotEmpty;

    final prefs = await SharedPreferences.getInstance();
    final hasCompletedSetup =
        prefs.getBool('has_completed_setup') ?? false;

    if (!mounted) return;

    if (!hasSession) {
      context.go('/get-started');
      return;
    }

    try {
      await ref.read(profileRepositoryProvider).getMyProfile();
      await prefs.setBool('has_completed_setup', true);
      if (!mounted) return;
      context.go('/home');
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response?.statusCode == 404) {
        context.go('/profile-setup');
      } else {
        if (hasCompletedSetup) {
          context.go('/home');
        } else {
          context.go('/profile-setup');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3F2868),
      body: Center(
        child: Image.asset('assets/firstlogo.png', width: 180, height: 180),
      ),
    );
  }
}