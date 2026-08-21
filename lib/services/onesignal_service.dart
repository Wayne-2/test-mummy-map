import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  static const String _appId = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: "e260fac3-f4b6-4285-b860-44cc30b6b5ef",
  );

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    OneSignal.initialize(_appId);
    _isInitialized = true;
  }

  String? get subscriptionId => OneSignal.User.pushSubscription.id;

  void addPushSubscriptionObserver(void Function(String? id) onChanged) {
    OneSignal.User.pushSubscription.addObserver((state) {
      onChanged(state.current.id);
    });
  }

  Future<bool> requestPermission() async {
    return await OneSignal.Notifications.requestPermission(true);
  }
}