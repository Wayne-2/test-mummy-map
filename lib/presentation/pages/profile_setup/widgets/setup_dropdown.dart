import 'package:flutter/material.dart';

class SetupDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const SetupDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hintText,
            style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1A1A1A))),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}