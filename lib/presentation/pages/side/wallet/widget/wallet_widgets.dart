import 'package:flutter/material.dart';
import 'package:mummymap/data/models/wallet_model.dart';


class TransactionTile extends StatelessWidget {
  final WalletTransaction tx;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.tx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            TransactionIcon(type: tx.type),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tx.formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              tx.formattedAmount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: tx.isCredit
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionIcon extends StatelessWidget {
  final TransactionType type;
  final double size;

  const TransactionIcon({
    super.key,
    required this.type,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type) {
      case TransactionType.deposit:
        icon = Icons.account_balance_outlined;
        break;
      case TransactionType.mealPlan:
        icon = Icons.shopping_bag_outlined;
        break;
      case TransactionType.doctorBooking:
        icon = Icons.medical_services_outlined;
        break;
      case TransactionType.transfer:
        icon = Icons.swap_horiz_outlined;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: const Color(0xFF3F2868), size: size * 0.5),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String label;

  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9E9E9E),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

String formatBalance(double value) {
  final formatted = value
      .toStringAsFixed(2)
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  return '₦$formatted';
}

Map<String, List<WalletTransaction>> groupByDate(
    List<WalletTransaction> transactions) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final Map<String, List<WalletTransaction>> grouped = {};

  for (final tx in transactions) {
    final txDay = DateTime(tx.date.year, tx.date.month, tx.date.day);
    String label;
    if (txDay == today) {
      label = 'TODAY';
    } else if (txDay == yesterday) {
      label = 'YESTERDAY';
    } else {
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      label = '${months[tx.date.month]} ${tx.date.year}';
    }
    grouped.putIfAbsent(label, () => []).add(tx);
  }
  return grouped;
}