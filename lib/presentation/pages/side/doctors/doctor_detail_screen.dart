import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/presentation/providers/doctors_provider.dart';
import 'package:mummymap/presentation/pages/side/doctors/minor%20screens/all_reviews_screen.dart';

class DoctorDetailScreen extends ConsumerStatefulWidget {
  final Doctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  ConsumerState<DoctorDetailScreen> createState() =>
      _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends ConsumerState<DoctorDetailScreen> {
  int _selectedDayIndex = 3;
  String? _selectedTime;
  String _selectedCallType = 'Audio';
  bool _aboutExpanded = false;

  List<DoctorReview> _reviews = const [];
  bool _reviewsLoading = true;

  final List<Map<String, String>> _days = [
    {'label': 'Sat', 'date': '12'},
    {'label': 'Sun', 'date': '13'},
    {'label': 'Mon', 'date': '14'},
    {'label': 'Tue', 'date': '15'},
    {'label': 'Wed', 'date': '16'},
    {'label': 'Thu', 'date': '17'},
    {'label': 'Fri', 'date': '18'},
  ];

  final Map<String, List<String>> _timeSlots = {
    'Morning': ['09-10 AM', '10-11 AM', '11-12 AM', '12-01 PM'],
    'Afternoon': ['05-06 PM', '07-08 PM', '08-10 PM', '11-12 PM'],
    'Evening': ['05-06 PM', '07-08 PM', '08-10 PM', '11-12 PM'],
  };

  final Map<String, bool> _sectionExpanded = {
    'Morning': true,
    'Afternoon': true,
    'Evening': true,
  };

  final Map<String, IconData> _sectionIcons = {
    'Morning': Icons.wb_sunny_outlined,
    'Afternoon': Icons.wb_sunny,
    'Evening': Icons.nightlight_round,
  };

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews =
        await ref.read(doctorsProvider.notifier).loadReviews(widget.doctor.id);
    if (!mounted) return;
    setState(() {
      _reviews = reviews;
      _reviewsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isBooking = ref.watch(doctorsProvider).isBooking;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
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
                    'Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorHeader(),
                  const SizedBox(height: 20),
                  _buildStatCards(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildWorkingHours(),
                  const SizedBox(height: 24),
                  _buildSchedule(),
                  const SizedBox(height: 24),
                  _buildChooseTimes(),
                  const SizedBox(height: 24),
                  _buildCallType(),
                  const SizedBox(height: 24),
                  _buildReviews(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isBooking
                    ? null
                    : () => _showBookingConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F2868),
                  disabledBackgroundColor:
                      const Color(0xFF3F2868).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: isBooking
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Book Appointment (${widget.doctor.fee})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorHeader() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            widget.doctor.imagePath,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person,
                  color: Color(0xFF3F2868), size: 40),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.doctor.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.doctor.specialty}  •  ${widget.doctor.hospital}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9E9E9E)),
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ...List.generate(5, (i) {
                    if (i < widget.doctor.rating.floor()) {
                      return const Icon(Icons.star,
                          color: Color(0xFFFFC107), size: 14);
                    } else if (i < widget.doctor.rating) {
                      return const Icon(Icons.star_half,
                          color: Color(0xFFFFC107), size: 14);
                    }
                    return const Icon(Icons.star_outline,
                        color: Color(0xFFFFC107), size: 14);
                  }),
                  const SizedBox(width: 4),
                  Text(
                    '(${widget.doctor.reviewCount} reviews)',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.phone_outlined,
              color: Color(0xFF3F2868), size: 18),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    final stats = [
      {
        'icon': Icons.people_outline,
        'color': const Color(0xFF3B82F6),
        'bg': const Color(0xFFEFF6FF),
        'value': '${widget.doctor.patients}',
        'label': 'Patients',
      },
      {
        'icon': Icons.camera_alt_outlined,
        'color': const Color(0xFFEC4899),
        'bg': const Color(0xFFFDF2F8),
        'value': widget.doctor.experience,
        'label': 'Experience',
      },
      {
        'icon': Icons.star_outline,
        'color': const Color(0xFFF59E0B),
        'bg': const Color(0xFFFFFBEB),
        'value': '${widget.doctor.rating}',
        'label': 'Ratings',
      },
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
                right: stats.indexOf(s) < stats.length - 1 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: s['bg'] as Color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: s['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(s['icon'] as IconData,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  s['value'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s['label'] as String,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Doctor',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF555555), height: 1.6),
            children: [
              TextSpan(
                text: _aboutExpanded
                    ? widget.doctor.about
                    : widget.doctor.about.length > 100
                        ? '${widget.doctor.about.substring(0, 100)}...'
                        : widget.doctor.about,
              ),
              if (widget.doctor.about.length > 100)
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _aboutExpanded = !_aboutExpanded),
                    child: Text(
                      _aboutExpanded ? '  See Less' : '  See More',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3F2868),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Working Hours',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Color(0xFF9E9E9E)),
            const SizedBox(width: 8),
            Text(
              widget.doctor.workingHours,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF555555)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Icon(Icons.calendar_month_outlined,
                color: Color(0xFF9E9E9E), size: 20),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedDayIndex == index;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedDayIndex = index),
                child: Container(
                  width: 48,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3F2868)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: isSelected
                        ? null
                        : Border.all(color: Colors.transparent),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _days[index]['label']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white70
                              : const Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _days[index]['date']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChooseTimes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Times',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        ..._timeSlots.entries.map((entry) {
          final section = entry.key;
          final slots = entry.value;
          final isExpanded = _sectionExpanded[section] ?? true;

          return Column(
            children: [
              GestureDetector(
                onTap: () => setState(() =>
                    _sectionExpanded[section] = !isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Icon(_sectionIcons[section],
                          size: 16, color: const Color(0xFF9E9E9E)),
                      const SizedBox(width: 8),
                      Text(
                        section,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF9E9E9E),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: slots.map((slot) {
                    final isSelected = _selectedTime == slot;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedTime = slot),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3F2868)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF3F2868)
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF555555),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 4),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCallType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Call Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['Audio', 'Video'].map((type) {
            final isSelected = _selectedCallType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedCallType = type),
                child: Container(
                  margin: EdgeInsets.only(
                      right: type == 'Audio' ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEDE7F6)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF3F2868)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        type == 'Audio'
                            ? Icons.phone_outlined
                            : Icons.videocam_outlined,
                        size: 16,
                        color: isSelected
                            ? const Color(0xFF3F2868)
                            : const Color(0xFF9E9E9E),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF3F2868)
                              : const Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllReviewsScreen(
                    doctorId: widget.doctor.id,
                    reviewCount: widget.doctor.reviewCount,
                  ),
                ),
              ),
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3F2868),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_reviewsLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF3F2868),
                  strokeWidth: 2.5,
                ),
              ),
            ),
          )
        else
          ..._reviews.map((r) => _ReviewCard(review: r)),
      ],
    );
  }

  void _showBookingConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Confirm Appointment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            _ConfirmRow(label: 'Doctor', value: widget.doctor.name),
            _ConfirmRow(
              label: 'Date',
              value:
                  '${_days[_selectedDayIndex]['label']} ${_days[_selectedDayIndex]['date']}',
            ),
            _ConfirmRow(
              label: 'Time',
              value: _selectedTime ?? 'Not selected',
            ),
            _ConfirmRow(label: 'Call Type', value: _selectedCallType),
            _ConfirmRow(label: 'Fee', value: widget.doctor.fee),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _confirmBooking(sheetContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F2868),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm & Pay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking(BuildContext sheetContext) async {
    Navigator.pop(sheetContext);
    final success = await ref.read(doctorsProvider.notifier).book(
          doctorId: widget.doctor.id,
          date:
              '${_days[_selectedDayIndex]['label']} ${_days[_selectedDayIndex]['date']}',
          time: _selectedTime ?? '',
          callType: _selectedCallType,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Appointment booked successfully!'
            : 'Failed to book appointment. Please try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (success) {
      ref.read(doctorsProvider.notifier).resetBookingSuccess();
    }
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF9E9E9E))),
          Text(value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              )),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final DoctorReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              review.avatarPath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => CircleAvatar(
                radius: 20,
                backgroundColor: Colors.primaries[
                        review.author.hashCode %
                            Colors.primaries.length]
                    .shade200,
                child: Text(
                  review.author[0],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.author,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      review.date,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) {
                    if (i < review.rating.floor()) {
                      return const Icon(Icons.star,
                          color: Color(0xFFFFC107), size: 13);
                    } else if (i < review.rating) {
                      return const Icon(Icons.star_half,
                          color: Color(0xFFFFC107), size: 13);
                    }
                    return const Icon(Icons.star_outline,
                        color: Color(0xFFFFC107), size: 13);
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  review.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    height: 1.5,
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