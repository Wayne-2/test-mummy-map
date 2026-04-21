import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<bool> completed;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
         
          Container(
            height: 1,
            color: const Color(0xFFE0E0E0),
          ),
         
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final isCompleted = completed[index];
              final isActive = index == currentStep;

              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF3F2868)
                      : const Color(0xFFE8D5F5),
                  border: Border.all(
                    color: isActive && !isCompleted
                        ? const Color(0xFF3F2868)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}