import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:mummymap/presentation/providers/wallet_provider.dart';
import 'package:mummymap/presentation/pages/side/wallet/paystack_checkout_screen.dart';
import 'package:mummymap/presentation/pages/side/wallet/widget/wallet_widgets.dart';
import 'transaction_detail_screen.dart';

class WalletBalanceDetailsScreen extends ConsumerStatefulWidget {
  final double balance;

  const WalletBalanceDetailsScreen({super.key, required this.balance});

  @override
  ConsumerState<WalletBalanceDetailsScreen> createState() =>
      _WalletBalanceDetailsScreenState();
}

class _WalletBalanceDetailsScreenState
    extends ConsumerState<WalletBalanceDetailsScreen> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(walletTransactionsProvider);
    final transactions = txAsync.value ?? [];
    final grouped = groupByDate(transactions);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                children: [
                  _buildBalanceCard(context),
                  const SizedBox(height: 8),
                  for (final entry in grouped.entries) ...[
                    SectionLabel(label: entry.key),
                    for (final tx in entry.value)
                      Column(
                        children: [
                          TransactionTile(
                            tx: tx,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TransactionDetailScreen(tx: tx),
                              ),
                            ),
                          ),
                          const Divider(
                              height: 1, color: Color(0xFFF5F5F5)),
                        ],
                      ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Wallet Balance Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final balanceAsync = ref.watch(walletBalanceProvider);
    final currentBalance = balanceAsync.value ?? widget.balance;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          const Text(
            'Wallet Balance',
            style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _balanceVisible
                    ? formatBalance(currentBalance)
                    : '₦ ••••••',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () =>
                    setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF9E9E9E),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _showAddMoneySheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F2868),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text(
                'Add Money',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMoneySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddMoneySheet(
        onDeposit: (amount) async {
          final idempotencyKey = const Uuid().v4();
          
          final result = await ref.read(walletNotifierProvider.notifier).initiateTopup(
            amountNgn: amount,
            idempotencyKey: idempotencyKey,
          );
          
          if (result != null && result.authorizationUrl.isNotEmpty) {
            final reference =
                result.reference.isNotEmpty ? result.reference : idempotencyKey;
            final success = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => PaystackCheckoutScreen(
                  authorizationUrl: result.authorizationUrl,
                  fallbackReference: reference,
                  verify: (r) => ref
                      .read(walletNotifierProvider.notifier)
                      .verifyTopup(r),
                ),
              ),
            );
            if (success == true) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Payment verified successfully!')),
                );
              }
            } else if (success == false) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Payment was not completed.')),
                );
              }
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to initiate topup')),
              );
            }
          }
        },
      ),
    );
  }
}

class _AddMoneySheet extends StatefulWidget {
  final Future<void> Function(double) onDeposit;

  const _AddMoneySheet({required this.onDeposit});

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Add Money',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter amount to deposit into your wallet',
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  fontSize: 16, color: Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                hintText: '₦0.00',
                hintStyle: const TextStyle(
                    color: Color(0xFFBDBDBD), fontSize: 16),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF3F2868), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final amount = double.tryParse(_amountController.text) ?? 0;
                        if (amount <= 0) return;
                        setState(() => _isLoading = true);
                        await widget.onDeposit(amount);
                        if (mounted) {
                          setState(() => _isLoading = false);
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F2868),
                  disabledBackgroundColor: const Color(0xFF3F2868),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Proceed',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}