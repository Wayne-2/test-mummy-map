import 'package:flutter/material.dart';
import 'package:mummymap/presentation/pages/auth/signin.dart';
import 'package:mummymap/presentation/pages/profile_setup/profile_setup.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>(); 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return; 

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetup()),
    );
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
              child: Form( 
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo3.png', height: 48, width: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Signup to get started today',
                      style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 32),

                    _AuthTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(
                          r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _AuthTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF9E9E9E),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Minimum 6 characters';
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Must contain uppercase letter';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Must contain a number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F2868),
                          disabledBackgroundColor: const Color(0xFF3F2868),
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
                                  SizedBox(width: 12),
                                  Text(
                                    'Signing Up...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already Have An Account? ',
                          style: TextStyle(color: Color(0xFF9E9E9E)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignIn(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3F2868),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator; 

  const _AuthTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField( 
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator, 
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
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