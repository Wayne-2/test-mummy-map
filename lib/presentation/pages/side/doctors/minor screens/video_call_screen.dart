import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/presentation/pages/side/doctors/minor%20screens/call_ended_screen.dart';
import 'package:mummymap/presentation/pages/side/doctors/widgets/call_control_bar.dart';

class VideoCallScreen extends StatefulWidget {
  final Doctor doctor;

  const VideoCallScreen({super.key, required this.doctor});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
 
  Timer? _timer;
  int _seconds = 13500;
  bool _speakerOn = true;
  bool _cameraOn = true;
  bool _micOn = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_seconds > 0) _seconds--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final h = (_seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _endCall() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CallEndedScreen(
          doctor: widget.doctor,
          durationLabel: '30:00 Minutes',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.doctor.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF2A2A2A),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white24, size: 120),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 28),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formattedTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: bottomPadding + 120,
            child: Container(
              width: 110,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/avatars/me.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF3A3A3A),
                    child: const Center(
                      child: Icon(Icons.person,
                          color: Colors.white24, size: 48),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: bottomPadding + 100,
            child: Text(
              widget.doctor.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPadding + 20,
            child: CallControlBar(
              speakerOn: _speakerOn,
              cameraOn: _cameraOn,
              micOn: _micOn,
              onToggleSpeaker: () =>
                  setState(() => _speakerOn = !_speakerOn),
              onToggleCamera: () => setState(() => _cameraOn = !_cameraOn),
              onToggleMic: () => setState(() => _micOn = !_micOn),
              onEndCall: _endCall,
            ),
          ),
        ],
      ),
    );
  }
}