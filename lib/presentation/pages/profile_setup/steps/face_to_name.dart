import 'package:flutter/material.dart';

class FaceToName extends StatelessWidget {
  final VoidCallback onComplete;

  const FaceToName({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Putting A Face To The Name',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a profile photo so we can personalise your experience.',
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 40),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE8D5F5),
                    border: Border.all(
                      color: const Color(0xFF3F2868),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Color(0xFF3F2868),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF3F2868),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F2868),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: onComplete,
              child: const Text(
                'Skip',
                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}