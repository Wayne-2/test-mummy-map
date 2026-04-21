import 'package:flutter/material.dart';
import 'package:mummymap/presentation/profile_setup/steps/privacy.dart';
import 'package:mummymap/presentation/profile_setup/steps/get_to_know_you.dart';
import 'package:mummymap/presentation/profile_setup/steps/face_to_name.dart';
import 'package:mummymap/presentation/profile_setup/steps/final_message.dart';
import 'package:mummymap/presentation/profile_setup/widgets/step_indicator.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  int _currentStep = 0;
  final List<bool> _completed = [false, false, false, false];

  void _nextStep() {
    setState(() {
      _completed[_currentStep] = true;
      if (_currentStep < 3) _currentStep++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            StepIndicator(
              currentStep: _currentStep,
              completed: _completed,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  Privacy(onAgree: _nextStep),
                  GetToKnowYou(onComplete: _nextStep),
                  FaceToName(onComplete: _nextStep),
                  FinalMessage(onComplete: _nextStep),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}