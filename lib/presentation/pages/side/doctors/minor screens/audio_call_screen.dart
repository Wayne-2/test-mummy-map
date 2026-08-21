import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/presentation/pages/side/doctors/minor%20screens/call_ended_screen.dart';
import 'package:mummymap/presentation/pages/side/doctors/widgets/call_control_bar.dart';
import 'package:mummymap/presentation/providers/agora_provider.dart';
import 'package:mummymap/utils/agora_services.dart';

class AudioCallScreen extends ConsumerStatefulWidget {
  final Doctor doctor;
  final String roomId;

  const AudioCallScreen({super.key, required this.doctor, required this.roomId});

  @override
  ConsumerState<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends ConsumerState<AudioCallScreen> {
  Timer? _timer;
  int _seconds = 0;

  bool _connecting = true;
  bool _joined = false;
  bool _callingFailed = false;

  bool _speakerOn = true;
  bool _micOn = true;

  late AgoraService _service;

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _service.leaveCall();
    super.dispose();
  }

  Future<void> _startCall() async {
    final service = ref.read(agoraServiceProvider);
    _service = service;

    service.setEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        if (!mounted) return;
        setState(() {
          _joined = true;
          _connecting = false;
        });
        _startTimer();
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        if (!mounted) return;
        setState(() => _connecting = false);
      },
      onError: (err, msg) {
        if (!mounted) return;
        setState(() {
          _connecting = false;
          _callingFailed = true;
        });
      },
    ));

    try {
      await service.joinCall(roomId: widget.roomId, video: false);
      if (!mounted) return;
      await service.setSpeakerEnabled(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _callingFailed = true;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  String get _formattedTime {
    final h = (_seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _toggleSpeaker(bool on) async {
    setState(() => _speakerOn = on);
    await _service.setSpeakerEnabled(on);
  }

  Future<void> _toggleMic(bool on) async {
    setState(() => _micOn = on);
    await _service.setMicEnabled(on);
  }

  void _endCall() {
    _timer?.cancel();
    _service.leaveCall();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CallEndedScreen(
          doctor: widget.doctor,
          durationLabel: _durationLabel,
        ),
      ),
    );
  }

  String get _durationLabel {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return _seconds > 0 ? '$m:$s Minutes' : '0:00 Minutes';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: const Color(0xFFF59E0B),
                    backgroundImage: NetworkImage(widget.doctor.imagePath),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.doctor.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusLabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_joined)
            Positioned(
              top: topPadding + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    _formattedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + 32,
            child: CallControlBar(
              speakerOn: _speakerOn,
              cameraOn: false,
              micOn: _micOn,
              cameraEnabled: false,
              onToggleSpeaker: () => _toggleSpeaker(!_speakerOn),
              onToggleCamera: () {},
              onToggleMic: () => _toggleMic(!_micOn),
              onEndCall: _endCall,
            ),
          ),
        ],
      ),
    );
  }

  String get _statusLabel {
    if (_callingFailed) return 'Call failed. Please try again.';
    if (_connecting) return 'Connecting…';
    return 'Call in progress';
  }
}