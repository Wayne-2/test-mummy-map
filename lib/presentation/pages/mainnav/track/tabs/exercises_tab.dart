import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mummymap/data/models/track_models.dart';  

class ExercisesTab extends StatefulWidget {
  const ExercisesTab({super.key});

  @override
  State<ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends State<ExercisesTab> {
  int _selectedLevel = 1;

  ExerciseLevel get _currentLevel =>
      kExerciseLevels[_selectedLevel - 1];

  bool get _isLevel1Selected => _selectedLevel == 1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildLevelStrip(),
          const SizedBox(height: 24),
          _isLevel1Selected
              ? _buildLevel1Detail(context)
              : _buildDayList(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLevelStrip() {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kExerciseLevels.length,
        itemBuilder: (context, index) {
          final level = index + 1;
          final isSelected = _selectedLevel == level;
          final isCompleted =
              kExerciseLevels[index].days.every((d) => d.completed);

          return GestureDetector(
            onTap: () {
              if (level != 1 && _selectedLevel == 1) {
                _showChangeLevelDialog(context, level);
              } else {
                setState(() => _selectedLevel = level);
              }
            },
            child: Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF7B2FBE), Color(0xFF3F2868)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFEDE7F6),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$level',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                  Text(
                    'Level',
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected
                          ? Colors.white70
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevel1Detail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Level 1',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                TextSpan(
                  text: '  •  Day 1',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/exercises/kegel.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 200,
                color: const Color(0xFFEDE7F6),
                child: const Icon(Icons.fitness_center,
                    size: 60, color: Color(0xFF3F2868)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...kLevel1Day1Exercises.map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ex.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ex.timing}  •  ${ex.repeats} Repeats',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TrainingScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F2868),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text(
                'Start Training',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () => _showHowToSheet(context),
              child: const Text(
                'How to perform exercises?',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3F2868),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ..._currentLevel.days.skip(1).map((day) =>
              _DayItem(
                day: day,
                onStart: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TrainingScreen(),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDayList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _currentLevel.days
            .map((day) => _DayItem(
                  day: day,
                  onStart: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrainingScreen(),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showChangeLevelDialog(BuildContext context, int level) {
    showDialog(
      context: context,
      builder: (_) => _ChangeLevelDialog(
        onChange: () {
          Navigator.pop(context);
          setState(() => _selectedLevel = level);
        },
      ),
    );
  }

  void _showHowToSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _HowToSheet(),
    );
  }
}

class _DayItem extends StatelessWidget {
  final ExerciseDay day;
  final VoidCallback onStart;

  const _DayItem({required this.day, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: day.completed
                  ? const Color(0xFF3F2868)
                  : Colors.transparent,
              border: Border.all(
                color: day.completed
                    ? const Color(0xFF3F2868)
                    : const Color(0xFFBDBDBD),
                width: 1.5,
              ),
            ),
            child: day.completed
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${day.dayNumber}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Training time: ${day.trainingTime}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
                Text(
                  'Done: ${day.done}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onStart,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF3F2868),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward,
                      color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeLevelDialog extends StatelessWidget {
  final VoidCallback onChange;

  const _ChangeLevelDialog({required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change your training level?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'With each level you get to build necessary muscles to keep you and your baby strong.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.fitness_center,
                    size: 60, color: Color(0xFF3F2868)),
              ),
            ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A))),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onChange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F2868),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text('Change',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HowToSheet extends StatelessWidget {
  const _HowToSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'How To Perform Exercises',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _HowToSection(
              title: 'Position',
              body:
                  'Get into a comfortable position and start the exercise. You can lay down on the floor, sit in a chair or just stay right where you are. Try to find the best option for you',
            ),
            _HowToSection(
              title: 'Classic Kegel',
              body:
                  'Squeeze your pelvic floor muscles for 3 seconds then relax for 3 seconds. Repeat exercise 10 times. Exercise time may change according to the level.',
            ),
            _HowToSection(
              title: 'Pulse Kegel',
              body:
                  'Start squeezing and releasing your pelvic floor muscles as fast as you can within 10 seconds. Then relax for 10 seconds. Repeat exercise 3 times. Exercise may change according to the level.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HowToSection extends StatelessWidget {
  final String title;
  final String body;

  const _HowToSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TRAINING SCREEN ──────────────────────────────────────────────────────────

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int _exerciseIndex = 0;
  bool _isResting = false;
  bool _isRunning = false;
  bool _isPaused = false;
  int _countdown = 3;
  int _repeatsLeft = 0;
  Timer? _timer;

  ExerciseSet get _currentExercise =>
      kLevel1Day1Exercises[_exerciseIndex];

  @override
  void initState() {
    super.initState();
    _repeatsLeft = _currentExercise.repeats;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _countdown = 3;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          if (_repeatsLeft > 0 && !_isResting) {
            _repeatsLeft--;
            _countdown = 3;
            if (_repeatsLeft == 0) {
              _isResting = true;
              _countdown = 30;
            }
          } else if (_isResting) {
            _isResting = false;
            _countdown = 3;
            _repeatsLeft = _currentExercise.repeats;
          }
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isPaused = true);
  }

  void _resume() {
    _startTimer();
  }

  void _exit(BuildContext context) {
    _timer?.cancel();
    Navigator.pop(context);
  }

  void _nextExercise() {
    _timer?.cancel();
    if (_exerciseIndex < kLevel1Day1Exercises.length - 1) {
      setState(() {
        _exerciseIndex++;
        _isRunning = false;
        _isPaused = false;
        _isResting = false;
        _countdown = 3;
        _repeatsLeft = _currentExercise.repeats;
      });
    } else {
      _showCompleteDialog();
    }
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete your training?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Take your training sessions seriously if you want to remain healthy during your pregnancy',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.self_improvement,
                      size: 60, color: Color(0xFF3F2868)),
                ),
              ),
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F2868),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text('Continue',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_currentExercise.isPulse) ...[
                    Text(
                      '${_currentExercise.timing.split(' X ')[0]} Squeeze  •  ${_currentExercise.timing.split(' X ')[1]} Relax',
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF555555)),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Repeat ',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF555555)),
                          ),
                          TextSpan(
                            text: '$_repeatsLeft',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F2868),
                            ),
                          ),
                          const TextSpan(
                            text: ' Times',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF555555)),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Squeeze And Relax Quickly',
                      style: TextStyle(
                          fontSize: 16, color: Color(0xFF555555)),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$_countdown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F2868),
                            ),
                          ),
                          const TextSpan(
                            text: ' - 10 - 10',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF555555)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 60),
                  _isResting
                      ? Column(
                          children: [
                            const Text(
                              'Have A Rest',
                              style: TextStyle(
                                  fontSize: 18, color: Color(0xFF555555)),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              '0:${_countdown.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF3F2868),
                              ),
                            ),
                          ],
                        )
                      : _buildTimerCircle(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo3.png', height: 28, width: 28,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(width: 28, height: 28)),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Mummy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F2868),
                      ),
                    ),
                    TextSpan(
                      text: 'map',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BCD4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.notifications_outlined,
              color: Color(0xFF1A1A1A)),
        ],
      ),
    );
  }

  Widget _buildTimerCircle() {
    final progress = _isRunning && _countdown <= 3
        ? (_countdown / 3.0)
        : 0.0;

    return GestureDetector(
      onTap: !_isRunning ? _startTimer : null,
      child: SizedBox(
        width: 160,
        height: 160,
        child: CustomPaint(
          painter: _CircleTimerPainter(progress: _isRunning ? progress : 0),
          child: Center(
            child: _isRunning
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isResting ? 'Rest' : 'Squeeze',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF9E9E9E)),
                      ),
                      Text(
                        '$_countdown',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F2868),
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Tap To Start',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _exit(context),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    'Exit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isResting
                  ? _nextExercise
                  : (_isPaused ? _resume : (_isRunning ? _pause : _startTimer)),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF3F2868),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isResting
                            ? Icons.skip_next
                            : (_isPaused
                                ? Icons.play_arrow
                                : (_isRunning
                                    ? Icons.pause
                                    : Icons.play_arrow)),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isResting
                            ? 'Continue'
                            : (_isPaused
                                ? 'Resume'
                                : (_isRunning ? 'Pause' : 'Start')),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleTimerPainter extends CustomPainter {
  final double progress;

  _CircleTimerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFFEDE7F6),
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2,
        2 * 3.14159 * progress,
        false,
        Paint()
          ..color = const Color(0xFF3F2868)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_CircleTimerPainter old) => old.progress != progress;
}