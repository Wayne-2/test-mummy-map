class Pregnancy {
  final DateTime dueDate;
  final DateTime? lastPeriodDate;
  final DateTime? conceptionDate;
  final String calculationMethod;

  const Pregnancy({
    required this.dueDate,
    required this.calculationMethod,
    this.lastPeriodDate,
    this.conceptionDate,
  });

  int get currentDay {
    final startDate = dueDate.subtract(const Duration(days: 280));
    return DateTime.now().difference(startDate).inDays.clamp(0, 280);
  }

  int get currentWeek => (currentDay / 7).floor().clamp(0, 40);

  int get trimester {
    if (currentWeek <= 13) return 1;
    if (currentWeek <= 26) return 2;
    return 3;
  }

  String get trimesterLabel {
    switch (trimester) {
      case 1:
        return '1st Trimester';
      case 2:
        return '2nd Trimester';
      default:
        return '3rd Trimester';
    }
  }
}