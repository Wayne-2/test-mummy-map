import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraService {
  late final RtcEngine engine;

  Future<void> initialize() async {
    engine = createAgoraRtcEngine();

    await engine.initialize(
      const RtcEngineContext(
        appId: "YOUR_APP_ID",
      ),
    );

    await engine.enableVideo();
  }

  Future<void> dispose() async {
    await engine.release();
  }
}