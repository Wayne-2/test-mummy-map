import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';

class SettingsState {
  final String firstName;
  final String lastName;
  final String? babySex;
  final String babyName;
  final String? firstChild;
  final bool babyAlreadyBorn;
  final bool reminders;
  final String lengthUnit;
  final String weightUnit;
  final int? age;
  final String relationship;
  final String email;
  final DateTime? dueDate;

  const SettingsState({
    this.firstName = '',
    this.lastName = '',
    this.babySex,
    this.babyName = '',
    this.firstChild,
    this.babyAlreadyBorn = false,
    this.reminders = false,
    this.lengthUnit = 'Inches (in)',
    this.weightUnit = 'Pounds (lbs)',
    this.age,
    this.relationship = 'Mother',
    this.email = '',
    this.dueDate,
  });

  String get fullName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? 'Mum' : full;
  }

  SettingsState copyWith({
    String? firstName,
    String? lastName,
    String? babySex,
    String? babyName,
    String? firstChild,
    bool? babyAlreadyBorn,
    bool? reminders,
    String? lengthUnit,
    String? weightUnit,
    int? age,
    String? relationship,
    String? email,
    DateTime? dueDate,
  }) {
    return SettingsState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      babySex: babySex ?? this.babySex,
      babyName: babyName ?? this.babyName,
      firstChild: firstChild ?? this.firstChild,
      babyAlreadyBorn: babyAlreadyBorn ?? this.babyAlreadyBorn,
      reminders: reminders ?? this.reminders,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      weightUnit: weightUnit ?? this.weightUnit,
      age: age ?? this.age,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final String _userId;

  SettingsNotifier(this._userId) : super(const SettingsState()) {
    _load();
  }

  String _key(String k) => '${_userId}_$k';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      firstName: prefs.getString(_key('firstName')) ?? '',
      lastName: prefs.getString(_key('lastName')) ?? '',
      babySex: prefs.getString(_key('babySex')),
      babyName: prefs.getString(_key('babyName')) ?? '',
      firstChild: prefs.getString(_key('firstChild')),
      babyAlreadyBorn: prefs.getBool(_key('babyAlreadyBorn')) ?? false,
      reminders: prefs.getBool(_key('reminders')) ?? false,
      lengthUnit: prefs.getString(_key('lengthUnit')) ?? 'Inches (in)',
      weightUnit: prefs.getString(_key('weightUnit')) ?? 'Pounds (lbs)',
      age: prefs.getInt(_key('age')),
      relationship: prefs.getString(_key('relationship')) ?? 'Mother',
      email: prefs.getString(_key('email')) ?? '',
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key('firstName'), state.firstName);
    await prefs.setString(_key('lastName'), state.lastName);
    if (state.babySex != null) await prefs.setString(_key('babySex'), state.babySex!);
    await prefs.setString(_key('babyName'), state.babyName);
    if (state.firstChild != null) {
      await prefs.setString(_key('firstChild'), state.firstChild!);
    }
    await prefs.setBool(_key('babyAlreadyBorn'), state.babyAlreadyBorn);
    await prefs.setBool(_key('reminders'), state.reminders);
    await prefs.setString(_key('lengthUnit'), state.lengthUnit);
    await prefs.setString(_key('weightUnit'), state.weightUnit);
    if (state.age != null) await prefs.setInt(_key('age'), state.age!);
    await prefs.setString(_key('relationship'), state.relationship);
    await prefs.setString(_key('email'), state.email);
  }

  void update(SettingsState newState) {
    state = newState;
    _save();
  }

  Future<void> clear() async {
    // Only clear the in-memory state, do not delete from SharedPreferences.
    // This allows the user's settings to be preserved for the next time they log in.
    state = const SettingsState();
  }

  void setFirstName(String v) { state = state.copyWith(firstName: v); _save(); }
  void setLastName(String v) { state = state.copyWith(lastName: v); _save(); }
  void setBabySex(String? v) { state = state.copyWith(babySex: v); _save(); }
  void setBabyName(String v) { state = state.copyWith(babyName: v); _save(); }
  void setFirstChild(String? v) { state = state.copyWith(firstChild: v); _save(); }
  void setBabyAlreadyBorn(bool v) { state = state.copyWith(babyAlreadyBorn: v); _save(); }
  void setReminders(bool v) { state = state.copyWith(reminders: v); _save(); }
  void setLengthUnit(String v) { state = state.copyWith(lengthUnit: v); _save(); }
  void setWeightUnit(String v) { state = state.copyWith(weightUnit: v); _save(); }
  void setAge(int? v) { state = state.copyWith(age: v); _save(); }
  void setRelationship(String v) { state = state.copyWith(relationship: v); _save(); }
  void setEmail(String v) { state = state.copyWith(email: v); _save(); }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final profile = ref.watch(profileProvider).value;
  final userId = profile?.userId ?? '';
  return SettingsNotifier(userId);
});