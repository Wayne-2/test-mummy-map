import 'package:mummymap/domain/entities/pregnancy.dart';

abstract class PregnancyRepository {
  Future<Pregnancy?> getPregnancy();
  Future<void> savePregnancy(Pregnancy pregnancy);
}