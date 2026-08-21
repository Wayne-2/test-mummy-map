import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/presentation/pages/side/doctors/minor%20screens/call_ended_screen.dart';
import 'package:mummymap/presentation/pages/side/doctors/widgets/call_control_bar.dart';
import 'package:mummymap/presentation/providers/agora_provider.dart';
import 'package:mummymap/utils/agora_services.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final Doctor doctor;
  final String roomId;

  const VideoCallScreen({super.key, required this.doctor, required this.roomId});

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  Timer? _timer;
  int _seconds = 0;

  bool _connecting = true;
  bool _joined = false;
  bool _callingFailed = false;

  bool _speakerOn = true;
  bool _cameraOn = true;
  bool _micOn = true;

  int? _remoteUid;

  late AgoraService _service;
  late String _channel;

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
        setState(() => _remoteUid = remoteUid);
      },
      onUserOffline: (connection, remoteUid, reason) {
        if (!mounted) return;
        setState(() {
          if (_remoteUid == remoteUid) _remoteUid = null;
        });
      },
      onFirstRemoteVideoFrame: (connection, remoteUid, width, height, elapsed) {
        if (!mounted) return;
        setState(() => _remoteUid = remoteUid);
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
      await service.joinCall(roomId: widget.roomId, video: true);
      if (!mounted) return;
      _channel = service.channel ?? '';
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

  Future<void> _toggleCamera(bool on) async {
    setState(() => _cameraOn = on);
    await _service.setCameraEnabled(on);
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

  Widget _buildRemoteView() {
    if (_callingFailed) {
      return const Center(
        child: Text(
          'Call failed. Please try again.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    if (_connecting || _joined == false) {
      return Container(
        color: const Color(0xFF1A1A1A),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: const Color(0xFFF59E0B),
              backgroundImage: NetworkImage(widget.doctor.imagePath),
            ),
            const SizedBox(height: 20),
            Text(
              widget.doctor.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
      );
    }

if (_remoteUid != null) {
      return _service.buildRemoteVideo(_remoteUid!, _channel);
    }

    return Container(
      color: const Color(0xFF1A1A1A),
      alignment: Alignment.center,
      child: const Text(
        'Waiting for the doctor to join…',
        style: TextStyle(color: Colors.white, fontSize: 16),
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
          Positioned.fill(child: _buildRemoteView()),
          if (!_callingFailed && _joined)
            Positioned(
              right: 16,
              bottom: bottomPadding + 140,
              child: Container(
                width: 110,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _cameraOn ? _service.buildLocalPreview() : Container(color: Colors.black),
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
          if (_connecting && !_callingFailed)
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
                  child: const Text(
                    'Connecting…',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
              cameraOn: _cameraOn,
              micOn: _micOn,
              onToggleSpeaker: () => _toggleSpeaker(!_speakerOn),
              onToggleCamera: () => _toggleCamera(!_cameraOn),
              onToggleMic: () => _toggleMic(!_micOn),
              onEndCall: _endCall,
            ),
          ),
        ],
      ),
    );
  }
}