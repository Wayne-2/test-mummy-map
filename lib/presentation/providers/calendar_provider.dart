import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/calendar_local_datasource.dart';
import 'package:mummymap/data/models/calendar_models.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';

final calendarLocalDatasourceProvider = Provider<CalendarLocalDatasource>((ref) {
  return CalendarLocalDatasource();
});

class CalendarState {
  final List<CalendarEvent> events;
  final List<ReminderModel> reminders;
  final bool isLoading;

  const CalendarState({
    this.events = const [],
    this.reminders = const [],
    this.isLoading = false,
  });

  CalendarState copyWith({
    List<CalendarEvent>? events,
    List<ReminderModel>? reminders,
    bool? isLoading,
  }) {
    return CalendarState(
      events: events ?? this.events,
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  final CalendarLocalDatasource _localDatasource;
  String _userId;

  CalendarNotifier(this._localDatasource, this._userId) : super(const CalendarState(isLoading: true)) {
    _loadData();
  }

  Future<void> refreshWith(String newUserId) async {
    if (newUserId == _userId) return;
    _userId = newUserId;
    state = const CalendarState(isLoading: true);
    await _loadData();
  }

  Future<void> _loadData() async {
    if (_userId.isEmpty) {
      state = state.copyWith(isLoading: false, events: [], reminders: []);
      return;
    }
    try {
      final events = await _localDatasource.getEvents(_userId);
      final reminders = await _localDatasource.getReminders(_userId);
      state = state.copyWith(
        events: events,
        reminders: reminders,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addEvent(CalendarEvent event) async {
    final newEvents = [...state.events, event];
    state = state.copyWith(events: newEvents);
    await _localDatasource.saveEvents(_userId, newEvents);
  }

  Future<void> updateEvent(CalendarEvent event) async {
    final newEvents = state.events.map((e) => e.id == event.id ? event : e).toList();
    state = state.copyWith(events: newEvents);
    await _localDatasource.saveEvents(_userId, newEvents);
  }

  Future<void> deleteEvent(String id) async {
    final newEvents = state.events.where((e) => e.id != id).toList();
    state = state.copyWith(events: newEvents);
    await _localDatasource.saveEvents(_userId, newEvents);
  }

  Future<void> addReminder(ReminderModel reminder) async {
    final newReminders = [...state.reminders, reminder];
    state = state.copyWith(reminders: newReminders);
    await _localDatasource.saveReminders(_userId, newReminders);
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    final newReminders = state.reminders.map((r) => r.id == reminder.id ? reminder : r).toList();
    state = state.copyWith(reminders: newReminders);
    await _localDatasource.saveReminders(_userId, newReminders);
  }

  Future<void> deleteReminder(String id) async {
    final newReminders = state.reminders.where((r) => r.id != id).toList();
    state = state.copyWith(reminders: newReminders);
    await _localDatasource.saveReminders(_userId, newReminders);
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final profile = ref.watch(profileProvider).value;
  final userId = profile?.userId ?? profile?.id ?? '';
  final notifier = CalendarNotifier(ref.watch(calendarLocalDatasourceProvider), userId);
  ref.listen(profileProvider, (prev, next) {
    final newId = next.value?.userId ?? next.value?.id ?? '';
    if (newId.isNotEmpty && newId != userId) {
      notifier.refreshWith(newId);
    }
  });
  return notifier;
});
