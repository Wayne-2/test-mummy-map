import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/firebase_options.dart';
import 'package:mummymap/router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> initializeNotifications() async {
    OneSignal.initialize("eebc8cfe-8173-4bdd-9c23-f2b79585ca65");
  
    await OneSignal.Notifications.requestPermission(true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('shop_box');
  await Hive.openBox<String>('articles_box');
  await Hive.openBox<String>('groups_box');
  await Hive.openBox<String>('weight_track_box');
  await Hive.openBox<String>('exercises_box');

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const _FriendlyErrorScreen();
  };

  

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeNotifications();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _FriendlyErrorScreen extends StatelessWidget {
  const _FriendlyErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh_rounded,
                  size: 56, color: Color(0xFFBDBDBD)),
              const SizedBox(height: 20),
              const Text(
                'Something needs a refresh',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This part of the screen ran into a problem. Please go back and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Color(0xFF9E9E9E), height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}