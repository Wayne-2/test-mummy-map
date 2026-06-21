import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/weight_track_datasource.dart';
import 'package:mummymap/data/models/weight_track_model.dart';
import 'package:mummymap/domain/repositories/weight_track_repository.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';

final weightTrackDatasourceProvider = Provider<WeightTrackDatasource>((ref) {
  return WeightTrackDatasource(ref.read(dioProvider));
});

final weightTrackRepositoryProvider = Provider<WeightTrackRepository>((ref) {
  return WeightTrackRepository(ref.read(weightTrackDatasourceProvider));
});

class WeightTrackState {
  final List<WeightLog> entries;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const WeightTrackState({
    this.entries = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  WeightTrackState copyWith({
    List<WeightLog>? entries,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WeightTrackState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class WeightTrackNotifier extends StateNotifier<WeightTrackState> {
  final WeightTrackRepository _repository;

  WeightTrackNotifier(this._repository) : super(const WeightTrackState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final entries = await _repository.getHistory();
      entries.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load weight history.',
      );
    }
  }

  Future<String?> addWeightLb(double weightLb, DateTime date, {int? week}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final entry = WeightLog(
      id: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
      weightKg: lbToKg(weightLb),
      recordedAt: date,
      week: week,
    );
    
    final previousEntries = state.entries;
    final optimisticList = List<WeightLog>.from(previousEntries)..add(entry);
    optimisticList.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    state = state.copyWith(entries: optimisticList);
    
    try {
      final saved = await _repository.logWeight(entry);
      final updated = List<WeightLog>.from(previousEntries)..add(saved);
      updated.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      state = state.copyWith(entries: updated, isSaving: false);
      return null;
    } catch (e) {
      state = state.copyWith(
        entries: previousEntries,
        isSaving: false,
        errorMessage: 'Could not save weight. Please try again.',
      );
      return 'Could not save weight. Please try again.';
    }
  }
}

final weightTrackProvider =
    StateNotifierProvider<WeightTrackNotifier, WeightTrackState>(
  (ref) => WeightTrackNotifier(ref.read(weightTrackRepositoryProvider)),
);