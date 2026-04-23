import 'package:mummymap/domain/entities/pregnancy.dart';

class PregnancyModel extends Pregnancy {
  const PregnancyModel({
    required super.dueDate,
    required super.calculationMethod,
    super.lastPeriodDate,
    super.conceptionDate,
  });

  factory PregnancyModel.fromJson(Map<String, dynamic> json) {
    return PregnancyModel(
      dueDate: DateTime.parse(json['due_date']),
      calculationMethod: json['calculation_method'],
      lastPeriodDate: json['last_period_date'] != null
          ? DateTime.parse(json['last_period_date'])
          : null,
      conceptionDate: json['conception_date'] != null
          ? DateTime.parse(json['conception_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'due_date': dueDate.toIso8601String(),
      'calculation_method': calculationMethod,
      'last_period_date': lastPeriodDate?.toIso8601String(),
      'conception_date': conceptionDate?.toIso8601String(),
    };
  }
}