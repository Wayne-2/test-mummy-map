import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles Firebase Cloud Messaging (FCM) alongside OneSignal.
/// OneSignal delivers via FCM/APNs; this service ensures:
///   * iOS/Android permission is explicitly requested (Android 13 POST_NOTIFICATIONS)
///   * Background/terminated tap handling works
///   * FCM token is available for logging/debugging
/// No flutter_local_notifications required – OneSignal/FCM system handles display.
/// This avoids Android core library desugaring and Java 25 incompatibility.

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint('[FCM] Background message: ${message.messageId} ${message.notification?.title}');
    debugPrint('[FCM] data: ${message.data}');
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;

  void Function(Map<String, dynamic> data)? onNotificationClicked;

  Future<void> initialize() async {
    if (_initialized) return;

    // Register background handler (must be after Firebase.initializeApp in main)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _initialized = true;
    if (kDebugMode) debugPrint('[FCM] Push service initialized (no local notifications)');

    // Request permission early (Android 13 needs POST_NOTIFICATIONS)
    await requestPermission();

    // Log current FCM token for debugging
    await _logToken();

    // Listeners: foreground, tap when app from background/terminated
    _attachListeners();
  }

  Future<void> _logToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) debugPrint('[FCM] FCM token: $token');
      _messaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) debugPrint('[FCM] Token refreshed: $newToken');
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] getToken error: $e');
    }
  }

  void _attachListeners() {
    _onMessageSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        debugPrint('[FCM] Foreground message: ${message.notification?.title} data=${message.data}');
      }
      // OneSignal already displays foreground notifications via its SDK.
      // For FCM-only messages, system will not show banner in foreground automatically.
      // We just log and optionally forward to app UI via onNotificationClicked if needed.
      // If you need visible foreground banner for FCM data-only messages without
      // flutter_local_notifications, handle via SnackBar in the UI layer.
    });

    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) debugPrint('[FCM] Initial message: ${message.data}');
        onNotificationClicked?.call(message.data);
      }
    });

    _onMessageOpenedAppSub?.cancel();
    _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) debugPrint('[FCM] onMessageOpenedApp: ${message.data}');
      onNotificationClicked?.call(message.data);
    });
  }

  /// Explicitly request notification permission (both OS and FCM).
  /// Covers Android 13+ POST_NOTIFICATIONS via permission_handler + Firebase request.
  Future<bool> requestPermission() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.notification.status;
        if (status.isDenied || status.isRestricted || status.isLimited) {
          final result = await Permission.notification.request();
          if (kDebugMode) debugPrint('[FCM] Permission.notification request result: $result');
        } else if (status.isPermanentlyDenied) {
          if (kDebugMode) debugPrint('[FCM] Permission permanently denied – prompt to settings');
          return false;
        }
      }

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );
      if (kDebugMode) {
        debugPrint('[FCM] requestPermission authorizationStatus=${settings.authorizationStatus}');
      }
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] requestPermission error: $e');
      return false;
    }
  }

  Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] getFcmToken error: $e');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] subscribeToTopic error: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (_) {}
  }

  void dispose() {
    _onMessageSub?.cancel();
    _onMessageOpenedAppSub?.cancel();
  }
}
