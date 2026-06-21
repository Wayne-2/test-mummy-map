import 'package:mummymap/data/datasources/mood_track_datasource.dart';
import 'package:mummymap/data/models/mood_track_model.dart';

class MoodTrackRepository {
  final MoodTrackDatasource datasource;

  MoodTrackRepository(this.datasource);

  Future<MoodLog> logMood(MoodLog entry) => datasource.logMood(entry);

  Future<List<MoodLog>> getHistory() => datasource.getMoodHistory();
}