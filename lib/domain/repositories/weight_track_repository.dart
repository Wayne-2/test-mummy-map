import 'package:mummymap/data/datasources/weight_track_datasource.dart';
import 'package:mummymap/data/models/weight_track_model.dart';

class WeightTrackRepository {
  final WeightTrackDatasource datasource;

  WeightTrackRepository(this.datasource);

  Future<WeightLog> logWeight(WeightLog entry) => datasource.logWeight(entry);

  Future<List<WeightLog>> getHistory({DateTime? from, DateTime? to}) =>
      datasource.getWeightHistory(from: from, to: to);
}