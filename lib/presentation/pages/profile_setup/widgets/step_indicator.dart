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

              Color bgColor;
              if (isCompleted) {
                bgColor = const Color(0xFF3F2868);
              } else if (isActive) {
                bgColor = const Color(0xFF3F2868);
              } else {
                bgColor = const Color(0xFFE8D5F5);
              }

              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                  border: Border.all(
                    color: isActive && !isCompleted
                        ? const Color(0xFF3F2868)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}