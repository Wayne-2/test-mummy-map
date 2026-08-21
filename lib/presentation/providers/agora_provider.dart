import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';
import 'package:mummymap/utils/agora_services.dart';

final agoraServiceProvider = Provider<AgoraService>((ref) {
  final service = AgoraService(ref.watch(dioProvider));
  ref.onDispose(() => service.dispose());
  return service;
});