import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mummymap/firebase_options.dart';
import 'package:mummymap/router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mummymap/services/onesignal_service.dart';
import 'package:mummymap/services/sync_service.dart';
import 'package:mummymap/domain/repositories/auth_repository.dart';
import 'package:mummymap/presentation/providers/notification_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final OneSignalService oneSignalService = OneSignalService();

Future<void> initializeNotifications() async {
    await oneSignalService.initialize();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('shop_box');
  await Hive.openBox<String>('articles_box');
  await Hive.openBox<String>('groups_box');
  await Hive.openBox<String>('weight_track_box');
  await Hive.openBox<String>('exercises_box');
  await Hive.openBox<String>('calendar_box');
  await Hive.openBox<String>('mood_box');

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

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _registeredToken = '';

  @override
  void initState() {
    super.initState();
    ref.read(syncServiceProvider);
    _setupPushSubscriptionObserver();
  }

  bool _isRegistered(String? id) =>
      id != null && id.isNotEmpty && !id.startsWith('local-');

  String get _platform {
    if (kIsWeb) return 'WEB';
    if (Platform.isIOS) return 'IOS';
    if (Platform.isAndroid) return 'ANDROID';
    return 'WEB';
  }

  void _setupPushSubscriptionObserver() {
    oneSignalService.addPushSubscriptionObserver((id) {
      _maybeRegisterDeviceToken(id);
    });
    _maybeRegisterDeviceToken(oneSignalService.subscriptionId);
  }

  Future<void> _maybeRegisterDeviceToken(String? id) async {
    if (!_isRegistered(id) || id == _registeredToken) return;
    final isLoggedIn =
        await _storage.read(key: AuthStorageKeys.isLoggedIn) == 'true';
    if (!isLoggedIn || !mounted) return;
    try {
      await ref
          .read(notificationRepositoryProvider)
          .registerDeviceToken(token: id!, platform: _platform);
      _registeredToken = id;
    } catch (_) {
      // Token registration will be retried on the next subscription change.
    }
  }

  @override
  Widget build(BuildContext context) {
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