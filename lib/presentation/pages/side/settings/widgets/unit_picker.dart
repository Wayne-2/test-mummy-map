import 'package:flutter/material.dart';

class UnitPicker extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const UnitPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3F2868) : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}