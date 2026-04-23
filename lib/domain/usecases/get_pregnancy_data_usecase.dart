import 'package:mummymap/domain/entities/pregnancy.dart';
import 'package:mummymap/domain/repositories/pregnancy_repository.dart';

class GetPregnancyDataUseCase {
  final PregnancyRepository repository;

  GetPregnancyDataUseCase(this.repository);

  Future<Pregnancy?> call() => repository.getPregnancy();
}