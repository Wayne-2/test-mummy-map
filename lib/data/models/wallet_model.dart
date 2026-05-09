enum TransactionType { deposit, mealPlan, doctorBooking, transfer }

enum TransactionStatus { successful, pending, failed, reversed }

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

  bool get isCredit => amount > 0;

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
    final period = date.hour >= 12 ? 'PM' : 'AM';
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
}

final kWalletTransactions = <WalletTransaction>[
  WalletTransaction(
    id: 't1',
    type: TransactionType.deposit,
    status: TransactionStatus.successful,
    amount: 25000,
    date: DateTime(2025, 1, 10, 5, 24),
    description: 'Depositing Funds',
    senderDetails: 'KELLY KIRKLAND GRACE\nKuda MFB | 202****789',
    remark: 'Funds',
    transactionNo: '25100097846992736324 42',
    sessionId: '09078573624038475393338593',
    creditedTo: 'Available Balance',
    paymentMethod: 'Bank Deposit',
  ),
  WalletTransaction(
    id: 't2',
    type: TransactionType.mealPlan,
    status: TransactionStatus.successful,
    amount: -25000,
    date: DateTime(2025, 1, 10, 5, 24),
    description: 'Meal Plan Purchase',
    senderDetails: 'KELLY KIRKLAND GRACE\nKuda MFB | 202****789',
    transactionNo: '25100097846992736324 42',
    paymentMethod: 'Wallet',
  ),
  WalletTransaction(
    id: 't3',
    type: TransactionType.doctorBooking,
    status: TransactionStatus.successful,
    amount: -5000,
    date: DateTime(2025, 1, 10, 5, 24),
    description: 'Doctor Appointment Booking',
    senderDetails: 'KELLY KIRKLAND GRACE\nKuda MFB | 202****789',
    transactionNo: '25100097846992736324 42',
    paymentMethod: 'Wallet',
  ),
  WalletTransaction(
    id: 't4',
    type: TransactionType.deposit,
    status: TransactionStatus.successful,
    amount: 25000,
    date: DateTime(2025, 1, 10, 5, 24),
    description: 'Depositing Funds',
    senderDetails: 'KELLY KIRKLAND GRACE\nKuda MFB | 202****789',
    remark: 'Funds',
    transactionNo: '25100097846992736324 42',
    sessionId: '09078573624038475393338593',
    creditedTo: 'Available Balance',
    paymentMethod: 'Bank Deposit',
  ),
  WalletTransaction(
    id: 't5',
    type: TransactionType.mealPlan,
    status: TransactionStatus.successful,
    amount: -25000,
    date: DateTime(2025, 1, 10, 5, 24),
    description: 'Meal Plan Purchase',
    senderDetails: 'KELLY KIRKLAND GRACE\nKuda MFB | 202****789',
    transactionNo: '25100097846992736324 42',
    paymentMethod: 'Wallet',
  ),
  WalletTransaction(
    id: 't6',
    type: TransactionType.deposit,
    status: TransactionStatus.successful,
    amount: 25000,
    date: DateTime(2025, 1, 10, 5, 24),
    description: 'Depositing Funds',
    senderDetails: 'KELLY KIRKLAND GRACE\nKuda MFB | 202****789',
    remark: 'Funds',
    transactionNo: '25100097846992736324 42',
    sessionId: '09078573624038475393338593',
    creditedTo: 'Available Balance',
    paymentMethod: 'Bank Deposit',
  ),
  WalletTransaction(
    id: 't7',
    type: TransactionType.doctorBooking,
    status: TransactionStatus.successful,
    amount: -5000,
    date: DateTime(2025, 1, 10, 5, 24),
    description: 'Doctor Appointment Booking',
    senderDetails: 'KELLY KIRKLAND GRACE\nKuda MFB | 202****789',
    transactionNo: '25100097846992736324 42',
    paymentMethod: 'Wallet',
  ),
  WalletTransaction(
    id: 't8',
    type: TransactionType.deposit,
    status: TransactionStatus.successful,
    amount: 25000,
    date: DateTime(2025, 1, 9, 5, 24),
    description: 'Depositing Funds',
    senderDetails: 'KELLY KIRKLAND GRACE\nKuda MFB | 202****789',
    remark: 'Funds',
    transactionNo: '25100097846992736324 42',
    sessionId: '09078573624038475393338593',
    creditedTo: 'Available Balance',
    paymentMethod: 'Bank Deposit',
  ),
  WalletTransaction(
    id: 't9',
    type: TransactionType.mealPlan,
    status: TransactionStatus.successful,
    amount: -25000,
    date: DateTime(2025, 1, 9, 5, 24),
    description: 'Meal Plan Purchase',
    senderDetails: 'KELLY KIRKLAND GRACE\nKuda MFB | 202****789',
    transactionNo: '25100097846992736324 42',
    paymentMethod: 'Wallet',
  ),
  WalletTransaction(
    id: 't10',
    type: TransactionType.transfer,
    status: TransactionStatus.successful,
    amount: -518000,
    date: DateTime(2025, 10, 8, 10, 21, 50),
    description: "Transfer to Chef Chi's Kitchen",
    senderDetails: 'KELLY KIRKLAND GRACE\nKuda MFB | 202****789',
    transactionNo: '25100097846992736324 42',
    paymentMethod: 'Wallet',
  ),
];

const double kWalletBalance = 26678.00;