import 'package:mummymap/data/datasources/doctor_remote_datasource.dart';
import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/domain/repositories/doctor_repository.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource _remote;

  DoctorRepositoryImpl(this._remote);

  @override
  Future<List<Doctor>> getDoctors() => _remote.getDoctors();

  @override
  Future<List<DoctorReview>> getReviews(String doctorId) =>
      _remote.getReviews(doctorId);

  @override
  Future<List<DoctorAppointment>> getUpcomingAppointments() =>
      _remote.getUpcomingAppointments();

  @override
  Future<List<DoctorAppointment>> getScheduledAppointments() =>
      _remote.getScheduledAppointments();

  @override
  Future<List<DoctorAppointment>> getHistoryAppointments() =>
      _remote.getHistoryAppointments();

  @override
  Future<DoctorAppointment> getAppointmentDetail(String appointmentId) =>
      _remote.getAppointmentDetail(appointmentId);

  @override
  Future<void> bookAppointment({
    required String doctorId,
    required String date,
    required String time,
    required String callType,
  }) =>
      _remote.bookAppointment(
        doctorId: doctorId,
        date: date,
        time: time,
        callType: callType,
      );

  @override
  Future<void> submitReview({
    required String doctorId,
    required double rating,
    required String body,
  }) =>
      _remote.submitReview(doctorId: doctorId, rating: rating, body: body);

  @override
  Future<ChatMessage> sendMessage({
    required String appointmentId,
    required String text,
  }) =>
      _remote.sendMessage(appointmentId: appointmentId, text: text);
}