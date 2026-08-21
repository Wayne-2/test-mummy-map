import 'package:mummymap/data/datasources/mood_local_datasource.dart';
import 'package:mummymap/data/datasources/mood_track_datasource.dart';
import 'package:mummymap/data/models/mood_track_model.dart';

class MoodTrackRepository {
  final MoodTrackDatasource datasource;
  final MoodLocalDatasource localDatasource;
  final String userId;

  MoodTrackRepository(this.datasource, this.localDatasource, this.userId);

  Future<MoodLog> logMood(MoodLog entry) async {
    final logs = await localDatasource.getLogs(userId);
    try {
      final saved = await datasource.logMood(entry);
      final synced = saved.copyWith(isPendingSync: false);
      await localDatasource.saveLogs(
        userId,
        [synced, ...logs.where((l) => l.id != entry.id)],
      );
      return synced;
    } catch (_) {
      // Offline: keep the entry locally as pending and sync later.
      final pending = entry.copyWith(isPendingSync: true);
      await localDatasource.saveLogs(
        userId,
        [pending, ...logs.where((l) => l.id != entry.id)],
      );
      return pending;
    }
  }

  Future<List<MoodLog>> getHistory() => datasource.getMoodHistory();

  Future<List<MoodLog>> getLocalLogs() => localDatasource.getLogs(userId);

  Future<void> flushPending() async {
    final logs = await localDatasource.getLogs(userId);
    final pending = logs.where((l) => l.isPendingSync).toList();
    if (pending.isEmpty) return;

    var updated = logs;
    for (final entry in pending) {
      try {
        final saved = await datasource.logMood(entry);
        final synced = saved.copyWith(isPendingSync: false);
        updated = [
          for (final l in updated)
            if (l.id == entry.id) synced else l,
        ];
      } catch (_) {
        break;
      }
    }
    await localDatasource.saveLogs(userId, updated);
  }
}