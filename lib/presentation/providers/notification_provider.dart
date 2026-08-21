import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/notification_remote_datasource.dart';
import 'package:mummymap/data/models/notification_model.dart';
import 'package:mummymap/domain/repositories/notification_repository.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';

final notificationDatasourceProvider =
    Provider<NotificationRemoteDatasource>((ref) {
  return NotificationRemoteDatasource(ref.read(dioProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(notificationDatasourceProvider));
});

class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? errorMessage;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  bool _loaded = false;

  NotificationNotifier(this._repository) : super(const NotificationState());

  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final notifications = await _repository.getNotifications();
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
      );
      _loaded = true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load notifications.',
      );
    }
  }

  Future<void> markAsRead(String id) async {
    final notifications = state.notifications
        .map((n) => n.id == id ? _copyRead(n, true) : n)
        .toList();
    state = state.copyWith(notifications: notifications);
    try {
      await _repository.markAsRead(id);
    } catch (_) {
      final reverted = state.notifications
          .map((n) => n.id == id ? _copyRead(n, false) : n)
          .toList();
      state = state.copyWith(notifications: reverted);
    }
  }

  Future<void> markAllAsRead() async {
    final notifications =
        state.notifications.map((n) => _copyRead(n, true)).toList();
    state = state.copyWith(notifications: notifications);
    try {
      await _repository.markAllAsRead();
    } catch (_) {}
  }

  AppNotification _copyRead(AppNotification n, bool isRead) {
    return AppNotification(
      id: n.id,
      title: n.title,
      body: n.body,
      boldPart: n.boldPart,
      category: n.category,
      data: n.data,
      createdAt: n.createdAt,
      isRead: isRead,
    );
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
  (ref) => NotificationNotifier(ref.read(notificationRepositoryProvider)),
);