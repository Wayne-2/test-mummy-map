import 'dart:math' as math;

class ProfileModel {
  final String? id;
  final String? userId;
  final String? email;
  final String? profileImage;

  final String? firstName;
  final String? lastName;
  final String? handle;

  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final String? location;
  final String? country;
  final String? state;
  final String? city;

  final int? heightCm;
  final int? weightKg;

  final bool? isPregnant;
  final DateTime? dueDate;
  final int? pregnancyWeek;
  final int? numberOfChildren;

  final int? postsCount;
  final int? followersCount;
  final int? followingCount;
  final bool? isVerified;

  ProfileModel({
    this.id,
    this.userId,
    this.email,
    this.profileImage,
    this.firstName,
    this.lastName,
    this.handle,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.location,
    this.country,
    this.state,
    this.city,
    this.heightCm,
    this.weightKg,
    this.isPregnant,
    this.dueDate,
    this.pregnancyWeek,
    this.numberOfChildren,
    this.postsCount,
    this.followersCount,
    this.followingCount,
    this.isVerified,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    DateTime? parseDate(dynamic v) =>
        (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;

    return ProfileModel(
      id: root['id'] as String?,
      userId: root['userId'] as String?,
      email: root['user'] is Map ? root['user']['email'] as String? : null,
      profileImage: root['profileImage'] as String?,
      firstName: (root['firstName'] ?? root['first_name']) as String?,
      lastName: (root['lastName'] ?? root['last_name']) as String?,
      handle: root['handle'] as String?,
      dateOfBirth: parseDate(root['dateOfBirth']),
      gender: root['gender'] as String?,
      bloodType: root['bloodType'] as String?,
      location: root['location'] as String?,
      country: root['country'] as String?,
      state: root['state'] as String?,
      city: root['city'] as String?,
      heightCm: (root['heightCm'] as num?)?.toInt(),
      weightKg: (root['weightKg'] as num?)?.toInt(),
      isPregnant: root['isPregnant'] as bool?,
      dueDate: parseDate(root['dueDate']),
      pregnancyWeek: (root['pregnancyWeek'] as num?)?.toInt(),
      numberOfChildren: (root['numberOfChildren'] as num?)?.toInt(),
      postsCount: (root['postsCount'] as num?)?.toInt(),
      followersCount: (root['followersCount'] as num?)?.toInt(),
      followingCount: (root['followingCount'] as num?)?.toInt(),
      isVerified: root['isVerified'] as bool?,
    );
  }

  Map<String, dynamic> toCreateJson() {
    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'handle': handle,
      'dateOfBirth': dateOfBirth?.toUtc().toIso8601String(),
      'gender': gender,
      'bloodType': bloodType,
      'location': location,
      'country': country,
      'state': state,
      'city': city,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'isPregnant': isPregnant,
      'dueDate': dueDate?.toUtc().toIso8601String(),
      'pregnancyWeek': (pregnancyWeek != null && pregnancyWeek! > 0)
          ? pregnancyWeek
          : null,
      'numberOfChildren': numberOfChildren,
    };
    map.removeWhere((_, value) => value == null || value == '');
    return map;
  }

  Map<String, dynamic> toUpdateJson() {
    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toUtc().toIso8601String(),
      'gender': gender,
      'bloodType': bloodType,
      'location': location,
      'country': country,
      'state': state,
      'city': city,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'isPregnant': isPregnant,
      'dueDate': dueDate?.toUtc().toIso8601String(),
      'pregnancyWeek': (pregnancyWeek != null && pregnancyWeek! > 0)
          ? pregnancyWeek
          : null,
      'numberOfChildren': numberOfChildren,
    };
    map.removeWhere((_, value) => value == null || value == '');
    return map;
  }

  ProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? handle,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    bool? isPregnant,
    DateTime? dueDate,
    int? pregnancyWeek,
    int? numberOfChildren,
  }) {
    return ProfileModel(
      id: id,
      userId: userId,
      email: email,
      profileImage: profileImage,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      handle: handle ?? this.handle,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      location: location,
      country: country,
      state: state,
      city: city,
      heightCm: heightCm,
      weightKg: weightKg,
      isPregnant: isPregnant ?? this.isPregnant,
      dueDate: dueDate ?? this.dueDate,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      postsCount: postsCount,
      followersCount: followersCount,
      followingCount: followingCount,
      isVerified: isVerified,
    );
  }
}

class ProfileMappers {
  ProfileMappers._();

  static String? handleFromName(String? first, String? last) {
    final base = '${first ?? ''}${last ?? ''}'.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );
    if (base.isEmpty) return null;
    final ms = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final rand = math.Random().nextInt(90000) + 10000; // 5 digits
    return '$base${ms}$rand';
  }

  static String? bloodTypeToApi(String? display) {
    if (display == null) return null;
    const map = {
      'A+': 'A_POSITIVE',
      'A-': 'A_NEGATIVE',
      'B+': 'B_POSITIVE',
      'B-': 'B_NEGATIVE',
      'AB+': 'AB_POSITIVE',
      'AB-': 'AB_NEGATIVE',
      'O+': 'O_POSITIVE',
      'O-': 'O_NEGATIVE',
    };
    return map[display];
  }

  static String? bloodTypeToDisplay(String? api) {
    if (api == null) return null;
    const map = {
      'A_POSITIVE': 'A+',
      'A_NEGATIVE': 'A-',
      'B_POSITIVE': 'B+',
      'B_NEGATIVE': 'B-',
      'AB_POSITIVE': 'AB+',
      'AB_NEGATIVE': 'AB-',
      'O_POSITIVE': 'O+',
      'O_NEGATIVE': 'O-',
    };
    return map[api];
  }

  static int? firstChildToCount(String? firstChild) {
    if (firstChild == null) return null;
    return firstChild.toLowerCase() == 'yes' ? 0 : 1;
  }

}