import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mummymap/data/models/profile_model.dart';
import 'package:mummymap/presentation/pages/mainnav/main_nav.dart';
import 'package:mummymap/presentation/providers/pregnancy_provider.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';
import 'package:mummymap/presentation/providers/profile_setup_draft_provider.dart';
import 'package:mummymap/presentation/providers/settings_provider.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  final List<String> _items = [
    'Reviewing Your Health & Lifestyle Inputs',
    'Customizing Insights Based On Your Pregnancy Stage',
    'Gathering Recommended Wellness Tips',
    'Generating Your Personalized Pregnancy Plan',
    'Preparing Your Daily & Weekly Progress Tracking',
  ];

  final List<bool> _checked = [false, false, false, false, false];
  bool _checklistDone = false;
  bool _submitDone = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runChecklist();
    _submitProfile();
  }

  Future<void> _runChecklist() async {
    for (int i = 0; i < _items.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _checked[i] = true);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _checklistDone = true);
  }

  Future<void> _submitProfile() async {
    final draft = ref.read(profileSetupDraftProvider);
    final pregnancy = ref.read(pregnancyProvider);
    final dueDate = draft.dueDate ?? pregnancy?.dueDate;

    final first = (draft.firstName != null && draft.firstName!.trim().isNotEmpty)
        ? draft.firstName!.trim()
        : 'Mum';
    final last = (draft.lastName != null && draft.lastName!.trim().isNotEmpty)
        ? draft.lastName!.trim()
        : 'User';
    final handle = ProfileMappers.handleFromName(first, last) ??
        'user${DateTime.now().millisecondsSinceEpoch.remainder(100000)}';

    final profile = ProfileModel(
      firstName: first,
      lastName: last,
      handle: handle,
      dateOfBirth: draft.dateOfBirth,
      bloodType: ProfileMappers.bloodTypeToApi(draft.bloodGroupDisplay),
      isPregnant: true,
      dueDate: dueDate,
      pregnancyWeek: pregnancy?.currentWeek,
      numberOfChildren: ProfileMappers.firstChildToCount(draft.firstChild),
    );

    try {
      await ref.read(profileProvider.notifier).submitSetup(
            profile: profile,
            imagePath: draft.imagePath,
          );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_setup', true);
      ref.read(settingsProvider.notifier).setFirstName(first);
      if (last != 'User') ref.read(settingsProvider.notifier).setLastName(last);
      ref.read(profileSetupDraftProvider.notifier).reset();
      if (mounted) setState(() => _submitDone = true);
    } catch (e) {
      if (mounted) setState(() => _error = _describe(e));
    }
  }

  String _describe(Object e) {
    final s = e.toString();
    if (s.contains('409')) return 'A profile already exists for this account.';
    return 'We couldn\'t save your profile. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final ready = _checklistDone && _submitDone;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _error != null
            ? _ErrorView(
                message: _error!,
                onRetry: () {
                  setState(() => _error = null);
                  _submitProfile();
                },
              )
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: ready
                    ? _AllSet()
                    : _Checklist(items: _items, checked: _checked),
              ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Color(0xFF3F2868)),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F2868),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text('Try Again',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
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
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF3F2868)),
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
                      color:
                          isDone ? const Color(0xFF3F2868) : Colors.transparent,
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
                        fontWeight:
                            isDone ? FontWeight.w500 : FontWeight.normal,
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
            child: const Icon(Icons.check, size: 52, color: Color(0xFF3F2868)),
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
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E), height: 1.6),
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