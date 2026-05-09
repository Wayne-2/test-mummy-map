import 'package:flutter/material.dart';
import 'package:mummymap/data/models/track_models.dart';

class WeightTrackingTab extends StatefulWidget {
  const WeightTrackingTab({super.key});

  @override
  State<WeightTrackingTab> createState() => _WeightTrackingTabState();
}

class _WeightTrackingTabState extends State<WeightTrackingTab> {
  bool _showChart = false;
  List<WeightEntry> _entries = List.from(kWeightEntries);

  double get _currentWeight =>
      _entries.isEmpty ? kStartWeight : _entries.last.weightLb;

  double get _gain => _currentWeight - kStartWeight;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildViewToggle(),
          const SizedBox(height: 24),
          _showChart ? _buildChart() : _buildDonut(),
          const SizedBox(height: 24),
          _buildStatRow(),
          const SizedBox(height: 24),
          if (!_showChart) _buildWeightTable(),
          const SizedBox(height: 40),
          _buildAddButton(context),
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

  Widget _buildDonut() {
    final progress = (_gain.abs() / (kTargetWeight - kStartWeight))
        .clamp(0.0, 1.0);

    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: CustomPaint(
          painter: _DonutPainter(progress: progress, hasData: _entries.isNotEmpty),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _gain == 0
                      ? '0'
                      : '${_gain > 0 ? '+' : ''}${_gain.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F2868),
                  ),
                ),
                const Text(
                  'LB GAIN',
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

  Widget _buildChart() {
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
              painter: _WeightChartPainter(entries: _entries),
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
              _Legend(color: const Color(0xFFFFA726), label: 'Current Weight'),
              const SizedBox(width: 20),
              _Legend(color: const Color(0xFF3F2868), label: 'Target Weight'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCol(label: 'START WEIGHT', value: '${kStartWeight} LB'),
          const _VertDivider(),
          _StatCol(label: 'CURRENT WEIGHT', value: '${_currentWeight.toStringAsFixed(1)} LB'),
          const _VertDivider(),
          _StatCol(label: 'TARGET WEIGHT', value: '${kTargetWeight} LB'),
        ],
      ),
    );
  }

  Widget _buildWeightTable() {
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
          ..._entries.map((e) {
            final change = e.weightLb - kStartWeight;
            final changeStr =
                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}LB';
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
                      '${e.week}',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${e.weightLb} LB',
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

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddWeightDialog(context),
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

  void _showAddWeightDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AddWeightDialog(
        onAdd: (wholePart, decimalPart, date) {
          final weight = wholePart + decimalPart / 10;
          setState(() {
            _entries.add(WeightEntry(
              date: date,
              week: _computeWeek(date),
              weightLb: weight,
            ));
          });
        },
      ),
    );
  }

  int _computeWeek(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    return ((date.difference(start).inDays) / 7).ceil();
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month];
  }
}

class _AddWeightDialog extends StatefulWidget {
  final void Function(double whole, double decimal, DateTime date) onAdd;

  const _AddWeightDialog({required this.onAdd});

  @override
  State<_AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<_AddWeightDialog> {
  DateTime _selectedDate = DateTime.now();
  String _unit = 'LB';
  double _whole = 133;
  double _decimal = 3;
  bool _showCalendar = false;

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
                  if (v != null) setState(() => _unit = v);
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
                min: 80,
                max: 200,
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
                  widget.onAdd(_whole, _decimal, _selectedDate);
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
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  return GestureDetector(
                    onTap: () =>
                        setLocalState(() => _selectedDate = date),
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

  _WeightChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    final weeks = [0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40];
    final trimesterColors = [
      const Color(0xFFFFE0B2).withOpacity(0.4),
      const Color(0xFFC8E6C9).withOpacity(0.4),
      const Color(0xFFBBDEFB).withOpacity(0.4),
    ];

    final minWeight = 128.0;
    final maxWeight = 168.0;
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
    currentPath.moveTo(xForWeek(0), yForWeight(kStartWeight));
    currentPath.lineTo(xForWeek(13), yForWeight(135.0));
    currentPath.lineTo(xForWeek(26), yForWeight(144.0));
    if (entries.isNotEmpty) {
      currentPath.lineTo(xForWeek(entries.last.week),
          yForWeight(entries.last.weightLb));
    }

    canvas.drawPath(
      currentPath,
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    final targetPath = Path();
    targetPath.moveTo(xForWeek(26), yForWeight(148.0));
    targetPath.lineTo(xForWeek(40), yForWeight(kTargetWeight));

    canvas.drawPath(
      targetPath,
      Paint()
        ..color = const Color(0xFF3F2868)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(xForWeek(0), yForWeight(kStartWeight)),
      5,
      Paint()..color = const Color(0xFFFFA726),
    );

    canvas.drawCircle(
      Offset(xForWeek(40), yForWeight(kTargetWeight)),
      5,
      Paint()..color = const Color(0xFF3F2868),
    );

    final targetLabel = TextPainter(
      text: const TextSpan(
        text: 'Target\n162.3',
        style: TextStyle(fontSize: 9, color: Color(0xFF3F2868)),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    targetLabel.paint(
      canvas,
      Offset(size.width - targetLabel.width - 4,
          yForWeight(kTargetWeight) - 30),
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
      old.entries != entries;
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