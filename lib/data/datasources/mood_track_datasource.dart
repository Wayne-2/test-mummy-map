import 'package:dio/dio.dart';
import 'package:mummymap/data/models/mood_track_model.dart';

class MoodTrackDatasource {
  final Dio dio;

  MoodTrackDatasource(this.dio);

  Future<MoodLog> logMood(MoodLog entry) async {
    final res = await dio.post('/api/v1/track/mood', data: entry.toCreateJson());
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return MoodLog.fromJson(data);
    }
    return entry;
  }

  Future<List<MoodLog>> getMoodHistory({int page = 1, int limit = 50}) async {
    final res = await dio.get(
      '/api/v1/track/mood',
      queryParameters: {'page': page, 'limit': limit},
    );
    return _extractList(res.data)
        .map((e) => MoodLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'] as List;
      if (data['logs'] is List) return data['logs'] as List;
      if (data['entries'] is List) return data['entries'] as List;
      if (data['items'] is List) return data['items'] as List;
    }
    return const [];
  }
}