import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/track_models.dart';
import 'package:mummymap/data/models/weight_track_model.dart';
import 'package:mummymap/presentation/providers/weight_track_provider.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';
import 'package:mummymap/presentation/providers/settings_provider.dart';

class WeightTrackingTab extends ConsumerStatefulWidget {
  const WeightTrackingTab({super.key});

  @override
  ConsumerState<WeightTrackingTab> createState() => _WeightTrackingTabState();
}

class _WeightTrackingTabState extends ConsumerState<WeightTrackingTab> {
  bool _showChart = false;

  int? _gestationalWeek(DateTime date, DateTime? dueDate) {
    if (dueDate == null) return null;
    final pregnancyStart = dueDate.subtract(const Duration(days: 280));
    final days = date.difference(pregnancyStart).inDays;
    if (days < 0) return null;
    return (days ~/ 7 + 1).clamp(1, 42).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final usesKilograms =
        ref.watch(settingsProvider).weightUnit == 'Kilograms (kg)';
    final startWeight = (profile?.weightKg != null && profile!.weightKg! > 0)
        ? (profile.weightKg! * 2.20462)
        : kStartWeight;

    final weightState = ref.watch(weightTrackProvider);
    final entries = weightState.entries
        .map((e) => WeightEntry(
              date: e.recordedAt,
              week: e.week ?? _gestationalWeek(e.recordedAt, profile?.dueDate) ?? 0,
              weightLb: double.parse(e.weightLb.toStringAsFixed(1)),
            ))
        .toList();

    final currentWeight =
        entries.isEmpty ? startWeight : entries.last.weightLb;
    final gain = currentWeight - startWeight;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (weightState.isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CircularProgressIndicator(
                color: Color(0xFF3F2868),
                strokeWidth: 2,
              ),
            ),
          if (weightState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                weightState.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          _buildViewToggle(),
          const SizedBox(height: 24),
          _showChart
              ? _buildChart(entries, startWeight)
              : _buildDonut(gain, entries.isNotEmpty, startWeight, usesKilograms),
          const SizedBox(height: 24),
          _buildStatRow(currentWeight, startWeight, usesKilograms),
          const SizedBox(height: 24),
          if (!_showChart) _buildWeightTable(entries, startWeight, usesKilograms),
          const SizedBox(height: 40),
          _buildAddButton(context, usesKilograms, profile?.dueDate),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0EAF9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToggleBtn(
                icon: Icons.pie_chart_outline,
                selected: !_showChart,
                onTap: () => setState(() => _showChart = false),
              ),
              _ToggleBtn(
                icon: Icons.bar_chart,
                selected: _showChart,
                onTap: () => setState(() => _showChart = true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonut(
    double gain,
    bool hasData,
    double startWeight,
    bool usesKilograms,
  ) {
    final progress = (gain.abs() / (startWeight * 0.2)).clamp(0.0, 1.0);
    final displayGain = _displayWeight(gain, usesKilograms);

    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: CustomPaint(
          painter: _DonutPainter(progress: progress, hasData: hasData),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayGain == 0
                      ? '0'
                      : '${displayGain > 0 ? '+' : ''}${displayGain.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F2868),
                  ),
                ),
                Text(
                  '${usesKilograms ? 'KG' : 'LB'} GAIN',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<WeightEntry> entries, double startWeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LG',
            style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: CustomPaint(
              painter: _WeightChartPainter(
                entries: entries,
                startWeight: startWeight,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'WEEKS',
              style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: const Color(0xFFFFA726), label: 'Start Weight'),
              const SizedBox(width: 20),
              _Legend(color: const Color(0xFF4CAF50), label: 'Recorded Weight'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(double currentWeight, double startWeight, bool usesKilograms) {
    final unit = usesKilograms ? 'KG' : 'LB';
    final displayCurrent = _displayWeight(currentWeight, usesKilograms);
    final displayStart = _displayWeight(startWeight, usesKilograms);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCol(label: 'START WEIGHT', value: '${displayStart.toStringAsFixed(1)} $unit'),
          const _VertDivider(),
          _StatCol(label: 'CURRENT WEIGHT', value: '${displayCurrent.toStringAsFixed(1)} $unit'),
          const _VertDivider(),
          const _StatCol(label: 'WEIGHT GOAL', value: 'NOT SET'),
        ],
      ),
    );
  }

  Widget _buildWeightTable(List<WeightEntry> entries, double startWeight, bool usesKilograms) {
    final unit = usesKilograms ? 'KG' : 'LB';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: const Row(
              children: [
                Expanded(child: _TableHeader('Date')),
                Expanded(child: _TableHeader('Week')),
                Expanded(child: _TableHeader('Weight')),
                Expanded(child: _TableHeader('Change')),
              ],
            ),
          ),
          ...entries.map((e) {
            final change = _displayWeight(e.weightLb - startWeight, usesKilograms);
            final changeStr =
                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} $unit';
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_monthName(e.date.month)} ${e.date.day}',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.week == 0 ? '—' : '${e.week}',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${_displayWeight(e.weightLb, usesKilograms).toStringAsFixed(1)} $unit',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      changeStr,
                      style: TextStyle(
                        fontSize: 14,
                        color: change >= 0
                            ? const Color(0xFF3F2868)
                            : Colors.red,
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

  Widget _buildAddButton(
    BuildContext context,
    bool usesKilograms,
    DateTime? dueDate,
  ) {
    return GestureDetector(
      onTap: () => _showAddWeightDialog(context, usesKilograms, dueDate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF3F2868),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Weight',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWeightDialog(
    BuildContext context,
    bool usesKilograms,
    DateTime? dueDate,
  ) {
    showDialog(
      context: context,
      builder: (_) => _AddWeightDialog(
        initialUnit: usesKilograms ? 'KG' : 'LB',
        onAdd: (weight, unit, date) async {
          final weightKg = unit == 'KG' ? weight : lbToKg(weight);
          final error = await ref.read(weightTrackProvider.notifier).addWeightKg(
                weightKg,
                date,
                week: _gestationalWeek(date, dueDate),
              );
          if (error != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  double _displayWeight(double weightLb, bool usesKilograms) =>
      usesKilograms ? lbToKg(weightLb) : weightLb;



  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month];
  }
}

class _AddWeightDialog extends StatefulWidget {
  final void Function(double weight, String unit, DateTime date) onAdd;
  final String initialUnit;

  const _AddWeightDialog({required this.onAdd, required this.initialUnit});

  @override
  State<_AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<_AddWeightDialog> {
  DateTime _selectedDate = DateTime.now();
  late String _unit;
  double _whole = 133;
  double _decimal = 3;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit;
    if (_unit == 'KG') _whole = 60;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: _showCalendar
          ? _buildCalendar()
          : _buildWeightPicker(),
    );
  }

  Widget _buildWeightPicker() {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateStr =
        '${months[_selectedDate.month]} ${_selectedDate.day}, ${_selectedDate.year}';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              _UnitDropdown(
                value: _unit,
                onChanged: (v) {
                  if (v == null || v == _unit) return;
                  final current = _whole + _decimal / 10;
                  final converted = v == 'KG' ? lbToKg(current) : kgToLb(current);
                  setState(() {
                    _unit = v;
                    _whole = converted.floorToDouble();
                    _decimal = ((converted - _whole) * 10)
                        .roundToDouble()
                        .clamp(0, 9)
                        .toDouble();
                  });
                },
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _showCalendar = true),
                child: const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF3F2868), size: 20),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
              ),
            ],
          ),
          const Divider(height: 24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NumberScroller(
                value: _whole,
                min: _unit == 'KG' ? 30 : 66,
                max: _unit == 'KG' ? 250 : 550,
                onChanged: (v) => setState(() => _whole = v),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '.',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                ),
              ),
              _NumberScroller(
                value: _decimal,
                min: 0,
                max: 9,
                onChanged: (v) => setState(() => _decimal = v),
              ),
              const SizedBox(width: 12),
              Text(
                _unit,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFF1A1A1A)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  widget.onAdd(_whole + _decimal / 10, _unit, _selectedDate);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F2868),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    DateTime _focusedMonth = _selectedDate;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final firstDay =
            DateTime(_focusedMonth.year, _focusedMonth.month, 1);
        final daysInMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
        final startWeekday = firstDay.weekday % 7;
        final months = [
          '', 'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December',
        ];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_monthName(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Text(
                    '${months[_focusedMonth.month]} ${_focusedMonth.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 18, color: Color(0xFF9E9E9E)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Color(0xFF1A1A1A)),
                    onPressed: () => setLocalState(() {
                      _focusedMonth = DateTime(
                          _focusedMonth.year, _focusedMonth.month - 1, 1);
                    }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: Color(0xFF1A1A1A)),
                    onPressed: () => setLocalState(() {
                      _focusedMonth = DateTime(
                          _focusedMonth.year, _focusedMonth.month + 1, 1);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9E9E9E))),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.2,
                ),
                itemCount: startWeekday + daysInMonth,
                itemBuilder: (_, index) {
                  if (index < startWeekday) return const SizedBox();
                  final day = index - startWeekday + 1;
                  final date = DateTime(
                      _focusedMonth.year, _focusedMonth.month, day);
                  final isFuture = date.isAfter(
                    DateTime(DateTime.now().year, DateTime.now().month,
                        DateTime.now().day),
                  );
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  return GestureDetector(
                    onTap: isFuture
                        ? null
                        : () => setLocalState(() => _selectedDate = date),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? const Color(0xFF3F2868)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? Colors.white
                                : isFuture
                                    ? const Color(0xFFBDBDBD)
                                    : const Color(0xFF1A1A1A),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
                    onTap: () =>
                        setState(() => _showCalendar = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F2868),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text('Ok',
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
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month];
  }
}

class _NumberScroller extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _NumberScroller({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value == min ? '' : '${(value - 1).toInt()}',
            style: const TextStyle(
                fontSize: 20, color: Color(0xFFBDBDBD)),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onVerticalDragUpdate: (d) {
              if (d.primaryDelta != null) {
                if (d.primaryDelta! < 0 && value < max) {
                  onChanged(value + 1);
                } else if (d.primaryDelta! > 0 && value > min) {
                  onChanged(value - 1);
                }
              }
            },
            child: Container(
              width: 80,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: const Border(
                  bottom: BorderSide(color: Color(0xFF3F2868)),
                  top: BorderSide(color: Color(0xFF3F2868)),
                ),
              ),
              child: Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value == max ? '' : '${(value + 1).toInt()}',
            style: const TextStyle(
                fontSize: 20, color: Color(0xFFBDBDBD)),
          ),
        ],
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _UnitDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        icon: const Icon(Icons.keyboard_arrow_down,
            size: 14, color: Color(0xFF9E9E9E)),
        style: const TextStyle(
            fontSize: 13, color: Color(0xFF1A1A1A)),
        items: const ['LB', 'KG']
            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final bool hasData;

  _DonutPainter({required this.progress, required this.hasData});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 14.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFEDE7F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (hasData && progress > 0) {
      final fgPaint = Paint()
        ..color = const Color(0xFF3F2868)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2,
        2 * 3.14159 * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.hasData != hasData;
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  final double startWeight;

  _WeightChartPainter({
    required this.entries,
    required this.startWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final weeks = [0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40];
    final trimesterColors = [
      const Color(0xFFFFE0B2).withOpacity(0.4),
      const Color(0xFFC8E6C9).withOpacity(0.4),
      const Color(0xFFBBDEFB).withOpacity(0.4),
    ];

    var minWeight = startWeight - 10.0;
    var maxWeight = startWeight + 10.0;
    for (final entry in entries) {
      minWeight = entry.weightLb < minWeight ? entry.weightLb : minWeight;
      maxWeight = entry.weightLb > maxWeight ? entry.weightLb : maxWeight;
    }
    minWeight -= 5;
    maxWeight += 5;
    final weekRange = 40.0;

    double xForWeek(int week) =>
        week / weekRange * size.width;
    double yForWeight(double weight) =>
        size.height - (weight - minWeight) / (maxWeight - minWeight) * size.height;

    final trimesterWidths = [
      xForWeek(13),
      xForWeek(26) - xForWeek(13),
      size.width - xForWeek(26),
    ];
    final trimesterLabels = ['FIRST\nTRIMESTER', 'SECOND\nTRIMESTER', 'THIRD\nTRIMESTER'];
    double xOffset = 0;

    for (int i = 0; i < 3; i++) {
      final rect = Rect.fromLTWH(xOffset, 0, trimesterWidths[i], size.height);
      canvas.drawRect(rect, Paint()..color = trimesterColors[i]);

      final tp = TextPainter(
        text: TextSpan(
          text: trimesterLabels[i],
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: trimesterWidths[i]);
      tp.paint(canvas, Offset(xOffset + (trimesterWidths[i] - tp.width) / 2,
          size.height / 2 - tp.height / 2));
      xOffset += trimesterWidths[i];
    }

    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    for (double w = minWeight; w <= maxWeight; w += 4) {
      final y = yForWeight(w);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: w.toInt().toString(),
          style: const TextStyle(fontSize: 9, color: Color(0xFF9E9E9E)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width - 4, y - tp.height / 2));
    }

    final currentPath = Path();
    currentPath.moveTo(xForWeek(0), yForWeight(startWeight));
    if (entries.isNotEmpty) {
      for (final entry in entries) {
        currentPath.lineTo(
          xForWeek(entry.week.clamp(0, 40).toInt()),
          yForWeight(entry.weightLb),
        );
      }
    }

    canvas.drawPath(
      currentPath,
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(xForWeek(0), yForWeight(startWeight)),
      5,
      Paint()..color = const Color(0xFFFFA726),
    );


    for (final week in weeks) {
      final tp = TextPainter(
        text: TextSpan(
          text: '$week',
          style: const TextStyle(fontSize: 9, color: Color(0xFF9E9E9E)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(xForWeek(week) - tp.width / 2, size.height + 4));
    }
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) =>
      old.entries != entries ||
      old.startWeight != startWeight;
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF555555))),
      ],
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;

  const _StatCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9E9E9E),
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFE0E0E0),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13, color: Color(0xFF9E9E9E)));
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 36,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3F2868) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon,
            size: 18,
            color:
                selected ? Colors.white : const Color(0xFF9E9E9E)),
      ),
    );
  }
}
