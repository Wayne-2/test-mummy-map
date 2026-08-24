import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles Firebase Cloud Messaging (FCM) + local notifications as a fallback
/// alongside OneSignal. OneSignal already delivers via FCM/APNs, but this
/// service ensures:
///   * iOS/Android permission is explicitly requested
///   * Foreground messages are displayed via flutter_local_notifications
///   * Background/terminated tap handling works
///   * FCM token is available if backend needs it in future
///
/// Background handler must be top-level and registered BEFORE runApp.

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
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;

  void Function(Map<String, dynamic> data)? onNotificationClicked;

  Future<void> initialize() async {
    if (_initialized) return;

    // Local notifications setup (Android channel + iOS settings)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _local.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && kDebugMode) {
          debugPrint('[FCM] Local notification tapped payload: ${response.payload}');
        }
        // Payload is map-like string; actual click data comes from onMessageOpenedApp
        // We store the payload as data if present
        if (onNotificationClicked != null) {
          // If payload was set, try to use it – otherwise no-op (click is handled via FCM listener)
          try {
            // payload is just notification id; real routing uses message.data
          } catch (_) {}
        }
      },
    );

    // Create Android notification channel (required for Android 8+)
    const channel = AndroidNotificationChannel(
      'mummymap_high_importance',
      'MummyMap Notifications',
      description: 'Important updates about appointments, health and community.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Register background handler (must be after Firebase.initializeApp in main)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _initialized = true;
    if (kDebugMode) debugPrint('[FCM] Local notifications initialized');

    // Request permission early (Android 13 needs POST_NOTIFICATIONS)
    await requestPermission();

    // Log current FCM token for debugging
    await _logToken();

    // Listeners: foreground, tap when app from background/terminated
    _attachListeners(channel);
  }

  Future<void> _logToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) debugPrint('[FCM] FCM token: $token');
      // Also listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) debugPrint('[FCM] Token refreshed: $newToken');
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] getToken error: $e');
    }
  }

  void _attachListeners(AndroidNotificationChannel channel) {
    // Foreground messages – show local notification so user still sees banner
    _onMessageSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        debugPrint('[FCM] Foreground message: ${message.notification?.title} data=${message.data}');
      }
      final notification = message.notification;
      // If message has notification payload, display it; data-only messages are still handled
      if (notification != null) {
        await _showLocalNotification(notification, channel, message.data);
      } else if (message.data.isNotEmpty) {
        // Data-only foreground message – synthesize a notification for visibility
        await _showLocalNotification(
          RemoteNotification(
            title: message.data['title'] as String? ?? message.data['headings'] as String? ?? 'MummyMap',
            body: message.data['body'] as String? ?? message.data['contents'] as String? ?? 'You have a new update',
          ),
          channel,
          message.data,
        );
      }
    });

    // App opened from terminated state via notification
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) debugPrint('[FCM] Initial message: ${message.data}');
        onNotificationClicked?.call(message.data);
      }
    });

    // App opened from background via notification tap
    _onMessageOpenedAppSub?.cancel();
    _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) debugPrint('[FCM] onMessageOpenedApp: ${message.data}');
      onNotificationClicked?.call(message.data);
    });
  }

  Future<void> _showLocalNotification(
    RemoteNotification notification,
    AndroidNotificationChannel channel,
    Map<String, dynamic> data,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _local.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: data.toString(),
    );
  }

  /// Explicitly request notification permission (both OS and FCM).
  /// Covers Android 13+ POST_NOTIFICATIONS via permission_handler + Firebase request.
  Future<bool> requestPermission() async {
    try {
      // Android 13+ requires POST_NOTIFICATIONS runtime permission.
      if (!kIsWeb) {
        final status = await Permission.notification.status;
        if (status.isDenied || status.isRestricted || status.isLimited) {
          final result = await Permission.notification.request();
          if (kDebugMode) debugPrint('[FCM] Permission.notification request result: $result');
          if (result.isDenied || result.isPermanentlyDenied) {
            // Still try Firebase permission – iOS will deny anyway
          }
        } else if (status.isPermanentlyDenied) {
          if (kDebugMode) debugPrint('[FCM] Permission permanently denied – prompt to settings');
          // Don't open settings automatically; let caller decide
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
