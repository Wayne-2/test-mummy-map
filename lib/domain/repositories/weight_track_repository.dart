import 'package:mummymap/data/datasources/weight_track_datasource.dart';
import 'package:mummymap/data/models/weight_track_model.dart';

import 'package:mummymap/data/datasources/weight_track_local_datasource.dart';

class WeightTrackRepository {
  final WeightTrackDatasource datasource;
  final WeightTrackLocalDatasource localDatasource;
  final String userId;

  WeightTrackRepository(this.datasource, this.localDatasource, this.userId);

  Future<WeightLog> logWeight(WeightLog entry) => datasource.logWeight(entry);

  Future<List<WeightLog>> getHistory({DateTime? from, DateTime? to}) async {
    final local = await localDatasource.getHistory(userId);
    try {
      final remote = await datasource.getWeightHistory(from: from, to: to);
      final merged = _mergeRemoteWithPending(remote, local);
      await localDatasource.saveHistory(userId, merged);
      return merged;
    } catch (_) {
      return local;
    }
  }

  Future<List<WeightLog>> getLocalHistory() => localDatasource.getHistory(userId);

  Future<void> saveLocalHistory(List<WeightLog> entries) => localDatasource.saveHistory(userId, entries);

  Future<void> flushPending() async {
    final local = await localDatasource.getHistory(userId);
    final pending = local.where((e) => e.isPendingSync).toList();
    if (pending.isEmpty) return;

    var updated = local;
    for (final entry in pending) {
      try {
        final saved = await datasource.logWeight(entry);
        final synced = saved.copyWith(isPendingSync: false);
        updated = [
          for (final e in updated)
            if (e.id == entry.id) synced else e,
        ];
      } catch (_) {
        break;
      }
    }
    await localDatasource.saveHistory(userId, updated);
  }

  List<WeightLog> _mergeRemoteWithPending(
    List<WeightLog> remote,
    List<WeightLog> local,
  ) {
    final byDay = <String, WeightLog>{
      for (final entry in remote) _dayKey(entry.recordedAt): entry,
    };
    for (final entry in local.where((entry) => entry.isPendingSync)) {
      byDay[_dayKey(entry.recordedAt)] = entry;
    }
    final merged = byDay.values.toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return merged;
  }

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
