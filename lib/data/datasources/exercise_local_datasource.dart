import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class ExerciseLocalDatasource {
  static const _boxName = 'exercises_box';
  static const _completedDaysKey = 'completed_days';

  Box<String> get _box => Hive.box<String>(_boxName);

  Future<Set<String>> getCompletedDays(String userId) async {
    final json = _box.get('${_completedDaysKey}_$userId');
    if (json == null) return {};
    try {
      final List decoded = jsonDecode(json) as List;
      return Set<String>.from(decoded);
    } catch (_) {
      return {};
    }
  }

  Future<void> saveCompletedDays(String userId, Set<String> completedDays) async {
    await _box.put('${_completedDaysKey}_$userId', jsonEncode(completedDays.toList()));
  }
}
