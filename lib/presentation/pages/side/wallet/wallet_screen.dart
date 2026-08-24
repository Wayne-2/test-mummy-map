import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:mummymap/presentation/providers/wallet_provider.dart';
import 'package:mummymap/presentation/pages/side/wallet/paystack_checkout_screen.dart';
import 'package:mummymap/presentation/pages/side/wallet/widget/wallet_widgets.dart';
import 'transactions_screen.dart';
import 'transaction_detail_screen.dart';
import 'wallet_balance_details_screen.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(context),
                    const SizedBox(height: 24),
                    _buildTransactionHistory(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE8D5F5),
                child: Icon(Icons.person, color: Color(0xFF3F2868), size: 22),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo3.png',
                height: 28,
                width: 28,
                errorBuilder: (_, __, ___) =>
                    const SizedBox(width: 28, height: 28),
              ),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Mummy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F2868),
                      ),
                    ),
                    TextSpan(
                      text: 'map',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BCD4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final balanceAsync = ref.watch(walletBalanceProvider);
    // Handle loading/error explicitly – previous `value ?? 0` hid errors and caused blank screen on 401
    if (balanceAsync.hasError) {
      final err = balanceAsync.error.toString();
      // Log for debug, show retry UI inline
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4A1878), Color(0xFF2D0F4E), Color(0xFF6B3A9E)]),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white70, size: 28),
            const SizedBox(height: 8),
            const Text('Could not load balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(err.length > 80 ? '${err.substring(0, 80)}...' : err, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => ref.invalidate(walletBalanceProvider), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Color(0xFF3F2868)), child: const Text('Retry')),
          ]),
        ),
      );
    }
    if (balanceAsync.isLoading && balanceAsync.value == null) {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4A1878), Color(0xFF2D0F4E), Color(0xFF6B3A9E)])),
        child: const Padding(padding: EdgeInsets.fromLTRB(24, 48, 24, 48), child: Center(child: CircularProgressIndicator(color: Colors.white))),
      );
    }
    final _balance = balanceAsync.value ?? 0.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A1878),
            Color(0xFF2D0F4E),
            Color(0xFF6B3A9E),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Column(
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WalletBalanceDetailsScreen(
                      balance: _balance),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _balanceVisible
                        ? formatBalance(_balance)
                        : '₦ ••••••',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(
                        () => _balanceVisible = !_balanceVisible),
                    child: Icon(
                      _balanceVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white60,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Wallet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _HeroButton(
                    icon: Icons.add_circle_outline,
                    label: 'Deposit',
                    onTap: () => _showDepositSheet(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeroButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transactions',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransactionsScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    final txAsync = ref.watch(walletTransactionsProvider);
    if (txAsync.isLoading && txAsync.value == null) {
      return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: Color(0xFF3F2868))));
    }
    if (txAsync.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Transaction History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          Text('Failed to load: ${txAsync.error}', style: const TextStyle(color: Colors.red, fontSize: 12)),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => ref.invalidate(walletTransactionsProvider), child: const Text('Retry')),
        ]),
      );
    }
    final transactions = txAsync.value ?? [];
    final preview = transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TransactionsScreen(),
                  ),
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3F2868),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...preview.map((tx) => Column(
              children: [
                TransactionTile(
                  tx: tx,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailScreen(tx: tx),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF5F5F5)),
              ],
            )),
      ],
    );
  }

  void _showDepositSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => _DepositSheet(
        onDeposit: (amount) async {
          // Close sheet first to avoid Navigator race when pushing checkout
          Navigator.pop(sheetCtx);
          final idempotencyKey = const Uuid().v4();

          final notifier = ref.read(walletNotifierProvider.notifier);
          final result = await notifier.initiateTopup(
            amountNgn: amount,
            idempotencyKey: idempotencyKey,
          );

          final notifierState = ref.read(walletNotifierProvider);
          final errMsg = notifierState is AsyncError ? (notifierState.error.toString()) : null;

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
                  const SnackBar(content: Text('Payment verified successfully!'), backgroundColor: Colors.green),
                );
              }
            } else if (success == false) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errMsg ?? 'Payment was not completed. ${errMsg ?? ""}')),
                );
              }
            }
          } else {
            if (mounted) {
              final msg = errMsg ?? '';
              // Show specific error (e.g., Minimum top-up is ₦100, or 401, or network)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg.isNotEmpty ? 'Failed to initiate topup: $msg' : 'Failed to initiate topup – check connection/login'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeroButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositSheet extends StatefulWidget {
  final Future<void> Function(double) onDeposit;

  const _DepositSheet({required this.onDeposit});

  @override
  State<_DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<_DepositSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
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
              'Deposit Funds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter amount to add to your wallet',
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
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
                        final amount = double.tryParse(_controller.text) ?? 0;
                        if (amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount (min ₦100)')));
                          return;
                        }
                        if (amount < 100) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum top-up is ₦100')));
                          return;
                        }
                        setState(() => _isLoading = true);
                        await widget.onDeposit(amount);
                        if (mounted) setState(() => _isLoading = false);
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