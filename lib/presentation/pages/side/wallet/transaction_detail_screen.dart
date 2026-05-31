import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mummymap/data/models/wallet_model.dart';
import 'package:mummymap/presentation/pages/side/wallet/widget/wallet_widgets.dart';

class TransactionDetailScreen extends StatelessWidget {
  final WalletTransaction tx;

  const TransactionDetailScreen({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDeposit = tx.type == TransactionType.deposit;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 16),
                    _buildDetailsCard(isDeposit),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context, isDeposit),
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
            'Transaction Details',
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

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          TransactionIcon(type: tx.type, size: 48),
          const SizedBox(height: 12),
          Text(
            tx.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatBalance(tx.amount.abs()),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  color: Color(0xFF2E7D32), size: 16),
              const SizedBox(width: 6),
              Text(
                tx.status.name[0].toUpperCase() +
                    tx.status.name.substring(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(bool isDeposit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          if (isDeposit && tx.creditedTo != null)
            _DetailRow(
              label: 'Credited to',
              value: tx.creditedTo!,
              isLink: true,
            ),
          if (tx.senderDetails != null)
            _DetailRow(
              label: 'Sender Details',
              value: tx.senderDetails!,
            ),
          if (tx.remark != null)
            _DetailRow(label: 'Remark', value: tx.remark!),
          if (isDeposit)
            _DetailRow(
                label: 'Transaction Type',
                value: tx.paymentMethod ?? 'Bank Deposit'),
          if (tx.transactionNo != null)
            _DetailRow(
              label: 'Transaction No.',
              value: tx.transactionNo!,
              canCopy: true,
            ),
          _DetailRow(label: 'Transaction Date', value: tx.detailDate),
          if (!isDeposit && tx.paymentMethod != null)
            _DetailRow(
              label: 'Payment Method',
              value: tx.paymentMethod!,
              isLink: true,
            ),
          if (isDeposit && tx.sessionId != null)
            _DetailRow(
              label: 'Session ID',
              value: tx.sessionId!,
              canCopy: true,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDeposit) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 12,
      ),
      child: Row(
        children: [
          if (!isDeposit) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Report Issue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: isDeposit ? 1 : 2,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShareReceiptScreen(tx: tx),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F2868),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text(
                'Share Receipt',
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
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLink;
  final bool canCopy;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLink = false,
    this.canCopy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isLink
                          ? const Color(0xFF3F2868)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                if (isLink)
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF3F2868), size: 16),
                if (canCopy) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Icon(Icons.copy_outlined,
                        size: 14, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShareReceiptScreen extends StatelessWidget {
  final WalletTransaction tx;

  const ShareReceiptScreen({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Share Receipt',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ReceiptCard(tx: tx),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 12,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F2868),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Download Receipt',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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

class _ReceiptCard extends StatelessWidget {
  final WalletTransaction tx;

  const _ReceiptCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ReceiptPainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '✦  Mummy ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3F2868),
                        ),
                      ),
                      TextSpan(
                        text: 'Map',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3F2868),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'Transaction Receipt',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                formatBalance(tx.amount.abs()),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Successful',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                tx.detailDate,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),
            if (tx.creditedTo != null) ...[
              _ReceiptRow(
                label: 'Receipt Details',
                value: 'KELLY KIRKLAND GRACE\nPaystack | 202****789',
              ),
              _ReceiptRow(
                label: 'Sender Details',
                value: tx.senderDetails ?? '',
              ),
            ] else
              _ReceiptRow(
                label: 'Sender Details',
                value: tx.senderDetails ?? '',
              ),
            _ReceiptRow(
              label: 'Transaction Type',
              value: tx.paymentMethod ?? '',
            ),
            if (tx.transactionNo != null)
              _ReceiptRow(
                label: 'Transaction No.',
                value: tx.transactionNo!,
              ),
            if (tx.sessionId != null)
              _ReceiptRow(
                label: 'Session ID',
                value: tx.sessionId!,
              ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5EEFF)
      ..style = PaintingStyle.fill;

    final path = Path();
    const radius = 12.0;
    const notchRadius = 12.0;
    final notchY = size.height - 32.0;

    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, notchY - notchRadius);
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, notchY + notchRadius);
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    canvas.drawPath(path, paint);

    final dashPaint = Paint()
      ..color = const Color(0xFFE0C8FF)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double x = 0;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, notchY),
        Offset(x + dashWidth, notchY),
        dashPaint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_ReceiptPainter old) => false;
}