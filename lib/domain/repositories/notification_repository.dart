import 'package:mummymap/data/datasources/notification_remote_datasource.dart';
import 'package:mummymap/data/models/notification_model.dart';

class NotificationRepository {
  final NotificationRemoteDatasource remoteDatasource;

  NotificationRepository(this.remoteDatasource);

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) {
    return remoteDatasource.registerDeviceToken(token: token, platform: platform);
  }

  Future<List<AppNotification>> getNotifications() {
    return remoteDatasource.getNotifications();
  }

  Future<void> markAsRead(String id) {
    return remoteDatasource.markAsRead(id);
  }

  Future<void> markAllAsRead() {
    return remoteDatasource.markAllAsRead();
  }
}