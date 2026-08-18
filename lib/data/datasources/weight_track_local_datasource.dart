import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mummymap/data/models/weight_track_model.dart';

class WeightTrackLocalDatasource {
  static const _boxName = 'weight_track_box';
  static const _historyKey = 'weight_history';

  Box<String> get _box => Hive.box<String>(_boxName);

  Future<List<WeightLog>> getHistory(String userId) async {
    final json = _box.get('${_historyKey}_$userId');
    if (json == null) return [];
    try {
      final decoded = jsonDecode(json) as List;
      return decoded
          .map((e) => WeightLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(String userId, List<WeightLog> entries) async {
    await _box.put(
      '${_historyKey}_$userId',
      jsonEncode(entries.map((e) => e.toStorageJson()).toList()),
    );
  }
}
