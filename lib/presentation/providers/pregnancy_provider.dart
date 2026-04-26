import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/pregnancy_local_datasource.dart';
import 'package:mummymap/data/repositories/pregnancy_repository_impl.dart';
import 'package:mummymap/domain/entities/pregnancy.dart';
import 'package:mummymap/domain/repositories/pregnancy_repository.dart';
import 'package:mummymap/domain/usecases/calculate_due_date_use_case.dart';
import 'package:mummymap/domain/usecases/get_pregnancy_data_usecase.dart';

final pregnancyLocalDataSourceProvider = Provider(
  (_) => PregnancyLocalDataSource(),
);

final pregnancyRepositoryProvider = Provider<PregnancyRepository>(
  (ref) => PregnancyRepositoryImpl(
    ref.read(pregnancyLocalDataSourceProvider),
  ),
);

final getPregnancyDataUseCaseProvider = Provider(
  (ref) => GetPregnancyDataUseCase(
    ref.read(pregnancyRepositoryProvider),
  ),
);

final calculateDueDateUseCaseProvider = Provider(
  (_) => CalculateDueDateUseCase(),
);

class PregnancyNotifier extends StateNotifier<Pregnancy?> {
  final GetPregnancyDataUseCase _getPregnancyDataUseCase;
  final PregnancyRepository _repository;
  final CalculateDueDateUseCase _calculateDueDateUseCase;

  PregnancyNotifier(
    this._getPregnancyDataUseCase,
    this._repository,
    this._calculateDueDateUseCase,
  ) : super(null) {
    _load();
  }

  Future<void> _load() async {
    state = await _getPregnancyDataUseCase();
  }

  Future<void> savePregnancy({
    required String method,
    required DateTime date,
  }) async {
    final dueDate = _calculateDueDateUseCase(method: method, date: date);
    final pregnancy = Pregnancy(
      dueDate: dueDate,
      calculationMethod: method,
      lastPeriodDate: method == 'First Day Of Last Period' ? date : null,
      conceptionDate: method == 'Date Of Conception' ? date : null,
    );
    await _repository.savePregnancy(pregnancy);
    state = pregnancy;
  }
}

final pregnancyProvider = StateNotifierProvider<PregnancyNotifier, Pregnancy?>(
  (ref) => PregnancyNotifier(
    ref.read(getPregnancyDataUseCaseProvider),
    ref.read(pregnancyRepositoryProvider),
    ref.read(calculateDueDateUseCaseProvider),
  ),
);