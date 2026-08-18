import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mummymap/data/models/calendar_models.dart';

class CalendarLocalDatasource {
  static const _boxName = 'calendar_box';
  static const _eventsKey = 'calendar_events';
  static const _remindersKey = 'calendar_reminders';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
  }

  Future<List<CalendarEvent>> getEvents(String userId) async {
    await init();
    final box = Hive.box<String>(_boxName);
    final data = box.get('${_eventsKey}_$userId');
    if (data != null) {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> saveEvents(String userId, List<CalendarEvent> events) async {
    await init();
    final box = Hive.box<String>(_boxName);
    final data = events.map((e) => e.toJson()).toList();
    await box.put('${_eventsKey}_$userId', jsonEncode(data));
  }

  Future<List<ReminderModel>> getReminders(String userId) async {
    await init();
    final box = Hive.box<String>(_boxName);
    final data = box.get('${_remindersKey}_$userId');
    if (data != null) {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => ReminderModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> saveReminders(String userId, List<ReminderModel> reminders) async {
    await init();
    final box = Hive.box<String>(_boxName);
    final data = reminders.map((e) => e.toJson()).toList();
    await box.put('${_remindersKey}_$userId', jsonEncode(data));
  }
}
