import 'package:flutter/material.dart';

class Privacy extends StatelessWidget {
  final VoidCallback onAgree;

  const Privacy({super.key, required this.onAgree});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Privacy Is Our Priority',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: const SingleChildScrollView(
                child: Text(
                 'By continuing, I consent to Mummy Map processing all data I provide through this app, including sensitive data such as  health information, so that Mummy Map can provide services to me. In addition, by signing up you agree to our Terms and Conditions and Privacy Policy which also tells you how we use your data. We never post it to Facebook.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onAgree,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F2868),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'I Agree',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}