import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/mood_local_datasource.dart';
import 'package:mummymap/data/datasources/mood_track_datasource.dart';
import 'package:mummymap/data/models/mood_track_model.dart';
import 'package:mummymap/domain/repositories/mood_track_repository.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';

final moodLocalDatasourceProvider = Provider<MoodLocalDatasource>((ref) {
  return MoodLocalDatasource();
});

final moodTrackDatasourceProvider = Provider<MoodTrackDatasource>((ref) {
  return MoodTrackDatasource(ref.read(dioProvider));
});

final moodTrackRepositoryProvider = Provider<MoodTrackRepository>((ref) {
  final profile = ref.watch(profileProvider).value;
  final userId = profile?.userId ?? profile?.id ?? '';
  return MoodTrackRepository(
    ref.read(moodTrackDatasourceProvider),
    ref.read(moodLocalDatasourceProvider),
    userId,
  );
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
    final entry = MoodLog(
      id: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
      mood: MoodType.fromUiLabel(uiLabel),
      notes: notes,
      loggedAt: loggedAt ?? DateTime.now(),
    );
    await _repository.logMood(entry);
    state = false;
    return true;
  }
}

final moodTrackProvider =
    StateNotifierProvider<MoodTrackNotifier, bool>(
  (ref) => MoodTrackNotifier(ref.read(moodTrackRepositoryProvider)),
);