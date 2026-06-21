import 'dart:convert';
import 'package:hive/hive.dart';

class GroupLocalDatasource {
  static const String _groupsBox = 'groups_box';

  GroupLocalDatasource();

  Future<void> saveGroups(List<Map<String, dynamic>> groups) async {
    final box = Hive.box<String>(_groupsBox);
    await box.put('joined_groups', jsonEncode(groups));
  }

  Future<List<Map<String, dynamic>>?> getLocalGroups() async {
    final box = Hive.box<String>(_groupsBox);
    final data = box.get('joined_groups');
    if (data == null) return null;
    try {
      final List decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveGroupPosts(String groupId, List<Map<String, dynamic>> posts) async {
    final box = Hive.box<String>(_groupsBox);
    await box.put('posts_$groupId', jsonEncode(posts));
  }

  Future<List<Map<String, dynamic>>?> getLocalGroupPosts(String groupId) async {
    final box = Hive.box<String>(_groupsBox);
    final data = box.get('posts_$groupId');
    if (data == null) return null;
    try {
      final List decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }
}
