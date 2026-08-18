import 'package:flutter/material.dart';

enum EventType { appointment, group, reminder, event }

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final EventType type;
  final Color color;
  final String timeLabel;
  final String emoji;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.color,
    required this.timeLabel,
    required this.emoji,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'type': type.name,
      'color': color.value,
      'timeLabel': timeLabel,
      'emoji': emoji,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      type: EventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventType.event,
      ),
      color: Color(json['color'] as int),
      timeLabel: json['timeLabel'] as String,
      emoji: json['emoji'] as String,
    );
  }
}

class ReminderModel {
  final String id;
  final String title;
  final String time;
  final String timeOfDay;
  final String? repeatDays;
  bool enabled;
  bool completed;

  ReminderModel({
    required this.id,
    required this.title,
    required this.time,
    required this.timeOfDay,
    this.repeatDays,
    this.enabled = true,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'timeOfDay': timeOfDay,
      'repeatDays': repeatDays,
      'enabled': enabled,
      'completed': completed,
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String,
      time: json['time'] as String,
      timeOfDay: json['timeOfDay'] as String,
      repeatDays: json['repeatDays'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

enum NewEventType { appointment, reminder, event }

class SeedData {
  const SeedData();

  List<CalendarEvent> get events {
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: 'seed_1',
        title: 'Baby Checkup',
        date: DateTime(now.year, now.month, now.day, 11),
        type: EventType.appointment,
        color: const Color(0xFF3F2868),
        timeLabel: '11:00 AM',
        emoji: '👶',
      ),
      CalendarEvent(
        id: 'seed_2',
        title: 'Sporty Moms Walk',
        date: DateTime(now.year, now.month, now.day, 16),
        type: EventType.group,
        color: const Color(0xFFFFA726),
        timeLabel: '4:00 PM',
        emoji: '🏃',
      ),
      CalendarEvent(
        id: 'seed_3',
        title: 'Start solids today',
        date: DateTime(now.year, now.month, now.day, 18),
        type: EventType.reminder,
        color: const Color(0xFF4FC3F7),
        timeLabel: 'Reminder',
        emoji: '💬',
      ),
      CalendarEvent(
        id: 'seed_4',
        title: 'Prenatal Checkup',
        date: DateTime(now.year, now.month, now.day + 3, 10),
        type: EventType.appointment,
        color: const Color(0xFF3F2868),
        timeLabel: '10:00 AM',
        emoji: '🏥',
      ),
      CalendarEvent(
        id: 'seed_5',
        title: 'Meal Plan Group Session',
        date: DateTime(now.year, now.month, now.day, 8, 30),
        type: EventType.group,
        color: const Color(0xFFFFA726),
        timeLabel: '8:30 AM',
        emoji: '🍽️',
      ),
    ];
  }

  static List<ReminderModel> seedReminders() {
    return [
      ReminderModel(
        id: 'rem_1',
        title: 'Prenatal Vitamin',
        time: '8:00 AM',
        timeOfDay: 'Morning',
        enabled: true,
      ),
      ReminderModel(
        id: 'rem_2',
        title: 'Stretch For 10 Mins',
        time: '9:00 AM',
        timeOfDay: 'Morning',
        repeatDays: 'Mon - Fri',
        enabled: true,
      ),
      ReminderModel(
        id: 'rem_3',
        title: 'Drink Water',
        time: '2:00 PM',
        timeOfDay: 'Afternoon',
        enabled: false,
        completed: true,
      ),
      ReminderModel(
        id: 'rem_4',
        title: 'Hydration Break',
        time: '11:32 AM',
        timeOfDay: 'Evening',
        repeatDays: 'Mon - Sun',
        enabled: true,
      ),
      ReminderModel(
        id: 'rem_5',
        title: 'Morning Stretch',
        time: 'Apr 4',
        timeOfDay: 'Morning',
        enabled: false,
        completed: true,
      ),
      ReminderModel(
        id: 'rem_6',
        title: 'Take Meds',
        time: 'Apr 6',
        timeOfDay: 'Morning',
        enabled: false,
        completed: true,
      ),
    ];
  }
}
