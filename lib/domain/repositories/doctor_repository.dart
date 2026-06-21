import 'package:mummymap/data/models/doctor_model.dart';

abstract class DoctorRepository {
  Future<List<Doctor>> getDoctors();
  Future<List<DoctorReview>> getReviews(String doctorId);
  Future<List<DoctorAppointment>> getUpcomingAppointments();
  Future<List<DoctorAppointment>> getScheduledAppointments();
  Future<List<DoctorAppointment>> getHistoryAppointments();
  Future<DoctorAppointment> getAppointmentDetail(String appointmentId);
  Future<void> bookAppointment({
    required String doctorId,
    required String date,
    required String time,
    required String callType,
  });
  Future<void> submitReview({
    required String doctorId,
    required double rating,
    required String body,
  });
  Future<ChatMessage> sendMessage({
    required String appointmentId,
    required String text,
  });
}