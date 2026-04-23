import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mummymap/presentation/providers/pregnancy_provider.dart';

const _facts = {
  1: 'Your baby is just getting started! The fertilized egg is implanting in your uterus. You may not feel any different yet.',
  2: 'Your baby\'s heart begins to form. It\'s about the size of a poppy seed.',
  3: 'The neural tube, which becomes the brain and spinal cord, is forming.',
  4: 'Your baby\'s heart is beating! It\'s about the size of an apple seed.',
  5: 'Your baby is developing facial features and tiny limb buds.',
  6: 'Brain waves can now be detected. Your baby is the size of a sweet pea.',
  7: 'Your baby\'s hands and feet are forming. Morning sickness may be in full swing.',
  8: 'All major organs are forming. Your baby is the size of a kidney bean.',
  9: 'Your baby can make small movements. Tooth buds are forming.',
  10: 'Your baby\'s vital organs are fully formed and starting to function.',
  11: 'Your baby is about the size of a fig. Fingers and toes are no longer webbed.',
  12: 'Your baby can yawn, stretch, and hiccup. The risk of miscarriage drops significantly.',
  13: 'You\'re entering your second trimester! Your baby is the size of a peach.',
  14: 'Your baby can squint, frown, and grimace. The kidneys are producing urine.',
  15: 'Your baby is forming taste buds. You may start to feel movement soon.',
  16: 'Your baby\'s eyes can move, though the eyelids are still closed.',
  17: 'Your baby is developing a layer of fat under the skin.',
  18: 'At this point of your pregnancy, you\'ll feel a bit more nauseated, under the weather and morning sickness and mood swings are now commonly felt. Try eating small, frequent meals and getting as much rest as you can.',
  19: 'Your baby is covered in vernix, a waxy coating that protects the skin.',
  20: 'You\'re halfway there! Your baby is about the size of a banana.',
  21: 'Your baby can swallow and is getting practice with digestive functions.',
  22: 'Your baby\'s lips, eyelids, and eyebrows are becoming more distinct.',
  23: 'Your baby can hear your voice now. Talk and sing to them!',
  24: 'Your baby\'s face is fully formed. The lungs are developing rapidly.',
  25: 'Your baby is gaining more fat and starting to look more like a newborn.',
  26: 'Your baby\'s eyes can open now. Brain activity is increasing.',
  27: 'You\'re entering your third trimester! Your baby can recognize your voice.',
  28: 'Your baby can blink, cough, and even dream during REM sleep.',
  29: 'Your baby\'s muscles and lungs are continuing to mature.',
  30: 'Your baby is about 3 pounds now and gaining weight steadily.',
  31: 'Your baby is going through major brain development this week.',
  32: 'Your baby is practicing breathing by inhaling amniotic fluid.',
  33: 'Your baby\'s bones are hardening, except for the skull which stays soft for delivery.',
  34: 'Your baby\'s central nervous system and lungs are nearly mature.',
  35: 'Your baby is running out of room and may have settled into a head-down position.',
  36: 'Your baby is considered late preterm. Most organs are ready!',
  37: 'Your baby is full term this week. Labor could begin any day.',
  38: 'Your baby is shedding the vernix and lanugo as they prepare for birth.',
  39: 'Your baby\'s brain and lungs are still maturing. Stay patient!',
  40: 'Your due date is here! Your baby is ready to meet the world.',
};

class FunFactsCard extends ConsumerWidget {
  const FunFactsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pregnancy = ref.watch(pregnancyProvider);
    final today = DateFormat('MMM d').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Fun Facts",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: pregnancy == null
                ? const Column(
                    children: [
                      Icon(Icons.auto_stories_outlined,
                          size: 40, color: Color(0xFFBDBDBD)),
                      SizedBox(height: 12),
                      Text(
                        'Add your due date to see daily pregnancy facts',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        '📅  $today',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _facts[pregnancy.currentWeek] ??
                            'Enjoy this special time in your pregnancy journey!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF555555),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}