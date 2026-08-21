import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/notification_model.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/group_detail.dart';
import 'package:mummymap/presentation/pages/side/doctors/minor%20screens/appointment_detail_screen.dart';
import 'package:mummymap/presentation/providers/notification_provider.dart';

enum _FilterTab { all, unread, read }

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  _FilterTab _activeTab = _FilterTab.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationProvider.notifier).load());
  }

  List<AppNotification> get _filtered {
    final notifications = ref.watch(notificationProvider).notifications;
    switch (_activeTab) {
      case _FilterTab.unread:
        return notifications.where((n) => !n.isRead).toList();
      case _FilterTab.read:
        return notifications.where((n) => n.isRead).toList();
      case _FilterTab.all:
        return notifications;
    }
  }

  int get _unreadCount => ref.watch(notificationProvider).unreadCount;
  int get _readCount =>
      ref.watch(notificationProvider).notifications.length - _unreadCount;

  Future<void> _refresh() async {
    await ref.read(notificationProvider.notifier).load(force: true);
  }

  void _markAllAsRead() {
    ref.read(notificationProvider.notifier).markAllAsRead();
  }

  void _onTap(AppNotification n) {
    ref.read(notificationProvider.notifier).markAsRead(n.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    _deepLink(n);
  }

  void _deepLink(AppNotification n) {
    final data = n.data;
    switch (n.category) {
      case NotificationCategory.appointment:
        if (data.appointmentId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  AppointmentDetailScreen(appointmentId: data.appointmentId!),
            ),
          );
        }
        break;
      case NotificationCategory.community:
        if (data.groupId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GroupDetail(groupId: data.groupId!),
            ),
          );
        }
        break;
      default:
        break;
    }
  }

  IconData _iconFor(NotificationCategory category) => category.icon;

  String _timeLabel(AppNotification n) {
    final diff = DateTime.now().difference(n.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} Mins Ago';
    if (diff.inHours < 24) return '${diff.inHours} Hours Ago';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = n.createdAt.hour > 12
        ? n.createdAt.hour - 12
        : n.createdAt.hour == 0
            ? 12
            : n.createdAt.hour;
    final m = n.createdAt.minute.toString().padLeft(2, '0');
    final period = n.createdAt.hour >= 12 ? 'PM' : 'AM';
    return '${months[n.createdAt.month]} ${n.createdAt.day}, ${n.createdAt.year} • $h:$m $period';
  }

  Map<String, List<AppNotification>> _groupByDate(List<AppNotification> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final Map<String, List<AppNotification>> grouped = {};
    for (final n in list) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      final String label;
      if (d == today) {
        label = 'Today';
      } else if (d == yesterday) {
        label = 'Yesterday';
      } else {
        label = months[n.createdAt.month];
      }
      grouped.putIfAbsent(label, () => []).add(n);
    }
    return grouped;
  }

  List<dynamic> _buildItems(Map<String, List<AppNotification>> grouped) {
    final items = <dynamic>[];
    for (final entry in grouped.entries) {
      items.add(entry.key);
      items.addAll(entry.value);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final filtered = _filtered;
    final grouped = _groupByDate(filtered);
    final items = _buildItems(grouped);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFF1A1A1A)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllAsRead,
                      child: Row(
                        children: const [
                          Text(
                            'Mark All As Read',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3F2868),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.done_all,
                              size: 16, color: Color(0xFF3F2868)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _FilterBar(
                active: _activeTab,
                total: state.notifications.length,
                unread: _unreadCount,
                read: _readCount,
                onChanged: (tab) => setState(() => _activeTab = tab),
              ),
            ),
            Expanded(
              child: state.isLoading && filtered.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? _EmptyState(tab: _activeTab)
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              if (item is String) {
                                return _DateHeader(label: item);
                              }
                              final n = item as AppNotification;
                              return _NotificationTile(
                                notification: n,
                                icon: _iconFor(n.category),
                                timeLabel: _timeLabel(n),
                                onTap: () => _onTap(n),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final _FilterTab active;
  final int total;
  final int unread;
  final int read;
  final ValueChanged<_FilterTab> onChanged;

  const _FilterBar({
    required this.active,
    required this.total,
    required this.unread,
    required this.read,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'All',
            count: total,
            selected: active == _FilterTab.all,
            onTap: () => onChanged(_FilterTab.all),
          ),
          _Tab(
            label: 'Unread',
            count: unread,
            selected: active == _FilterTab.unread,
            onTap: () => onChanged(_FilterTab.unread),
          ),
          _Tab(
            label: 'Read',
            count: read,
            selected: active == _FilterTab.read,
            onTap: () => onChanged(_FilterTab.read),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3F2868) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.25)
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;

  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9E9E9E),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final String timeLabel;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.icon,
    required this.timeLabel,
    required this.onTap,
  });

  List<TextSpan> _parseText(String text, String bold) {
    if (bold.isEmpty || !text.contains(bold)) {
      return [
        TextSpan(
          text: text,
          style: const TextStyle(
              fontSize: 14, color: Color(0xFF1A1A1A), height: 1.4),
        ),
      ];
    }
    final parts = text.split(bold);
    return [
      TextSpan(
        text: parts[0],
        style: const TextStyle(
            fontSize: 14, color: Color(0xFF1A1A1A), height: 1.4),
      ),
      TextSpan(
        text: bold,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            height: 1.4),
      ),
      if (parts.length > 1)
        TextSpan(
          text: parts[1],
          style: const TextStyle(
              fontSize: 14, color: Color(0xFF1A1A1A), height: 1.4),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final text = notification.boldPart.isNotEmpty
        ? '${notification.title}\n${notification.body}'
        : notification.body.isNotEmpty
            ? notification.body
            : notification.title;
    final bold = notification.boldPart.isNotEmpty
        ? notification.title
        : notification.boldPart;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF3F2868), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: _parseText(text, bold),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeLabel,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ),
            if (!notification.isRead) ...[
              const SizedBox(width: 10),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3F2868),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _FilterTab tab;

  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final String title;
    final String subtitle;

    switch (tab) {
      case _FilterTab.unread:
        title = 'No unread notifications';
        subtitle = 'You\'re all caught up!';
        break;
      case _FilterTab.read:
        title = 'No read notifications';
        subtitle = 'Notifications you\'ve opened will appear here.';
        break;
      case _FilterTab.all:
        title = 'No notifications yet';
        subtitle =
            'When you get notifications about your pregnancy, appointments or community activity they\'ll show up here.';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                size: 44,
                color: Color(0xFF3F2868),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}