import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/presentation/providers/doctors_provider.dart';
import 'package:mummymap/presentation/pages/side/doctors/doctor_detail_screen.dart';
import 'package:mummymap/presentation/pages/side/doctors/minor%20screens/video_call_screen.dart';

class AppointmentDetailScreen extends ConsumerStatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  ConsumerState<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState
    extends ConsumerState<AppointmentDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  DoctorAppointment? _appointment;
  bool _loading = true;
  List<ChatMessage> _messages = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final appointment = await ref
        .read(doctorsProvider.notifier)
        .loadAppointmentDetail(widget.appointmentId);
    if (!mounted) return;
    setState(() {
      _appointment = appointment;
      _messages = appointment?.messages ?? const [];
      _loading = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    final message = await ref.read(doctorsProvider.notifier).send(
          appointmentId: widget.appointmentId,
          text: text,
        );
    if (!mounted || message == null) return;
    setState(() => _messages = [..._messages, message]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF3F2868)),
              )
            : _appointment == null
                ? const Center(
                    child: Text(
                      'Appointment not found',
                      style:
                          TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                    ),
                  )
                : _buildContent(_appointment!),
      ),
    );
  }

  Widget _buildContent(DoctorAppointment appointment) {
    final chatExpired = appointment.chatWindowLabel.startsWith('0 ');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Appointment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              _buildDoctorRow(appointment),
              const SizedBox(height: 20),
              _buildStatCards(appointment),
              if (_canJoinCall(appointment)) ...[
                const SizedBox(height: 16),
                _buildJoinCallButton(appointment),
              ],
              const SizedBox(height: 16),
              _buildDateTimeRow(appointment),
              const SizedBox(height: 24),
              _buildReviewSection(),
              const SizedBox(height: 24),
              _buildChatHeader(chatExpired, appointment.chatWindowLabel),
              const SizedBox(height: 16),
              ..._messages.map((m) => _ChatBubble(message: m)),
            ],
          ),
        ),
        _buildInputBar(chatExpired),
      ],
    );
  }

  Widget _buildDoctorRow(DoctorAppointment appointment) {
    final doctor = appointment.doctor;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Image.asset(
            doctor.imagePath,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5F5),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.person,
                  color: Color(0xFF3F2868), size: 32),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${doctor.specialty}  •  ${doctor.hospital}',
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ..._stars(doctor.rating, 13),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorDetailScreen(doctor: doctor),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Visit Profile',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3F2868),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            size: 16, color: Color(0xFF3F2868)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _StatusBadge(status: appointment.status),
      ],
    );
  }

  Widget _buildStatCards(DoctorAppointment appointment) {
    final stats = [
      {
        'icon': Icons.access_time,
        'color': const Color(0xFF3B82F6),
        'bg': const Color(0xFFEFF6FF),
        'value': appointment.hoursSpent,
        'label': 'Hours Spent',
      },
      {
        'icon': Icons.camera_alt_outlined,
        'color': const Color(0xFFEC4899),
        'bg': const Color(0xFFFDF2F8),
        'value': appointment.bookingFee,
        'label': 'Booking Fee',
      },
      {
        'icon': Icons.star_outline,
        'color': const Color(0xFFF59E0B),
        'bg': const Color(0xFFFFFBEB),
        'value': '${appointment.doctor.rating}',
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s['label'] as String,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _canJoinCall(DoctorAppointment appointment) {
    return appointment.status == AppointmentStatus.scheduled &&
        appointment.callType.toLowerCase().contains('video');
  }

  Widget _buildJoinCallButton(DoctorAppointment appointment) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _joinVideoCall(appointment),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F2868),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.videocam, size: 20),
        label: const Text(
          'Join Video Call',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _joinVideoCall(DoctorAppointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          doctor: appointment.doctor,
          roomId: appointment.id,
        ),
      ),
    );
  }

  Widget _buildDateTimeRow(DoctorAppointment appointment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 16, color: Color(0xFF3F2868)),
          const SizedBox(width: 8),
          Text(
            appointment.date,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const Icon(Icons.access_time, size: 16, color: Color(0xFF3F2868)),
          const SizedBox(width: 8),
          Text(
            appointment.time,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE8D5F5),
              child:
                  Icon(Icons.person, color: Color(0xFF3F2868), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'You',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Text(
                        '31 mins ago',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(children: _stars(3.5, 13)),
                  const SizedBox(height: 6),
                  const Text(
                    'I had a wonderful session with Dr. Kim. He was really honest, gave me insightful ideas oon how to care of myself even in this delicate situation, and challenged me to find myself and take charge to becoming a better woman',
                    style: TextStyle(
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
      ],
    );
  }

  Widget _buildChatHeader(bool expired, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Meeting Chat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: expired
                ? const Color(0xFFFFEBEE)
                : const Color(0xFFEDE7F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time,
                  size: 14,
                  color: expired
                      ? const Color(0xFFE53935)
                      : const Color(0xFF3F2868)),
              const SizedBox(width: 6),
              Text(
                'Chat Window: $label',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: expired
                      ? const Color(0xFFE53935)
                      : const Color(0xFF3F2868),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar(bool expired) {
    if (expired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: const Color(0xFFF9F9F9),
        child: const Center(
          child: Text(
            'The chat window for this appointment has closed',
            style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline,
              color: Color(0xFF9E9E9E), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Type in your message...',
                hintStyle:
                    TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: const Icon(Icons.send, color: Color(0xFF3F2868), size: 22),
          ),
        ],
      ),
    );
  }

  List<Widget> _stars(double rating, double size) {
    return List.generate(5, (i) {
      if (i < rating.floor()) {
        return Icon(Icons.star, color: const Color(0xFFFFC107), size: size);
      } else if (i < rating) {
        return Icon(Icons.star_half,
            color: const Color(0xFFFFC107), size: size);
      }
      return Icon(Icons.star_outline,
          color: const Color(0xFFFFC107), size: size);
    });
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

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  message.avatarPath,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.primaries[
                            message.authorName.hashCode %
                                Colors.primaries.length]
                        .shade200,
                    child: Text(
                      message.authorName[0],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                message.authorName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '•  ${message.timeLabel}',
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (message.hasAttachment)
            _AttachmentCard(
              name: message.attachmentName!,
              size: message.attachmentSize ?? '',
            ),
          if (message.text != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                message.text!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final String name;
  final String size;

  const _AttachmentCard({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.picture_as_pdf,
                color: Color(0xFFE53935), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  size,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
          const Icon(Icons.download, color: Color(0xFF9E9E9E), size: 20),
        ],
      ),
    );
  }
}