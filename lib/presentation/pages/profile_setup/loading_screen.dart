import 'package:flutter/material.dart';
import 'package:mummymap/presentation/pages/mainnav/main_nav.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final List<String> _items = [
    'Reviewing Your Health & Lifestyle Inputs',
    'Customizing Insights Based On Your Pregnancy Stage',
    'Gathering Recommended Wellness Tips',
    'Generating Your Personalized Pregnancy Plan',
    'Preparing Your Daily & Weekly Progress Tracking',
  ];

  final List<bool> _checked = [false, false, false, false, false];
  bool _allDone = false;

  @override
  void initState() {
    super.initState();
    _runChecklist();
  }

  Future<void> _runChecklist() async {
    for (int i = 0; i < _items.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _checked[i] = true);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _allDone = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _allDone ? _AllSet() : _Checklist(items: _items, checked: _checked),
        ),
      ),
    );
  }
}

class _Checklist extends StatelessWidget {
  final List<String> items;
  final List<bool> checked;

  const _Checklist({required this.items, required this.checked});

  @override
  Widget build(BuildContext context) {
    final completedCount = checked.where((c) => c).length;
    final progress = completedCount / items.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo3.png', height: 40, width: 40),
                const SizedBox(width: 12),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Mummy',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F2868),
                        ),
                      ),
                      TextSpan(
                        text: 'map',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3F2868)),
            ),
          ),
          const SizedBox(height: 32),
          ...List.generate(items.length, (index) {
            final isDone = checked[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? const Color(0xFF3F2868) : Colors.transparent,
                      border: Border.all(
                        color: isDone
                            ? const Color(0xFF3F2868)
                            : const Color(0xFFBDBDBD),
                        width: 1.5,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      items[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDone
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFFBDBDBD),
                        fontWeight: isDone ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AllSet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8D5F5),
            ),
            child: const Icon(
              Icons.check,
              size: 52,
              color: Color(0xFF3F2868),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "You're All Set!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your personalized pregnancy plan is ready. Let\'s get started on this journey together.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNav()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F2868),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Let's Go",
                style: TextStyle(
                  fontSize: 16,
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