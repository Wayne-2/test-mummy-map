import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/presentation/providers/doctors_provider.dart';
import 'package:mummymap/presentation/pages/side/doctors/doctors_list_screen.dart';
import 'package:mummymap/presentation/pages/side/doctors/doctor_detail_screen.dart';
import 'package:mummymap/presentation/pages/side/doctors/minor%20screens/appointment_detail_screen.dart';

class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key});

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF3F2868),
              unselectedLabelColor: const Color(0xFF9E9E9E),
              indicatorColor: const Color(0xFF3F2868),
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 15),
              tabs: const [
                Tab(text: 'Doctors'),
                Tab(text: 'Appointments'),
                Tab(text: 'History'),
              ],
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3F2868),
                      ),
                    )
                  : state.errorMessage != null
                      ? _ErrorState(
                          message: state.errorMessage!,
                          onRetry: () =>
                              ref.read(doctorsProvider.notifier).refresh(),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _DoctorsTab(state: state),
                            _AppointmentsTab(appointments: state.scheduled),
                            _HistoryTab(appointments: state.history),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE8D5F5),
            child: Icon(Icons.person, color: Color(0xFF3F2868), size: 22),
          ),
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
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _DoctorsTab extends StatelessWidget {
  final DoctorsState state;

  const _DoctorsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _SearchBar(
            hint: 'Name, category, location...',
            onFilterTap: () {},
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: () {},
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
          const SizedBox(height: 12),
          state.upcoming.isEmpty
              ? const _EmptySchedule()
              : _UpcomingCard(appointment: state.upcoming.first),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Doctors',
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
                      builder: (_) => const DoctorListScreen()),
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
          const SizedBox(height: 12),
          ...state.topDoctors.map((d) => _TopDoctorCard(doctor: d)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 36, color: Color(0xFFBDBDBD)),
          SizedBox(height: 10),
          Text(
            'No upcoming appointments',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Book a doctor to see your schedule here',
            style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final DoctorAppointment appointment;

  const _UpcomingCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B3FA0), Color(0xFF9B59B6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      appointment.doctor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.videocam,
                          color: Colors.white, size: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.doctor.specialty,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${appointment.date}, ${appointment.time}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              appointment.doctor.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.person,
                    color: Colors.white70, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopDoctorCard extends StatelessWidget {
  final Doctor doctor;

  const _TopDoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DoctorDetailScreen(doctor: doctor)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                doctor.imagePath,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: const Color(0xFFE8D5F5),
                  child: const Icon(Icons.person,
                      color: Color(0xFF3F2868), size: 36),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${doctor.specialty}  •  ${doctor.hospital}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9E9E9E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _StarRating(
                      rating: doctor.rating, reviewCount: doctor.reviewCount),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Fees',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                ),
                Text(
                  doctor.fee,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DoctorDetailScreen(doctor: doctor)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F2868),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _AppointmentsTab extends StatelessWidget {
  final List<DoctorAppointment> appointments;

  const _AppointmentsTab({required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              const Text(
                'Scheduled',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today_outlined,
                    size: 18, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('Today',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF1A1A1A))),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: Color(0xFF1A1A1A)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: appointments.isEmpty
              ? const _EmptyAppointments(
                  message: 'No scheduled appointments')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) => _AppointmentListCard(
                    appointment: appointments[index],
                  ),
                ),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final List<DoctorAppointment> appointments;

  const _HistoryTab({required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: _SearchBar(
              hint: 'Name, category, location...', onFilterTap: () {}),
        ),
        Expanded(
          child: appointments.isEmpty
              ? const _EmptyAppointments(message: 'No appointment history')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) => _AppointmentListCard(
                    appointment: appointments[index],
                    showStatus: true,
                  ),
                ),
        ),
      ],
    );
  }
}

class _AppointmentListCard extends StatelessWidget {
  final DoctorAppointment appointment;
  final bool showStatus;

  const _AppointmentListCard({
    required this.appointment,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AppointmentDetailScreen(appointmentId: appointment.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                appointment.doctor.imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D5F5),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(Icons.person,
                      color: Color(0xFF3F2868), size: 30),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.doctor.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    showStatus
                        ? appointment.doctor.specialty
                        : '${appointment.doctor.specialty}  •  ${appointment.doctor.hospital}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9E9E9E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: Color(0xFF9E9E9E)),
                      const SizedBox(width: 4),
                      Text(
                        '${appointment.date}  •  ${appointment.time}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                  if (showStatus) ...[
                    const SizedBox(height: 6),
                    _StatusBadge(status: appointment.status),
                  ],
                ],
              ),
            ),
            _CallTypeIcon(callType: appointment.callType),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = status == AppointmentStatus.completed
        ? 'Completed'
        : status == AppointmentStatus.declined
            ? 'Declined'
            : 'Scheduled';
    final color = status == AppointmentStatus.completed
        ? const Color(0xFF4CAF50)
        : status == AppointmentStatus.declined
            ? const Color(0xFFE53935)
            : const Color(0xFF3F2868);
    final bgColor = status == AppointmentStatus.completed
        ? const Color(0xFFE8F5E9)
        : status == AppointmentStatus.declined
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFEDE7F6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _CallTypeIcon extends StatelessWidget {
  final String callType;

  const _CallTypeIcon({required this.callType});

  @override
  Widget build(BuildContext context) {
    final icon = callType == 'Video'
        ? Icons.videocam_outlined
        : callType == 'Message'
            ? Icons.chat_bubble_outline
            : Icons.phone_outlined;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF3F2868)),
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  final String message;

  const _EmptyAppointments({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8D5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.calendar_today_outlined,
                size: 40, color: Color(0xFF3F2868)),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Color(0xFF3F2868),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback onFilterTap;

  const _SearchBar({required this.hint, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20),
                const SizedBox(width: 10),
                Text(
                  hint,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune,
                color: Color(0xFF1A1A1A), size: 20),
          ),
        ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final int? reviewCount;

  const _StarRating({required this.rating, this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return const Icon(Icons.star, color: Color(0xFFFFC107), size: 14);
          } else if (i < rating) {
            return const Icon(Icons.star_half,
                color: Color(0xFFFFC107), size: 14);
          }
          return const Icon(Icons.star_outline,
              color: Color(0xFFFFC107), size: 14);
        }),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount reviews)',
            style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
          ),
        ],
      ],
    );
  }
}