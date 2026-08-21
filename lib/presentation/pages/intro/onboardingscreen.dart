import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _images = [
    'assets/Frame 75.png',
    'assets/Frame 76.png',
    'assets/Frame 77.png',
  ];

  void _nextPage() {
    if (_currentPage < _images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToSignUp();
    }
  }

  void _skip() {
    _navigateToSignUp();
  }

  void _navigateToSignUp() {
    context.go('/signup');
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Image.asset(_images[index], fit: BoxFit.contain);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  _OutlinedPurpleButton(
                    label: _currentPage == _images.length - 1 ? 'Done' : 'Next',
                    onTap: _nextPage,
                  ),
                  const SizedBox(height: 12),
                  _OutlinedPurpleButton(label: 'Skip', onTap: _skip),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlinedPurpleButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlinedPurpleButton({required this.label, required this.onTap});

  @override
  State<_OutlinedPurpleButton> createState() => _OutlinedPurpleButtonState();
}

class _OutlinedPurpleButtonState extends State<_OutlinedPurpleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF3F2868) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFF3F2868), width: 1.5),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _isPressed ? Colors.white : const Color(0xFF3F2868),
            ),
          ),
        ),
      ),
    );
  }
}
