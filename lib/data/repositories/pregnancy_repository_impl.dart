import 'package:mummymap/data/datasources/pregnancy_local_datasource.dart';
import 'package:mummymap/data/models/pregnancy_model.dart';
import 'package:mummymap/domain/entities/pregnancy.dart';
import 'package:mummymap/domain/repositories/pregnancy_repository.dart';

class PregnancyRepositoryImpl implements PregnancyRepository {
  final PregnancyLocalDataSource localDataSource;

  PregnancyRepositoryImpl(this.localDataSource);

  @override
  Future<Pregnancy?> getPregnancy() => localDataSource.getPregnancy();

  @override
  Future<void> savePregnancy(Pregnancy pregnancy) {
    return localDataSource.savePregnancy(
      PregnancyModel(
        dueDate: pregnancy.dueDate,
        calculationMethod: pregnancy.calculationMethod,
        lastPeriodDate: pregnancy.lastPeriodDate,
        conceptionDate: pregnancy.conceptionDate,
      ),
    );
  }
}