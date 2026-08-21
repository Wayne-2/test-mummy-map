import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/weight_track_datasource.dart';
import 'package:mummymap/data/models/weight_track_model.dart';
import 'package:mummymap/domain/repositories/weight_track_repository.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';

import 'package:mummymap/data/datasources/weight_track_local_datasource.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';

final weightTrackLocalDatasourceProvider = Provider<WeightTrackLocalDatasource>((ref) {
  return WeightTrackLocalDatasource();
});

final weightTrackDatasourceProvider = Provider<WeightTrackDatasource>((ref) {
  return WeightTrackDatasource(ref.read(dioProvider));
});

final weightTrackRepositoryProvider = Provider<WeightTrackRepository>((ref) {
  final profile = ref.watch(profileProvider).value;
  final userId = profile?.userId ?? profile?.id ?? '';
  return WeightTrackRepository(
    ref.read(weightTrackDatasourceProvider),
    ref.read(weightTrackLocalDatasourceProvider),
    userId,
  );
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
    try {
      final local = await _repository.getLocalHistory();
      if (local.isNotEmpty) {
        state = state.copyWith(entries: local);
      }
    } catch (_) {}

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final remoteEntries = await _repository.getHistory();
      
      final localPending = state.entries.where((e) => e.isPendingSync).toList();
      final uniqueMerged = <WeightLog>[];
      final seenDates = <String>{};
      
      for (final e in [...remoteEntries, ...localPending]) {
        final dateKey = '${e.recordedAt.year}-${e.recordedAt.month}-${e.recordedAt.day}';
        if (!seenDates.contains(dateKey)) {
          seenDates.add(dateKey);
          uniqueMerged.add(e);
        } else if (!e.isPendingSync) { 
          final idx = uniqueMerged.indexWhere((x) => _isSameDay(x.recordedAt, e.recordedAt));
          if (idx != -1) uniqueMerged[idx] = e;
        }
      }

      uniqueMerged.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      state = state.copyWith(entries: uniqueMerged, isLoading: false);
      await _repository.saveLocalHistory(uniqueMerged);

      // Push any offline entries to the server now that we're online.
      await _repository.flushPending();
      final afterSync = await _repository.getLocalHistory();
      if (afterSync.isNotEmpty) {
        state = state.copyWith(entries: afterSync);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: state.entries.isEmpty ? 'Could not load weight history.' : null,
      );
    }
  }

  Future<String?> addWeightKg(double weightKg, DateTime date, {int? week}) async {
    if (!weightKg.isFinite || weightKg <= 0 || date.isAfter(DateTime.now())) {
      return 'Enter a valid weight and date.';
    }
    if (state.entries.any((entry) => _isSameDay(entry.recordedAt, date))) {
      return 'A weight has already been recorded for this date.';
    }
    state = state.copyWith(isSaving: true, clearError: true);
    final entry = WeightLog(
      id: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
      weightKg: weightKg,
      recordedAt: date,
      week: week,
      isPendingSync: true,
    );

    final previousEntries = state.entries;
    final optimisticList = List<WeightLog>.from(previousEntries)
      ..removeWhere((e) => e.recordedAt.year == date.year && e.recordedAt.month == date.month && e.recordedAt.day == date.day)
      ..add(entry);
    optimisticList.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    state = state.copyWith(entries: optimisticList);

    // Save locally immediately so it doesn't disappear
    try {
      await _repository.saveLocalHistory(optimisticList);
    } catch (_) {
      state = state.copyWith(isSaving: false);
      return 'Could not save weight locally. Please try again.';
    }

    try {
      final saved = await _repository.logWeight(entry);
      final synced = saved.copyWith(isPendingSync: false);
      final syncedEntries = state.entries
          .where((log) => log.id != entry.id)
          .toList()
        ..removeWhere((log) => _isSameDay(log.recordedAt, date))
        ..add(synced)
        ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      await _repository.saveLocalHistory(syncedEntries);
      state = state.copyWith(entries: syncedEntries);
      await load();
      state = state.copyWith(isSaving: false);
      return null;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
      );
      // We don't revert optimisticList here because we want it to persist offline!
      return 'Could not sync weight. Saved offline.';
    }
  }

  Future<String?> addWeightLb(double weightLb, DateTime date, {int? week}) =>
      addWeightKg(lbToKg(weightLb), date, week: week);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

final weightTrackProvider =
    StateNotifierProvider<WeightTrackNotifier, WeightTrackState>(
  (ref) => WeightTrackNotifier(ref.read(weightTrackRepositoryProvider)),
);
