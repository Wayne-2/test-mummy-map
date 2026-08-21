import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mummymap/data/models/mood_track_model.dart';

class MoodLocalDatasource {
  static const _boxName = 'mood_box';
  static const _historyKey = 'mood_history';

  Box<String> get _box => Hive.box<String>(_boxName);

  Future<List<MoodLog>> getLogs(String userId) async {
    final json = _box.get('${_historyKey}_$userId');
    if (json == null) return [];
    try {
      final decoded = jsonDecode(json) as List;
      return decoded
          .map((e) => MoodLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLogs(String userId, List<MoodLog> logs) async {
    await _box.put(
      '${_historyKey}_$userId',
      jsonEncode(logs.map((e) => e.toStorageJson()).toList()),
    );
  }
}