import 'dart:convert';
import 'package:hive/hive.dart';

class GroupLocalDatasource {
  static const String _groupsBox = 'groups_box';

  GroupLocalDatasource();

  Future<void> saveGroups(String userId, List<Map<String, dynamic>> groups) async {
    final box = Hive.box<String>(_groupsBox);
    await box.put('joined_groups_$userId', jsonEncode(groups));
  }

  Future<List<Map<String, dynamic>>?> getLocalGroups(String userId) async {
    final box = Hive.box<String>(_groupsBox);
    final data = box.get('joined_groups_$userId');
    if (data == null) return null;
    try {
      final List decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  Future<void> clearGroups(String userId) async {
    final box = Hive.box<String>(_groupsBox);
    await box.delete('joined_groups_$userId');
  }

  Future<void> saveGroupPosts(String userId, String groupId, List<Map<String, dynamic>> posts) async {
    final box = Hive.box<String>(_groupsBox);
    await box.put('posts_${groupId}_$userId', jsonEncode(posts));
  }

  Future<List<Map<String, dynamic>>?> getLocalGroupPosts(String userId, String groupId) async {
    final box = Hive.box<String>(_groupsBox);
    final data = box.get('posts_${groupId}_$userId');
    if (data == null) return null;
    try {
      final List decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  Future<void> clearGroupPosts(String userId, String groupId) async {
    final box = Hive.box<String>(_groupsBox);
    await box.delete('posts_${groupId}_$userId');
  }

  Future<void> saveBookmarks(String userId, List<String> bookmarks) async {
    final box = Hive.box<String>(_groupsBox);
    await box.put('bookmarks_$userId', jsonEncode(bookmarks));
  }

  Future<List<String>> getBookmarks(String userId) async {
    final box = Hive.box<String>(_groupsBox);
    final data = box.get('bookmarks_$userId');
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.cast<String>();
    } catch (_) {
      return [];
    }
  }
}
