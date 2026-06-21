import 'package:flutter/material.dart';

class CallControlBar extends StatelessWidget {
  final bool speakerOn;
  final bool cameraOn;
  final bool micOn;
  final bool cameraEnabled;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleMic;
  final VoidCallback onEndCall;
  final bool light;

  const CallControlBar({
    super.key,
    required this.speakerOn,
    required this.cameraOn,
    required this.micOn,
    required this.onToggleSpeaker,
    required this.onToggleCamera,
    required this.onToggleMic,
    required this.onEndCall,
    this.cameraEnabled = true,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = light ? const Color(0xFFF5F5F5) : Colors.white;
    final iconColor = const Color(0xFF1A1A1A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CircleButton(
          icon: speakerOn ? Icons.volume_up : Icons.volume_off,
          background: buttonColor,
          iconColor: iconColor,
          onTap: onToggleSpeaker,
        ),
        _CircleButton(
          icon: cameraOn ? Icons.videocam : Icons.videocam_off,
          background: buttonColor,
          iconColor: cameraEnabled ? iconColor : const Color(0xFFBDBDBD),
          onTap: cameraEnabled ? onToggleCamera : () {},
        ),
        _CircleButton(
          icon: micOn ? Icons.mic : Icons.mic_off,
          background: buttonColor,
          iconColor: iconColor,
          onTap: onToggleMic,
        ),
        _CircleButton(
          icon: Icons.call_end,
          background: const Color(0xFFE53935),
          iconColor: Colors.white,
          onTap: onEndCall,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}