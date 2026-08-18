import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/exercise_local_datasource.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';

final exerciseLocalDatasourceProvider = Provider<ExerciseLocalDatasource>((ref) {
  return ExerciseLocalDatasource();
});

class ExerciseState {
  final Set<String> completedDays;

  const ExerciseState({
    this.completedDays = const {},
  });

  bool isCompleted(int level, int dayNumber) {
    return completedDays.contains('${level}_$dayNumber');
  }

  ExerciseState copyWith({
    Set<String>? completedDays,
  }) {
    return ExerciseState(
      completedDays: completedDays ?? this.completedDays,
    );
  }
}

class ExerciseNotifier extends StateNotifier<ExerciseState> {
  final ExerciseLocalDatasource _localDatasource;
  final String _userId;

  ExerciseNotifier(this._localDatasource, this._userId) : super(const ExerciseState()) {
    _load();
  }

  Future<void> _load() async {
    final completed = await _localDatasource.getCompletedDays(_userId);
    state = state.copyWith(completedDays: completed);
  }

  Future<void> toggleDayCompletion(int level, int dayNumber) async {
    final key = '${level}_$dayNumber';
    final current = Set<String>.from(state.completedDays);
    if (current.contains(key)) {
      current.remove(key);
    } else {
      current.add(key);
    }
    state = state.copyWith(completedDays: current);
    await _localDatasource.saveCompletedDays(_userId, current);
  }
}

final exerciseProvider = StateNotifierProvider<ExerciseNotifier, ExerciseState>((ref) {
  final profile = ref.watch(profileProvider).value;
  final userId = profile?.userId ?? '';
  return ExerciseNotifier(ref.read(exerciseLocalDatasourceProvider), userId);
});
