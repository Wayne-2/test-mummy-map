import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/utils/agora_services.dart';

final agoraServiceProvider = Provider<AgoraService>((ref) {
  return AgoraService();
});