import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/pages/auth/signin.dart';
import 'package:mummymap/presentation/pages/auth/signup.dart' show describeAuthError;
import 'package:mummymap/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({super.key});

  @override
  ConsumerState<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPassword> {
  int _step = 0;
  String _email = '';
  String _resetToken = '';

  void _onEmailSubmitted(String email) {
    setState(() {
      _email = email;
      _step = 1;
    });
  }

  void _onOtpVerified(String resetToken) {
    setState(() {
      _resetToken = resetToken;
      _step = 2;
    });
  }

  void _onResetComplete() {
    context.go('/signin');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.fromARGB(255, 222, 197, 239), Colors.white],
              ),
            ),
          ),
          Positioned(
            bottom: 190,
            left: 16,
            right: 16,
            top: screenHeight * 0.18,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 32,
                bottom: bottomPadding + 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _step == 0
                      ? _EmailStep(
                          key: const ValueKey(0),
                          onSubmitted: _onEmailSubmitted,
                        )
                      : _step == 1
                          ? _OtpStep(
                              key: const ValueKey(1),
                              email: _email,
                              onVerified: _onOtpVerified,
                            )
                          : _ResetStep(
                              key: const ValueKey(2),
                              resetToken: _resetToken,
                              onComplete: _onResetComplete,
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailStep extends ConsumerStatefulWidget {
  final ValueChanged<String> onSubmitted;

  const _EmailStep({super.key, required this.onSubmitted});

  @override
  ConsumerState<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends ConsumerState<_EmailStep> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final v = _emailController.text.trim();
    return v.isNotEmpty && v.contains('@') && v.contains('.');
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      await ref
          .read(authRepositoryProvider)
          .requestPasswordResetOtp(email: email);

      if (!mounted) return;
      widget.onSubmitted(email);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(describeAuthError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logo3.png', height: 48, width: 48),
        const SizedBox(height: 16),
        const Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter email to receive OTP',
          style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
        ),
        const SizedBox(height: 32),
        _FloatingLabelField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (_isValid && !_isLoading) ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F2868),
              disabledBackgroundColor: const Color(0xFF9E9E9E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Sending code...',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  )
                : const Text(
                    'Send Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => context.pop(),
          child: const Text(
            'Back To Sign In',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3F2868),
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpStep extends ConsumerStatefulWidget {
  final String email;
  final ValueChanged<String> onVerified;

  const _OtpStep({super.key, required this.email, required this.onVerified});

  @override
  ConsumerState<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends ConsumerState<_OtpStep> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _resendCountdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _isComplete => _otp.length == 6;

  Future<void> _submit() async {
    if (!_isComplete) return;
    setState(() => _isLoading = true);

    try {
      final resetToken = await ref
          .read(authRepositoryProvider)
          .verifyResetOtp(otp: _otp);

      if (!mounted) return;
      widget.onVerified(resetToken);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(describeAuthError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    try {
      await ref.read(authRepositoryProvider).requestPasswordResetOtp(
            email: widget.email,
          );
      _startResendTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(describeAuthError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logo3.png', height: 48, width: 48),
        const SizedBox(height: 16),
        const Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter 6-digit OTP code',
          style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            final isSeparator = i == 3;
            return Row(
              children: [
                if (isSeparator) ...[
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Text(
                      '—',
                      style: TextStyle(fontSize: 18, color: Color(0xFFBDBDBD)),
                    ),
                  ),
                ],
                SizedBox(
                  width: 42,
                  height: 52,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => _onDigitChanged(i, v),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF3F2868),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't receive code? ",
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            ),
            GestureDetector(
              onTap: _resendCountdown == 0 ? _resendOtp : null,
              child: Text(
                _resendCountdown > 0 ? 'Resend In ${_resendCountdown}s' : 'Resend',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _resendCountdown > 0
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF3F2868),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (_isComplete && !_isLoading) ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F2868),
              disabledBackgroundColor: const Color(0xFF9E9E9E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ResetStep extends ConsumerStatefulWidget {
  final String resetToken;
  final VoidCallback onComplete;

  const _ResetStep(
      {super.key, required this.resetToken, required this.onComplete});

  @override
  ConsumerState<_ResetStep> createState() => _ResetStepState();
}

class _ResetStepState extends ConsumerState<_ResetStep> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasMaxLength => _passwordController.text.length <= 20;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'));

  bool get _passwordsMatch =>
      _passwordController.text == _confirmController.text &&
      _confirmController.text.isNotEmpty;

  bool get _isValid =>
      _hasMinLength &&
      _hasMaxLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecial &&
      _passwordsMatch;

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).resetPassword(
            newPassword: _passwordController.text.trim(),
            resetToken: widget.resetToken,
          );

      if (!mounted) return;
      widget.onComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(describeAuthError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logo3.png', height: 48, width: 48),
        const SizedBox(height: 16),
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Set a new password',
          style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
        ),
        const SizedBox(height: 32),
        _FloatingLabelField(
          controller: _passwordController,
          label: 'Password',
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF9E9E9E),
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),
        _FloatingLabelField(
          controller: _confirmController,
          label: 'Confirm Password',
          obscureText: _obscureConfirm,
          onChanged: (_) => setState(() {}),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF9E9E9E),
              size: 20,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        const SizedBox(height: 20),
        _ValidationRow(met: _hasMinLength, label: 'A minimum of 8 characters'),
        const SizedBox(height: 6),
        _ValidationRow(met: _hasUppercase, label: 'At least one uppercase'),
        const SizedBox(height: 6),
        _ValidationRow(met: _hasLowercase, label: 'At least one lowercase'),
        const SizedBox(height: 6),
        _ValidationRow(met: _hasNumber, label: 'At least one number'),
        const SizedBox(height: 6),
        _ValidationRow(
          met: _hasSpecial,
          label: 'At least one special character "\$,#..."',
        ),
        const SizedBox(height: 6),
        _ValidationRow(met: _passwordsMatch, label: 'Passwords match'),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (_isValid && !_isLoading) ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F2868),
              disabledBackgroundColor: const Color(0xFF9E9E9E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Resetting...',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  )
                : const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ValidationRow extends StatelessWidget {
  final bool met;
  final String label;

  const _ValidationRow({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check : Icons.close,
          size: 16,
          color: met ? const Color(0xFF4CAF50) : const Color(0xFFBDBDBD),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: met ? const Color(0xFF4CAF50) : const Color(0xFFBDBDBD),
          ),
        ),
      ],
    );
  }
}

class _FloatingLabelField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const _FloatingLabelField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        floatingLabelStyle:
            const TextStyle(color: Color(0xFF3F2868), fontSize: 12),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F2868), width: 1.5),
        ),
      ),
    );
  }
}