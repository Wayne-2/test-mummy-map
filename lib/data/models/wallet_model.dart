enum TransactionType { deposit, mealPlan, doctorBooking, transfer }

enum TransactionStatus { successful, pending, failed, reversed }

class TopUpInitiation {
  final String reference;
  final int amount;
  final String currency;
  final String authorizationUrl;
  final String accessCode;

  const TopUpInitiation({
    required this.reference,
    required this.amount,
    required this.currency,
    required this.authorizationUrl,
    required this.accessCode,
  });

  factory TopUpInitiation.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    return TopUpInitiation(
      reference: root['reference']?.toString() ?? '',
      amount: int.tryParse(root['amount']?.toString() ?? '0') ?? 0,
      currency: root['currency']?.toString() ?? 'NGN',
      authorizationUrl: root['authorizationUrl']?.toString() ?? '',
      accessCode: root['accessCode']?.toString() ?? '',
    );
  }
}

class WalletTransaction {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final DateTime date;
  final String description;
  final String? senderDetails;
  final String? remark;
  final String? transactionNo;
  final String? sessionId;
  final String? paymentMethod;
  final String? creditedTo;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.date,
    required this.description,
    this.senderDetails,
    this.remark,
    this.transactionNo,
    this.sessionId,
    this.paymentMethod,
    this.creditedTo,
  });

  bool get isCredit => type == TransactionType.deposit;

  String get formattedAmount {
    final abs = amount.abs();
    final formatted = abs
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return isCredit ? '+₦$formatted' : '-₦$formatted';
  }

  String get formattedDate {
    final h = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;
    final m = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '$h:$m $period, ${date.day} ${months[date.month]} ${date.year.toString().substring(2)}';
  }

  String get detailDate {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final h = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;
    final m = date.minute.toString().padLeft(2, '0');
    return '${months[date.month]} ${_ordinal(date.day)}, ${date.year} $h:$m:${date.second.toString().padLeft(2, '0')}';
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      type: _parseType(json['type']?.toString()),
      status: _parseStatus(json['status']?.toString()),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: _parseDate(json),
      description: json['description']?.toString() ?? '',
      senderDetails: json['senderDetails']?.toString(),
      remark: json['remark']?.toString(),
      transactionNo: json['transactionNo']?.toString(),
      sessionId: json['sessionId']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      creditedTo: json['creditedTo']?.toString(),
    );
  }

  static TransactionType _parseType(String? t) {
    if (t == null) return TransactionType.transfer;
    final lower = t.toLowerCase();
    if (lower.contains('meal')) return TransactionType.mealPlan;
    if (lower.contains('doctor') || lower.contains('appointment')) return TransactionType.doctorBooking;
    if (lower.contains('credit') || lower.contains('deposit') || lower.contains('topup')) return TransactionType.deposit;
    return TransactionType.transfer;
  }

  static DateTime _parseDate(Map<String, dynamic> json) {
    for (final k in const ['createdAt', 'created_at', 'date', 'timestamp']) {
      final v = json[k];
      if (v != null) {
        final parsed = DateTime.tryParse(v.toString());
        if (parsed != null) return parsed;
      }
    }
    return DateTime.now();
  }

  static TransactionStatus _parseStatus(String? s) {
    if (s == null) return TransactionStatus.pending;
    final lower = s.toLowerCase();
    if (lower.contains('success')) return TransactionStatus.successful;
    if (lower.contains('fail')) return TransactionStatus.failed;
    if (lower.contains('revers')) return TransactionStatus.reversed;
    return TransactionStatus.pending;
  }
}