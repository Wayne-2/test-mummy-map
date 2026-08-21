import 'package:flutter/material.dart';

enum NotificationCategory {
  appointment,
  medication,
  emergency,
  healthReminder,
  kickCountReminder,
  mealplan,
  order,
  vendor,
  chat,
  milestone,
  promotion,
  community,
  generic,
}

class NotificationCategories {
  NotificationCategories._();

  static NotificationCategory fromRaw(String? raw) {
    if (raw == null || raw.isEmpty) return NotificationCategory.generic;
    switch (raw.toLowerCase().replaceAll('-', '_')) {
      case 'appointment':
        return NotificationCategory.appointment;
      case 'medication':
        return NotificationCategory.medication;
      case 'emergency':
        return NotificationCategory.emergency;
      case 'health_reminder':
      case 'health':
        return NotificationCategory.healthReminder;
      case 'kick_count_reminder':
      case 'kick_count':
        return NotificationCategory.kickCountReminder;
      case 'mealplan':
      case 'meal_plan':
        return NotificationCategory.mealplan;
      case 'order':
        return NotificationCategory.order;
      case 'vendor':
        return NotificationCategory.vendor;
      case 'chat':
      case 'message':
        return NotificationCategory.chat;
      case 'milestone_notification':
      case 'milestone':
        return NotificationCategory.milestone;
      case 'promotion':
      case 'promo':
        return NotificationCategory.promotion;
      case 'community':
      case 'group':
        return NotificationCategory.community;
      default:
        return NotificationCategory.generic;
    }
  }
}

class NotificationData {
  final String category;
  final String? appointmentId;
  final String? roomId;
  final String? medicationId;
  final String? time;
  final String? alertId;
  final String? planId;
  final String? orderId;
  final String? status;
  final String? vendorId;
  final String? conversationId;
  final String? senderId;
  final String? postId;
  final String? groupId;
  final String? promoId;
  final String? week;

  const NotificationData({
    required this.category,
    this.appointmentId,
    this.roomId,
    this.medicationId,
    this.time,
    this.alertId,
    this.planId,
    this.orderId,
    this.status,
    this.vendorId,
    this.conversationId,
    this.senderId,
    this.postId,
    this.groupId,
    this.promoId,
    this.week,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    String? pick(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is String && v.isNotEmpty) return v;
        if (v is num) return v.toString();
      }
      return null;
    }

    return NotificationData(
      category: pick(const ['category', 'type', 'kind']) ?? 'generic',
      appointmentId: pick(const ['appointmentId', 'appointment_id']),
      roomId: pick(const ['roomId', 'room_id']),
      medicationId: pick(const ['medicationId', 'medication_id']),
      time: pick(const ['time']),
      alertId: pick(const ['alertId', 'alert_id']),
      planId: pick(const ['planId', 'plan_id']),
      orderId: pick(const ['orderId', 'order_id']),
      status: pick(const ['status']),
      vendorId: pick(const ['vendorId', 'vendor_id']),
      conversationId: pick(const ['conversationId', 'conversation_id']),
      senderId: pick(const ['senderId', 'sender_id']),
      postId: pick(const ['postId', 'post_id']),
      groupId: pick(const ['groupId', 'group_id']),
      promoId: pick(const ['promoId', 'promo_id']),
      week: pick(const ['week']),
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String boldPart;
  final NotificationCategory category;
  final NotificationData data;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.boldPart,
    required this.category,
    required this.data,
    required this.createdAt,
    required this.isRead,
  });

  String? get deepLinkTarget => data.category;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    String? pickString(List<String> keys) {
      for (final k in keys) {
        final v = root[k];
        if (v is String && v.isNotEmpty) return v;
      }
      return null;
    }

    final title = pickString(['title', 'headings']) ?? '';
    final body = pickString(['body', 'message', 'content', 'contents']) ?? '';
    final boldPart = pickString(['boldPart', 'highlight', 'subject']) ?? '';

    final dataRaw = root['data'];
    final dataMap = dataRaw is Map<String, dynamic> ? dataRaw : const <String, dynamic>{};
    final NotificationData data;
    if (dataMap.isNotEmpty) {
      data = NotificationData.fromJson(dataMap);
    } else {
      data = NotificationData.fromJson(root);
    }

    final rawCategory = data.category.isNotEmpty ? data.category : (pickString(['category', 'type', 'kind']) ?? 'generic');

    DateTime parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) {
        final parsed = DateTime.tryParse(v);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return AppNotification(
      id: (root['id'] ?? root['_id'] ?? root['notificationId'] ?? '').toString(),
      title: title,
      body: body,
      boldPart: boldPart,
      category: NotificationCategories.fromRaw(rawCategory),
      data: data,
      createdAt: parseDate(root['createdAt'] ?? root['created_at'] ?? root['timestamp']),
      isRead: root['isRead'] as bool? ??
          root['read'] as bool? ??
          root['is_read'] as bool? ??
          false,
    );
  }
}

extension NotificationCategoryX on NotificationCategory {
  IconData get icon {
    switch (this) {
      case NotificationCategory.appointment:
        return Icons.calendar_today_outlined;
      case NotificationCategory.medication:
        return Icons.medication_outlined;
      case NotificationCategory.emergency:
        return Icons.emergency_outlined;
      case NotificationCategory.healthReminder:
      case NotificationCategory.kickCountReminder:
        return Icons.monitor_heart_outlined;
      case NotificationCategory.mealplan:
        return Icons.restaurant_outlined;
      case NotificationCategory.order:
      case NotificationCategory.vendor:
      case NotificationCategory.promotion:
        return Icons.local_mall_outlined;
      case NotificationCategory.chat:
        return Icons.chat_bubble_outline;
      case NotificationCategory.milestone:
        return Icons.child_care_outlined;
      case NotificationCategory.community:
        return Icons.group_outlined;
      case NotificationCategory.generic:
        return Icons.notifications_outlined;
    }
  }
}