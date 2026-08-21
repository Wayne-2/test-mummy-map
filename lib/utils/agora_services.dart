import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const String kAgoraAppId = String.fromEnvironment(
  'AGORA_APP_ID',
  defaultValue: '61e45614dea4487484f970967c331618',
);

class AgoraService {
  static const String _tokenEndpoint = '/api/v1/rooms/{roomId}/tokens';

  final Dio _dio;

  late final RtcEngine engine;
  bool _initialized = false;

  String? channel;
  int? uid;
  String? token;

  AgoraService(this._dio);

  Future<void> _fetchRoomToken({
    required String roomId,
    String? confirmationId,
  }) async {
    final response = await _dio.post(
      _tokenEndpoint.replaceFirst('{roomId}', roomId),
      data: {
        if (confirmationId != null) 'confirmationId': confirmationId,
      },
    );
    final data = response.data;
    final map = (data is Map<String, dynamic> && data['data'] is Map)
        ? data['data'] as Map<String, dynamic>
        : (data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{});
    token = (map['token'] ?? '') as String;
    channel = (map['channel'] ?? '') as String;
    uid = ((map['uid'] ?? 0) as num).toInt();
  }

  Future<void> _initEngine() async {
    if (_initialized) return;
    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: kAgoraAppId));
    await engine.enableVideo();
    _initialized = true;
  }

  Future<void> joinCall({
    required String roomId,
    String? confirmationId,
    bool video = true,
  }) async {
    await _fetchRoomToken(
      roomId: roomId,
      confirmationId: confirmationId,
    );
    await _initEngine();

    await engine.setChannelProfile(ChannelProfileType.channelProfileCommunication);
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.joinChannel(
      token: token!,
      channelId: channel!,
      uid: uid!,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: video,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: video,
      ),
    );
  }

  Future<void> leaveCall() async {
    if (!_initialized) return;
    await engine.leaveChannel();
  }

  Future<void> dispose() async {
    if (!_initialized) return;
    try {
      await engine.leaveChannel();
    } catch (_) {}
    try {
      await engine.release();
    } catch (_) {}
    _initialized = false;
    channel = null;
    uid = null;
  }

  Future<void> setMicEnabled(bool enabled) async {
    await engine.muteLocalAudioStream(!enabled);
  }

  Future<void> setCameraEnabled(bool enabled) async {
    await engine.muteLocalVideoStream(!enabled);
  }

  Future<void> setSpeakerEnabled(bool enabled) async {
    await engine.setEnableSpeakerphone(enabled);
  }

  void setEventHandler(RtcEngineEventHandler handler) {
    engine.registerEventHandler(handler);
  }

  Widget buildLocalPreview() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: engine,
        canvas: const VideoCanvas(uid: 0, renderMode: RenderModeType.renderModeFit),
      ),
    );
  }

  Widget buildRemoteVideo(int remoteUid, String channelId) {
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: engine,
        canvas: VideoCanvas(
          uid: remoteUid,
          renderMode: RenderModeType.renderModeFit,
        ),
        connection: RtcConnection(channelId: channelId),
      ),
    );
  }
}