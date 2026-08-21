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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _handleUrl(url);
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (url) {
            _handleUrl(url);
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (mounted && !_loading) setState(() => _failed = true);
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

    // Ignore Paystack hosted checkout hosts and blank/intermediate urls
    if (uri.host == 'checkout.paystack.com' ||
        uri.host.endsWith('paystack.com') ||
        uri.scheme == 'about' ||
        url == 'about:blank') {
      return;
    }

    // Only verify when callback contains reference/trxref to avoid premature verify on ads/redirects
    final hasRef = uri.queryParameters.containsKey('reference') ||
        uri.queryParameters.containsKey('trxref');
    if (!hasRef) return;

    _handled = true;
    final reference =
        uri.queryParameters['reference'] ??
        uri.queryParameters['trxref'] ??
        widget.fallbackReference;
    final success = await widget.verify(reference);
    if (!mounted) return;
    Navigator.of(context).pop(success);
  }

  void _retry() {
    setState(() {
      _failed = false;
      _loading = true;
      _handled = false;
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
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Paystack',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF3F2868)),
            ),
          if (_failed)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_outlined,
                      size: 48, color: Color(0xFFBDBDBD)),
                  const SizedBox(height: 16),
                  const Text(
                    'Could not load the payment page',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check your connection and try again.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _retry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F2868),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}