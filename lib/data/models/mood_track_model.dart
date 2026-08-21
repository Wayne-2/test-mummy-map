class MoodType {
  MoodType._();

  static const values = [
    'HAPPY',
    'SAD',
    'ANXIOUS',
    'CALM',
    'IRRITABLE',
    'EXCITED',
    'TIRED',
    'OVERWHELMED',
    'GRATEFUL',
    'OTHER',
  ];

  static const _uiToEnum = {
    'Happy': 'HAPPY',
    'Sad': 'SAD',
    'Anxious': 'ANXIOUS',
    'Excited': 'EXCITED',
    'Angry': 'IRRITABLE',
    'Inspired': 'GRATEFUL',
    'Calm': 'CALM',
    'Tired': 'TIRED',
    'Overwhelmed': 'OVERWHELMED',
    'Grateful': 'GRATEFUL',
  };

  static String fromUiLabel(String label) {
    final direct = _uiToEnum[label];
    if (direct != null) return direct;
    final upper = label.toUpperCase();
    return values.contains(upper) ? upper : 'OTHER';
  }

  static String display(String raw) {
    if (raw.isEmpty) return '';
    return '${raw[0].toUpperCase()}${raw.substring(1).toLowerCase()}';
  }
}

class MoodLog {
  final String? id;
  final String mood;
  final String? notes;
  final DateTime loggedAt;
  final bool isPendingSync;

  const MoodLog({
    this.id,
    required this.mood,
    this.notes,
    required this.loggedAt,
    this.isPendingSync = false,
  });

  factory MoodLog.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    DateTime parseDate() {
      for (final k in ['loggedAt', 'recordedAt', 'date', 'createdAt']) {
        final v = root[k];
        if (v is String && v.isNotEmpty) {
          final d = DateTime.tryParse(v);
          if (d != null) return d.toLocal();
        }
      }
      return DateTime.now();
    }

    return MoodLog(
      id: root['id']?.toString() ?? root['_id']?.toString(),
      mood: (root['mood'] ?? 'OTHER').toString(),
      notes: root['notes'] as String?,
      loggedAt: parseDate(),
      isPendingSync: root['isPendingSync'] == true,
    );
  }

  Map<String, dynamic> toCreateJson() {
    final map = <String, dynamic>{
      'mood': mood,
      'notes': notes,
      'loggedAt': loggedAt.toUtc().toIso8601String(),
    };
    map.removeWhere((_, v) => v == null || v == '');
    return map;
  }

  Map<String, dynamic> toStorageJson() => {
        ...toCreateJson(),
        if (id != null) 'id': id,
        'isPendingSync': isPendingSync,
      };

  MoodLog copyWith({String? id, bool? isPendingSync}) => MoodLog(
        id: id ?? this.id,
        mood: mood,
        notes: notes,
        loggedAt: loggedAt,
        isPendingSync: isPendingSync ?? this.isPendingSync,
      );
}