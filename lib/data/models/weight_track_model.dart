const double kgPerLb = 0.45359237;

double lbToKg(double lb) => lb * kgPerLb;
double kgToLb(double kg) => kg / kgPerLb;

class WeightLog {
  final String? id;
  final double weightKg;
  final DateTime recordedAt;
  final int? week;
  final String? notes;
  final bool isPendingSync;

  const WeightLog({
    this.id,
    required this.weightKg,
    required this.recordedAt,
    this.week,
    this.notes,
    this.isPendingSync = false,
  });

  double get weightLb => kgToLb(weightKg);

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    num? pickNum(List<String> keys) {
      for (final k in keys) {
        final v = root[k];
        if (v is num) return v;
        if (v is String) {
          final parsed = num.tryParse(v);
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    DateTime parseDate() {
      for (final k in ['recordedAt', 'date', 'loggedAt', 'createdAt', 'sessionAt']) {
        final v = root[k];
        if (v is String && v.isNotEmpty) {
          final d = DateTime.tryParse(v);
          if (d != null) return d.toLocal();
        }
      }
      return DateTime.now();
    }

    return WeightLog(
      id: root['id']?.toString() ?? root['_id']?.toString(),
      weightKg: (pickNum(['weightKg', 'weight', 'valueKg', 'value']) ?? 0)
          .toDouble(),
      recordedAt: parseDate(),
      week: pickNum(['week', 'pregnancyWeek'])?.toInt(),
      notes: root['notes'] as String?,
      isPendingSync: root['isPendingSync'] == true,
    );
  }

  Map<String, dynamic> toCreateJson() {
    final map = <String, dynamic>{
      'weightKg': double.parse(weightKg.toStringAsFixed(2)),
      'recordedAt': recordedAt.toUtc().toIso8601String(),
      'week': week,
      'notes': notes,
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }

  Map<String, dynamic> toStorageJson() => {
        ...toCreateJson(),
        if (id != null) 'id': id,
        'isPendingSync': isPendingSync,
      };

  WeightLog copyWith({String? id, bool? isPendingSync}) => WeightLog(
        id: id ?? this.id,
        weightKg: weightKg,
        recordedAt: recordedAt,
        week: week,
        notes: notes,
        isPendingSync: isPendingSync ?? this.isPendingSync,
      );
}
