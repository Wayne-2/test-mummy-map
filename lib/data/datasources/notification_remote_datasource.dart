import 'package:dio/dio.dart';
import 'package:mummymap/data/models/notification_model.dart';

class NotificationRemoteDatasource {
  final Dio dio;

  NotificationRemoteDatasource(this.dio);

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    await dio.post(
      '/api/v1/notifications/device-token',
      data: {'token': token, 'platform': platform},
    );
  }

  Future<List<AppNotification>> getNotifications() async {
    final res = await dio.get('/api/v1/notifications');
    return _extractList(res.data)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await dio.patch('/api/v1/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await dio.post('/api/v1/notifications/read-all');
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'] as List;
      if (data['notifications'] is List) return data['notifications'] as List;
      if (data['items'] is List) return data['items'] as List;
      if (data['results'] is List) return data['results'] as List;
    }
    return const [];
  }
}