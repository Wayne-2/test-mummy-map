import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mummymap/presentation/pages/profile_setup/widgets/setup_text_field.dart';
import 'package:mummymap/presentation/pages/profile_setup/widgets/setup_dropdown.dart';
import 'package:mummymap/presentation/providers/pregnancy_provider.dart';
import 'package:mummymap/presentation/providers/profile_setup_draft_provider.dart';

class GetToKnowYou extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const GetToKnowYou({super.key, required this.onComplete});

  @override
  ConsumerState<GetToKnowYou> createState() => _GetToKnowYouState();
}

class _GetToKnowYouState extends ConsumerState<GetToKnowYou> {
  int _subIndex = 0;

  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _selectedDob;
  String? _firstTimeMum;
  String? _bloodGroup;

  String? _basedOn;
  final _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _nextSub() async {
    if (_subIndex == 0) {
      final draft = ref.read(profileSetupDraftProvider.notifier);
      draft.setName(_nameController.text);
      if (_selectedDob != null) draft.setDateOfBirth(_selectedDob!);
      draft.setBloodGroup(_bloodGroup);
      draft.setFirstChild(_firstTimeMum);
      setState(() => _subIndex = 1);
    } else {
      if (_selectedDate != null && _basedOn != null) {
        await ref.read(pregnancyProvider.notifier).savePregnancy(
              method: _basedOn!,
              date: _selectedDate!,
            );
        final dueDate = ref.read(pregnancyProvider)?.dueDate;
        if (dueDate != null) {
          ref.read(profileSetupDraftProvider.notifier).setDueDate(dueDate);
        }
      }
      widget.onComplete();
    }
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => _datePickerTheme(context, child),
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
      _dobController.text = DateFormat('MMMM d, yyyy').format(picked);
    }
  }

  Future<void> _pickDate() async {
    final isEstimated = _basedOn == 'Estimated Due Date';
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isEstimated ? DateTime.now() : DateTime(2020),
      lastDate: isEstimated
          ? DateTime.now().add(const Duration(days: 365))
          : DateTime.now(),
      builder: (context, child) => _datePickerTheme(context, child),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _dateController.text = DateFormat('MMMM d, yyyy').format(picked);
    }
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3F2868),
          onPrimary: Colors.white,
          onSurface: Color(0xFF1A1A1A),
        ),
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _subIndex,
      children: [
        _PersonalInfo(
          nameController: _nameController,
          dobController: _dobController,
          firstTimeMum: _firstTimeMum,
          bloodGroup: _bloodGroup,
          onFirstTimeMumChanged: (val) => setState(() => _firstTimeMum = val),
          onBloodGroupChanged: (val) => setState(() => _bloodGroup = val),
          onPickDob: _pickDob,
          onContinue: _nextSub,
        ),
        _DueDate(
          basedOn: _basedOn,
          dateController: _dateController,
          onBasedOnChanged: (val) {
            setState(() {
              _basedOn = val;
              _selectedDate = null;
              _dateController.clear();
            });
          },
          onPickDate: _pickDate,
          onContinue: _nextSub,
        ),
      ],
    );
  }
}

class _PersonalInfo extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dobController;
  final String? firstTimeMum;
  final String? bloodGroup;
  final ValueChanged<String?> onFirstTimeMumChanged;
  final ValueChanged<String?> onBloodGroupChanged;
  final VoidCallback onPickDob;
  final VoidCallback onContinue;

  const _PersonalInfo({
    required this.nameController,
    required this.dobController,
    required this.firstTimeMum,
    required this.bloodGroup,
    required this.onFirstTimeMumChanged,
    required this.onBloodGroupChanged,
    required this.onPickDob,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hey, Let's Get To Know You",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us a little about yourself.',
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 32),
          SetupTextField(controller: nameController, hintText: 'Full Name'),
          const SizedBox(height: 16),
          SetupTextField(
            controller: dobController,
            hintText: 'Date Of Birth',
            readOnly: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today_outlined,
                  color: Color(0xFF9E9E9E), size: 20),
              onPressed: onPickDob,
            ),
            onTap: onPickDob,
          ),
          const SizedBox(height: 16),
          SetupDropdown(
            value: firstTimeMum,
            hintText: 'Are You A First Time Mum?',
            items: const ['Yes', 'No'],
            onChanged: onFirstTimeMumChanged,
          ),
          const SizedBox(height: 16),
          SetupDropdown(
            value: bloodGroup,
            hintText: 'Blood Group',
            items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
            onChanged: onBloodGroupChanged,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onContinue,
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
              onTap: onContinue,
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

class _DueDate extends StatelessWidget {
  final String? basedOn;
  final TextEditingController dateController;
  final ValueChanged<String?> onBasedOnChanged;
  final VoidCallback onPickDate;
  final VoidCallback onContinue;

  const _DueDate({
    required this.basedOn,
    required this.dateController,
    required this.onBasedOnChanged,
    required this.onPickDate,
    required this.onContinue,
  });

  String get _helperText {
    if (basedOn == 'First Day Of Last Period') {
      return 'We calculate estimated due date using a 28-day menstrual cycle';
    } else if (basedOn == 'Date Of Conception') {
      return 'Pregnancy begins 2 weeks before conception. This is when your due date is calculated from.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "When's The Big Arrival!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select how you want to calculate your due date, you can change it any time no worries.',
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E), height: 1.5),
          ),
          const SizedBox(height: 32),
          SetupDropdown(
            value: basedOn,
            hintText: 'Based On',
            items: const [
              'First Day Of Last Period',
              'Estimated Due Date',
              'Date Of Conception',
            ],
            onChanged: onBasedOnChanged,
          ),
          const SizedBox(height: 16),
          SetupTextField(
            controller: dateController,
            hintText: 'Date',
            readOnly: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today_outlined,
                  color: Color(0xFF9E9E9E), size: 20),
              onPressed: onPickDate,
            ),
            onTap: onPickDate,
          ),
          if (_helperText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _helperText,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onContinue,
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
              onTap: onContinue,
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