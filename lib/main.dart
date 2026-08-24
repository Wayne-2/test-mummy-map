import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mummymap/firebase_options.dart';
import 'package:mummymap/router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mummymap/services/onesignal_service.dart';
import 'package:mummymap/services/push_notification_service.dart';
import 'package:mummymap/services/sync_service.dart';
import 'package:mummymap/domain/repositories/auth_repository.dart';
import 'package:mummymap/presentation/providers/notification_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final OneSignalService oneSignalService = OneSignalService();
final PushNotificationService pushNotificationService = PushNotificationService();

Future<void> initializeNotifications() async {
  // OneSignal must be initialized after Firebase
  await oneSignalService.initialize();
  await pushNotificationService.initialize();

  // Wire click handlers to global navigator for deep-linking.
  // Both services will forward tapped notification data here.
  oneSignalService.onNotificationClicked = handlePushClick;
  pushNotificationService.onNotificationClicked = handlePushClick;

  if (kDebugMode) debugPrint('[Push] Unified push initialization done');
}

/// Global handler for notification taps (OneSignal + FCM).
/// Decides where to navigate based on payload `category` / `type`.
void handlePushClick(Map<String, dynamic> data) {
  if (kDebugMode) debugPrint('[Push] handlePushClick data=$data');
  final ctx = navigatorKey.currentContext;
  // If app is still launching and context is null, delay slightly and retry.
  if (ctx == null) {
    Future.delayed(const Duration(milliseconds: 800), () => handlePushClick(data));
    return;
  }

  // Extract deep-link category similarly to notification_model
  String rawCategory = '';
  for (final k in ['category', 'type', 'kind']) {
    final v = data[k];
    if (v is String && v.isNotEmpty) {
      rawCategory = v.toLowerCase();
      break;
    }
  }

  // Refresh notification feed so badge/new item appears
  try {
    final container = ProviderScope.containerOf(ctx, listen: false);
    // Best-effort refresh; ignore errors
    unawaited(container.read(notificationProvider.notifier).load(force: true));
  } catch (_) {}

  // For now route to notifications screen for any push, plus try specific routes
  // Use navigator push – go_router initialLocation is guarded but Material navigator works.
  // If specific IDs exist, app can navigate deeper (appointment etc).
  // We use navigatorKey to pushNamed via go_router if available.
  final nav = navigatorKey.currentState;
  if (nav == null) return;

  // Always land on home first if needed, then push specific screen
  // Simple: show SnackBar + go to notifications feed; detailed routing can be enhanced.
  // Keeping it generic ensures no crashes on unknown payloads.
  if (!nav.context.mounted) return;

  // Example routing – extend as backend payloads stabilize
  switch (rawCategory) {
    case 'appointment':
      // Appointment detail needs ID; if none, just open notifications
      if (data['appointmentId'] != null || data['appointment_id'] != null) {
        // Let notifications_screen deep-link handle it – just open notifications
        _safeNavigateToNotifications(nav);
      } else {
        _safeNavigateToNotifications(nav);
      }
      break;
    case 'community':
    case 'group':
      _safeNavigateToNotifications(nav);
      break;
    default:
      _safeNavigateToNotifications(nav);
      break;
  }
}

void _safeNavigateToNotifications(NavigatorState nav) {
  // Best-effort: if already on notifications, no-op. Otherwise push via go_router if available.
  // We use a SnackBar as visible feedback that push was received when app is open.
  try {
    final ctx = nav.context;
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(content: Text('New notification received')),
    );
  } catch (_) {}
  // Navigation is optional – user can tap bell icon. Keeping automatic navigation minimal
  // to avoid disrupting current flow. Uncomment to auto-open notifications:
  // try { GoRouter.of(nav.context).push('/notifications'); } catch(_) {}
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
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    ref.read(syncServiceProvider);
    _setupPushSubscriptionObserver();
    // Also trigger token registration after a short delay – OneSignal subscriptionId
    // can be null for a few seconds after first launch while it registers with FCM/APNs.
    _scheduleRetry();
    // Ensure system permission dialog shows after UI is ready (fixes early-request not showing)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      try {
        final status = await Permission.notification.status;
        if (status.isDenied) {
          if (kDebugMode) debugPrint('[Push] Post-frame requesting notification permission');
          await oneSignalService.requestPermission();
          await pushNotificationService.requestPermission();
          final id = oneSignalService.subscriptionId;
          if (id != null && id.isNotEmpty && id != _registeredToken) {
            await _maybeRegisterDeviceToken(id);
          }
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final id = oneSignalService.subscriptionId;
      if (kDebugMode) debugPrint('[Push] Retry token check id=$id registered=$_registeredToken');
      if (id != null && id.isNotEmpty && id != _registeredToken) {
        _maybeRegisterDeviceToken(id);
      }
      // One more retry at 10s for slow networks
      Future.delayed(const Duration(seconds: 7), () {
        if (!mounted) return;
        final id2 = oneSignalService.subscriptionId;
        if (id2 != null && id2.isNotEmpty && id2 != _registeredToken) {
          _maybeRegisterDeviceToken(id2);
        }
      });
    });
  }

  bool _isRegistered(String? id) => id != null && id.isNotEmpty && !id.startsWith('local-');

  String get _platform {
    if (kIsWeb) return 'WEB';
    if (Platform.isIOS) return 'IOS';
    if (Platform.isAndroid) return 'ANDROID';
    return 'WEB';
  }

  void _setupPushSubscriptionObserver() {
    oneSignalService.addPushSubscriptionObserver((id) {
      if (kDebugMode) debugPrint('[Push] Observer subscriptionId=$id');
      _maybeRegisterDeviceToken(id);
    });
    // Fire immediately with current value (may be null on first run)
    _maybeRegisterDeviceToken(oneSignalService.subscriptionId);

    // Also listen to foreground notifications to refresh feed live
    oneSignalService.onNotificationReceived = (data) {
      if (!mounted) return;
      ref.read(notificationProvider.notifier).load(force: true);
    };
  }

  Future<void> _maybeRegisterDeviceToken(String? id) async {
    if (!_isRegistered(id) || id == _registeredToken) return;
    final isLoggedIn = await _storage.read(key: AuthStorageKeys.isLoggedIn) == 'true';
    if (!isLoggedIn || !mounted) {
      if (kDebugMode) debugPrint('[Push] Skip register – not logged in or not mounted (id=$id)');
      return;
    }
    try {
      if (kDebugMode) debugPrint('[Push] Registering device token id=$id platform=$_platform');
      await ref.read(notificationRepositoryProvider).registerDeviceToken(token: id!, platform: _platform);
      _registeredToken = id;
      if (kDebugMode) debugPrint('[Push] Device token registered successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] registerDeviceToken failed: $e');
      // Will be retried on next subscription change or on next login.
    }
  }

  /// Public helper to force re-register after login. Call this from sign-in flow.
  Future<void> registerIfNeeded() async {
    final id = oneSignalService.subscriptionId ?? await pushNotificationService.getFcmToken();
    await _maybeRegisterDeviceToken(id);
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
              const Icon(Icons.refresh_rounded, size: 56, color: Color(0xFFBDBDBD)),
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
                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E), height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
