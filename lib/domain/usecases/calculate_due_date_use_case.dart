class CalculateDueDateUseCase {
  DateTime call({
    required String method,
    required DateTime date,
  }) {
    switch (method) {
      case 'First Day Of Last Period':
        return date.add(const Duration(days: 280));
      case 'Date Of Conception':
        return date.add(const Duration(days: 266));
      case 'Estimated Due Date':
      default:
        return date;
    }
  }
}