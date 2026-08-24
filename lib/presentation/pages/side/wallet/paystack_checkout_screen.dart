import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaystackCheckoutScreen extends StatefulWidget {
  final String authorizationUrl;
  final String fallbackReference;
  final Future<bool> Function(String reference) verify;

  const PaystackCheckoutScreen({
    super.key,
    required this.authorizationUrl,
    required this.fallbackReference,
    required this.verify,
  });

  @override
  State<PaystackCheckoutScreen> createState() => _PaystackCheckoutScreenState();
}

class _PaystackCheckoutScreenState extends State<PaystackCheckoutScreen> {
  late final WebViewController _controller;
  bool _handled = false;
  bool _loading = true;
  bool _failed = false;
  bool _verifying = false;
  String? _lastUrl;

  @override
  void initState() {
    super.initState();
    if (widget.authorizationUrl.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid payment URL – missing authorizationUrl')),
        );
        Navigator.of(context).pop(false);
      });
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _lastUrl = url;
            _handleUrl(url);
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (url) {
            _lastUrl = url;
            _handleUrl(url);
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (err) {
            // Ignore errors on blank/paystack checkout iframe loads
            if (mounted && _lastUrl != null && _lastUrl!.contains('paystack')) return;
            if (mounted) setState(() => _failed = true);
          },
          onNavigationRequest: (nav) {
            _handleUrl(nav.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  Future<void> _handleUrl(String url) async {
    if (_handled) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    // Paystack close/success pages often look like:
    // https://standard.paystack.co/close?reference=xxx
    // https://checkout.paystack.com/success?trxref=xxx&reference=xxx
    // or backend callback: https://mummymap-be-staging.up.railway.app/api/v1/wallet/callback?reference=xxx
    // We check ANY url that contains reference/trxref, regardless of host

    final hasRef = uri.queryParameters.containsKey('reference') ||
        uri.queryParameters.containsKey('trxref') ||
        url.contains('reference=') ||
        url.contains('trxref=');

    // Also detect Paystack "close" or backend redirect that may not have query but indicates success
    final isPaystackClose = uri.host.contains('paystack') && url.contains('close');
    final isCallback = url.contains('/wallet/') || url.contains('callback') || url.contains('verify');

    // Ignore intermediate paystack checkout loads without reference
    if (!hasRef && !isPaystackClose && !isCallback) {
      // Special case: about:blank or checkout host without ref -> definitely ignore
      if (uri.host == 'checkout.paystack.com' ||
          uri.host.endsWith('paystack.com') ||
          uri.host.endsWith('paystack.co') ||
          uri.scheme == 'about' ||
          url == 'about:blank') {
        return;
      }
      return;
    }

    // Only verify if we have a reference; otherwise wait for next navigation
    if (!hasRef) return;

    _handled = true;
    if (mounted) setState(() => _verifying = true);
    final reference =
        uri.queryParameters['reference'] ??
        uri.queryParameters['trxref'] ??
        widget.fallbackReference;
    try {
      final success = await widget.verify(reference);
      if (!mounted) return;
      Navigator.of(context).pop(success);
    } catch (_) {
      if (!mounted) return;
      setState(() => _verifying = false);
      _handled = false; // allow retry
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification failed – tap "I have paid" to retry')),
      );
    }
  }

  Future<void> _manualVerify() async {
    if (_verifying) return;
    setState(() => _verifying = true);
    try {
      final success = await widget.verify(widget.fallbackReference);
      if (!mounted) return;
      Navigator.of(context).pop(success);
    } catch (e) {
      if (!mounted) return;
      setState(() => _verifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    }
  }

  void _retry() {
    setState(() {
      _failed = false;
      _loading = true;
      _handled = false;
      _verifying = false;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
          onPressed: () async {
            // If user closes manually, try to verify with fallback – payment may have succeeded
            if (_handled || _verifying) {
              Navigator.of(context).pop(false);
              return;
            }
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Close payment?'),
                content: const Text('If you already paid, we will verify your transaction. Otherwise it will be cancelled.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Verify payment')),
                ],
              ),
            );
            if (confirm == true) {
              await _manualVerify();
            } else if (confirm == false) {
              if (mounted) Navigator.of(context).pop(false);
            }
          },
        ),
        title: const Text(
          'Paystack',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _verifying ? null : _manualVerify,
            child: _verifying
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('I have paid', style: TextStyle(color: Color(0xFF3F2868), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading && !_verifying)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF3F2868)),
            ),
          if (_verifying)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircularProgressIndicator(color: Color(0xFF3F2868)),
                  SizedBox(height: 12),
                  Text('Verifying payment...', style: TextStyle(color: Color(0xFF3F2868))),
                ]),
              ),
            ),
          if (_failed)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 48, color: Color(0xFFBDBDBD)),
                  const SizedBox(height: 16),
                  const Text(
                    'Could not load the payment page',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Check your connection and try again.', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _retry,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F2868), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
