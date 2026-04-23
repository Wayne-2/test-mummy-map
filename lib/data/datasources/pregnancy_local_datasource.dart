import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mummymap/data/models/pregnancy_model.dart';

class PregnancyLocalDataSource {
  static const _key = 'pregnancy_data';

  Future<PregnancyModel?> getPregnancy() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    return PregnancyModel.fromJson(jsonDecode(json));
  }

  Future<void> savePregnancy(PregnancyModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(model.toJson()));
  }
}