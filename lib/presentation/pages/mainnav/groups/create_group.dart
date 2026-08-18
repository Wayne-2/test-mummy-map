import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';

class CreateGroup extends ConsumerStatefulWidget {
  const CreateGroup({super.key});

  @override
  ConsumerState<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends ConsumerState<CreateGroup> {
  final _nameController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  Future<void> _createGroup() async {
    if (!_isValid) return;
    setState(() => _isLoading = true);

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final success = await ref.read(groupsProvider.notifier).createGroup(
          name: _nameController.text.trim(),
          tags: tags,
          isPublic: _isPublic,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Could not create the group. The name may already be taken.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Create Group',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3F2868),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                _nameController.text.trim().isEmpty
                                    ? 'G'
                                    : _nameController.text
                                        .trim()
                                        .substring(0, 1)
                                        .toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Group Name',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration('e.g. November Moms 2025'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Tags',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tagsController,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                          'e.g. health, first-trimester, lagos'),
                    ),
                    const SizedBox(height: 6),
                    const Text('Separate tags with commas (optional)',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E))),
                    const SizedBox(height: 20),
                    const Text('Privacy',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 8),
                    _PrivacyOption(
                      icon: Icons.public,
                      title: 'Public',
                      subtitle: 'Anyone can find and join this group',
                      selected: _isPublic,
                      onTap: () => setState(() => _isPublic = true),
                    ),
                    const SizedBox(height: 8),
                    _PrivacyOption(
                      icon: Icons.lock_outline,
                      title: 'Private',
                      subtitle: 'Only approved members can view this group',
                      selected: !_isPublic,
                      onTap: () => setState(() => _isPublic = false),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isValid && !_isLoading
                            ? _createGroup
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F2868),
                          disabledBackgroundColor:
                              const Color(0xFFBDBDBD),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Create Group',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF3F2868), width: 1.5),
      ),
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PrivacyOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE8D5F5)
              : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF3F2868)
                : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? const Color(0xFF3F2868)
                    : const Color(0xFF9E9E9E)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: selected
                              ? const Color(0xFF3F2868)
                              : const Color(0xFF1A1A1A))),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E))),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF3F2868), size: 20),
          ],
        ),
      ),
    );
  }
}
