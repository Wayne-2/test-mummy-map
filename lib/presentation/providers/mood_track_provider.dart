import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/mood_track_datasource.dart';
import 'package:mummymap/data/models/mood_track_model.dart';
import 'package:mummymap/domain/repositories/mood_track_repository.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';

final moodTrackDatasourceProvider = Provider<MoodTrackDatasource>((ref) {
  return MoodTrackDatasource(ref.read(dioProvider));
});

final moodTrackRepositoryProvider = Provider<MoodTrackRepository>((ref) {
  return MoodTrackRepository(ref.read(moodTrackDatasourceProvider));
});

class MoodTrackNotifier extends StateNotifier<bool> {
  final MoodTrackRepository _repository;

  MoodTrackNotifier(this._repository) : super(false);

  Future<bool> logMood({
    required String uiLabel,
    required String notes,
    DateTime? loggedAt,
  }) async {
    state = true;
    try {
      final entry = MoodLog(
        mood: MoodType.fromUiLabel(uiLabel),
        notes: notes,
        loggedAt: loggedAt ?? DateTime.now(),
      );
      await _repository.logMood(entry);
      state = false;
      return true;
    } catch (e) {
      state = false;
      return false;
    }
  }
}

final moodTrackProvider =
    StateNotifierProvider<MoodTrackNotifier, bool>(
  (ref) => MoodTrackNotifier(ref.read(moodTrackRepositoryProvider)),
);