import 'package:dio/dio.dart';
import 'package:mummymap/data/models/weight_track_model.dart';

class WeightTrackDatasource {
  final Dio dio;

  WeightTrackDatasource(this.dio);

  Future<WeightLog> logWeight(WeightLog entry) async {
    final res = await dio.post('/api/v1/track/weight', data: entry.toCreateJson());
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return WeightLog.fromJson(data);
    }
    return entry;
  }

  Future<List<WeightLog>> getWeightHistory({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int limit = 100,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (from != null) {
      query['from'] = from.toUtc().toIso8601String().split('T').first;
    }
    if (to != null) {
      query['to'] = to.toUtc().toIso8601String().split('T').first;
    }
    final res = await dio.get('/api/v1/track/weight', queryParameters: query);
    return _extractList(res.data)
        .map((e) => WeightLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'] as List;
      if (data['logs'] is List) return data['logs'] as List;
      if (data['entries'] is List) return data['entries'] as List;
      if (data['items'] is List) return data['items'] as List;
      if (data['history'] is List) return data['history'] as List;
    }
    return const [];
  }
}