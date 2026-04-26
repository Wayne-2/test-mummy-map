import 'package:flutter/material.dart';

enum _NotifType { reminder, group, message, appointment }

enum _FilterTab { all, unread, read }

class AppNotification {
  final String id;
  final _NotifType type;
  final String text;
  final String boldPart;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.text,
    required this.boldPart,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  _FilterTab _activeTab = _FilterTab.all;

  final List<AppNotification> _notifications = [];

  List<AppNotification> get _filtered {
    switch (_activeTab) {
      case _FilterTab.unread:
        return _notifications.where((n) => !n.isRead).toList();
      case _FilterTab.read:
        return _notifications.where((n) => n.isRead).toList();
      case _FilterTab.all:
        return _notifications;
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;
  int get _readCount => _notifications.where((n) => n.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final n = _notifications.firstWhere((n) => n.id == id);
      n.isRead = true;
    });
  }

  Map<String, List<AppNotification>> _groupByDate(
      List<AppNotification> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<AppNotification>> grouped = {};

    for (final n in list) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      String label;
      if (d == today) {
        label = 'Today';
      } else if (d == yesterday) {
        label = 'Yesterday';
      } else {
        final months = [
          '', 'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        label = months[n.createdAt.month];
      }
      grouped.putIfAbsent(label, () => []).add(n);
    }

    return grouped;
  }

  IconData _iconFor(_NotifType type) {
    switch (type) {
      case _NotifType.reminder:
        return Icons.notifications_outlined;
      case _NotifType.group:
        return Icons.group_outlined;
      case _NotifType.message:
        return Icons.chat_bubble_outline;
      case _NotifType.appointment:
        return Icons.calendar_today_outlined;
    }
  }

  String _timeLabel(AppNotification n) {
    final diff = DateTime.now().difference(n.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} Mins Ago';
    if (diff.inHours < 24) return '${diff.inHours} Hours Ago';
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[n.createdAt.month]} ${n.createdAt.day}, ${n.createdAt.year} • ${_formatTime(n.createdAt)}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(_filtered);
    final hasUnread = _unreadCount > 0;

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
                  if (_notifications.isNotEmpty && hasUnread)
                    GestureDetector(
                      onTap: _markAllAsRead,
                      child: Row(
                        children: [
                          const Text(
                            'Mark All As Read',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3F2868),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.done_all,
                              size: 16, color: Color(0xFF3F2868)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (_notifications.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _FilterBar(
                  active: _activeTab,
                  total: _notifications.length,
                  unread: _unreadCount,
                  read: _readCount,
                  onChanged: (tab) => setState(() => _activeTab = tab),
                ),
              ),
            ],
            Expanded(
              child: _notifications.isEmpty
                  ? _EmptyState()
                  : _filtered.isEmpty
                      ? _EmptyFilterState(tab: _activeTab)
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: _buildItems(grouped).length,
                          itemBuilder: (context, index) {
                            final item = _buildItems(grouped)[index];
                            if (item is String) {
                              return _DateHeader(label: item);
                            }
                            final n = item as AppNotification;
                            return _NotificationTile(
                              notification: n,
                              icon: _iconFor(n.type),
                              timeLabel: _timeLabel(n),
                              onTap: () => _markAsRead(n.id),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _buildItems(Map<String, List<AppNotification>> grouped) {
    final items = <dynamic>[];
    for (final entry in grouped.entries) {
      items.add(entry.key);
      items.addAll(entry.value);
    }
    return items;
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
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
                      children: _parseText(
                          notification.text, notification.boldPart),
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When you get notifications about your pregnancy, appointments or community activity they\'ll show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
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

class _EmptyFilterState extends StatelessWidget {
  final _FilterTab tab;

  const _EmptyFilterState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final label = tab == _FilterTab.unread ? 'unread' : 'read';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
              'No $label notifications',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}