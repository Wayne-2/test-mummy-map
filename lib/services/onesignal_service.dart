import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Handles OneSignal initialization, permission, listeners, and navigation.
///
/// Call [initialize] once on app startup (already done in main.dart).
/// Use [requestPermission] to prompt the user when needed.
/// Listen to subscription changes via [addPushSubscriptionObserver].
class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  // Set via --dart-define=ONESIGNAL_APP_ID=xxx or fallback.
  // The fallback matches the existing project value.
  static const String _appId = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: "e260fac3-f4b6-4285-b860-44cc30b6b5ef",
  );

  bool _isInitialized = false;
  bool _listenersAttached = false;

  /// Optional callback when a notification is clicked.
  /// Provides the raw OneSignal additionalData map.
  void Function(Map<String, dynamic> data)? onNotificationClicked;
  void Function(Map<String, dynamic> data)? onNotificationReceived;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Enable verbose logging in debug builds only.
    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    }

    OneSignal.initialize(_appId);

    // Ensure push subscription is opted-in. OneSignal v5 requires explicit optIn
    // after initialization for some devices.
    try {
      OneSignal.User.pushSubscription.optIn();
    } catch (_) {}

    _attachListeners();
    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('[OneSignal] Initialized with appId=$_appId');
      debugPrint('[OneSignal] Initial subscriptionId=${subscriptionId}');
      debugPrint('[OneSignal] OptedIn=${OneSignal.User.pushSubscription.optedIn}');
    }

    // Proactively request permission (will show system dialog once).
    // Safe to call even if already granted – it returns immediately.
    // We don't await here to avoid blocking startup; the observer will catch the token.
    unawaited(requestPermission());
  }

  void _attachListeners() {
    if (_listenersAttached) return;
    _listenersAttached = true;

    // Foreground notifications: by default OneSignal may hide them.
    // We explicitly display them so users see banners even in-app.
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      if (kDebugMode) {
        debugPrint('[OneSignal] Foreground will display: ${event.notification.title}');
        debugPrint('[OneSignal] additionalData: ${event.notification.additionalData}');
      }
      onNotificationReceived?.call(
        event.notification.additionalData ?? {},
      );
      // This displays the notification as a system banner even when app is foregrounded.
      event.notification.display();
    });

    // When user taps a notification (background / terminated / foreground).
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData ?? {};
      if (kDebugMode) {
        debugPrint('[OneSignal] Notification clicked: ${event.notification.title}');
        debugPrint('[OneSignal] additionalData: $data');
      }
      onNotificationClicked?.call(data);
      // Also forward to global handler for deep-linking if needed.
      _handleClickData(data);
    });

    // Permission changes (useful for debugging)
    OneSignal.Notifications.addPermissionObserver((state) {
      if (kDebugMode) {
        debugPrint('[OneSignal] Permission changed: $state');
      }
    });

    // Also listen to push subscription changes for logging
    OneSignal.User.pushSubscription.addObserver((state) {
      if (kDebugMode) {
        debugPrint('[OneSignal] Subscription changed: ${state.current.id} optedIn=${state.current.optedIn}');
      }
    });
  }

  void _handleClickData(Map<String, dynamic> data) {
    // No-op here – main.dart wires onNotificationClicked to navigator.
    // Keeping this for future deep-link routing if needed.
  }

  /// Current OneSignal subscription ID (push token) if available.
  String? get subscriptionId => OneSignal.User.pushSubscription.id;

  bool get isOptedIn => OneSignal.User.pushSubscription.optedIn ?? false;

  bool get isInitialized => _isInitialized;

  /// Observe subscription ID changes. Immediately fires with current value if present.
  void addPushSubscriptionObserver(void Function(String? id) onChanged) {
    OneSignal.User.pushSubscription.addObserver((state) {
      onChanged(state.current.id);
    });
  }

  /// Request OS notification permission from the user.
  /// Returns true if permission is granted.
  Future<bool> requestPermission() async {
    try {
      final granted = await OneSignal.Notifications.requestPermission(true);
      if (kDebugMode) debugPrint('[OneSignal] requestPermission result: $granted');
      // After granting, ensure we are opted-in so subscriptionId becomes available.
      if (granted) {
        try {
          OneSignal.User.pushSubscription.optIn();
        } catch (_) {}
      }
      return granted;
    } catch (e) {
      if (kDebugMode) debugPrint('[OneSignal] requestPermission error: $e');
      return false;
    }
  }

  /// Explicitly opt-in to push. Useful if user previously opted out.
  Future<void> optIn() async {
    try {
      OneSignal.User.pushSubscription.optIn();
    } catch (e) {
      if (kDebugMode) debugPrint('[OneSignal] optIn error: $e');
    }
  }

  Future<void> optOut() async {
    try {
      OneSignal.User.pushSubscription.optOut();
    } catch (e) {
      if (kDebugMode) debugPrint('[OneSignal] optOut error: $e');
    }
  }

  /// Associate an external user ID (your backend user ID) with OneSignal for targeting.
  Future<void> login(String externalId) async {
    try {
      await OneSignal.login(externalId);
      if (kDebugMode) debugPrint('[OneSignal] login: $externalId');
    } catch (e) {
      if (kDebugMode) debugPrint('[OneSignal] login error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await OneSignal.logout();
      if (kDebugMode) debugPrint('[OneSignal] logout success');
    } catch (e) {
      if (kDebugMode) debugPrint('[OneSignal] logout error: $e');
    }
  }

  /// Tag helpers for segmentation
  Future<void> addTag(String key, String value) async {
    try {
      OneSignal.User.addTagWithKey(key, value);
    } catch (_) {}
  }

  Future<void> removeTag(String key) async {
    try {
      OneSignal.User.removeTag(key);
    } catch (_) {}
  }

  /// For debugging: prints current state.
  void logStatus() {
    if (kDebugMode) {
      debugPrint('[OneSignal] subscriptionId=${subscriptionId}');
      debugPrint('[OneSignal] optedIn=$isOptedIn');
      debugPrint('[OneSignal] permission=${OneSignal.Notifications.permission}');
    }
  }
}
