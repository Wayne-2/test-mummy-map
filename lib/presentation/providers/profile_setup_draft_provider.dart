import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupDraft {
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? bloodGroupDisplay;
  final String? firstChild;
  final DateTime? dueDate;
  final String? imagePath;

  const ProfileSetupDraft({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.bloodGroupDisplay,
    this.firstChild,
    this.dueDate,
    this.imagePath,
  });

  ProfileSetupDraft copyWith({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? bloodGroupDisplay,
    String? firstChild,
    DateTime? dueDate,
    String? imagePath,
  }) {
    return ProfileSetupDraft(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroupDisplay: bloodGroupDisplay ?? this.bloodGroupDisplay,
      firstChild: firstChild ?? this.firstChild,
      dueDate: dueDate ?? this.dueDate,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class ProfileSetupDraftNotifier extends StateNotifier<ProfileSetupDraft> {
  ProfileSetupDraftNotifier() : super(const ProfileSetupDraft());

  void setName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return;
    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first;
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    state = state.copyWith(firstName: first, lastName: last);
  }

  void setDateOfBirth(DateTime v) =>
      state = state.copyWith(dateOfBirth: v);
  void setBloodGroup(String? v) =>
      state = state.copyWith(bloodGroupDisplay: v);
  void setFirstChild(String? v) => state = state.copyWith(firstChild: v);
  void setDueDate(DateTime v) => state = state.copyWith(dueDate: v);
  void setImagePath(String v) => state = state.copyWith(imagePath: v);

  void reset() => state = const ProfileSetupDraft();
}

final profileSetupDraftProvider =
    StateNotifierProvider<ProfileSetupDraftNotifier, ProfileSetupDraft>(
  (_) => ProfileSetupDraftNotifier(),
);