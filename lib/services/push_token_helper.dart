import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/main.dart';
import 'package:mummymap/presentation/providers/notification_provider.dart';

/// Call this after user login / OTP verify to ensure device token is registered.
/// Safe to call multiple times – deduplicates via backend or local check.
Future<void> registerPushToken(WidgetRef ref) async {
  try {
    // Ensure push services requested permission and are ready
    await oneSignalService.requestPermission();
    await pushNotificationService.requestPermission();

    // Give OneSignal a moment to generate subscriptionId after optIn
    String? token = oneSignalService.subscriptionId;
    if (token == null || token.isEmpty) {
      await Future.delayed(const Duration(seconds: 2));
      token = oneSignalService.subscriptionId;
    }
    // Fallback to FCM token if OneSignal still null
    token ??= await pushNotificationService.getFcmToken();

    if (token == null || token.isEmpty) {
      if (kDebugMode) debugPrint('[PushHelper] No token available yet');
      return;
    }

    String platform;
    if (kIsWeb) {
      platform = 'WEB';
    } else if (Platform.isIOS) {
      platform = 'IOS';
    } else if (Platform.isAndroid) {
      platform = 'ANDROID';
    } else {
      platform = 'WEB';
    }

    if (kDebugMode) debugPrint('[PushHelper] Registering token $token platform=$platform');
    await ref.read(notificationRepositoryProvider).registerDeviceToken(token: token, platform: platform);
    if (kDebugMode) debugPrint('[PushHelper] Token registered');
  } catch (e) {
    if (kDebugMode) debugPrint('[PushHelper] registerPushToken error: $e');
  }
}

/// Non-Ref version for use in main.dart or background isolates
Future<void> registerPushTokenWithContainer(ProviderContainer container) async {
  try {
    await oneSignalService.requestPermission();
    String? token = oneSignalService.subscriptionId;
    if (token == null || token.isEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      token = oneSignalService.subscriptionId;
    }
    if (token == null || token.isEmpty) return;
    String platform;
    if (kIsWeb) {
      platform = 'WEB';
    } else if (Platform.isIOS) {
      platform = 'IOS';
    } else if (Platform.isAndroid) {
      platform = 'ANDROID';
    } else {
      platform = 'WEB';
    }
    await container.read(notificationRepositoryProvider).registerDeviceToken(token: token, platform: platform);
  } catch (_) {}
}
