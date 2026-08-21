import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/mood_track_provider.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';
import 'package:mummymap/presentation/providers/shop_provider.dart';
import 'package:mummymap/presentation/providers/weight_track_provider.dart';

class SyncService {
  SyncService(this._ref);

  final Ref _ref;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) flushPending();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => flushPending());
  }

  Future<void> flushPending() async {
    final profile = _ref.read(profileProvider).value;
    final userId = profile?.userId ?? '';
    if (userId.isEmpty) return;

    try {
      await _ref.read(weightTrackRepositoryProvider).flushPending();
    } catch (_) {}
    try {
      await _ref.read(moodTrackRepositoryProvider).flushPending();
    } catch (_) {}
    try {
      await _ref.read(shopRepositoryProvider).flushPendingCartOps();
    } catch (_) {}
  }

  void dispose() {
    _subscription?.cancel();
    _started = false;
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref)..start();
});