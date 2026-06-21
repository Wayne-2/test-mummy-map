import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/domain/repositories/doctor_repository.dart';

class GetDoctorsUseCase {
  final DoctorRepository repository;

  GetDoctorsUseCase(this.repository);

  Future<List<Doctor>> call() => repository.getDoctors();
}

class GetReviewsUseCase {
  final DoctorRepository repository;

  GetReviewsUseCase(this.repository);

  Future<List<DoctorReview>> call(String doctorId) =>
      repository.getReviews(doctorId);
}

class GetUpcomingAppointmentsUseCase {
  final DoctorRepository repository;

  GetUpcomingAppointmentsUseCase(this.repository);

  Future<List<DoctorAppointment>> call() =>
      repository.getUpcomingAppointments();
}

class GetScheduledAppointmentsUseCase {
  final DoctorRepository repository;

  GetScheduledAppointmentsUseCase(this.repository);

  Future<List<DoctorAppointment>> call() =>
      repository.getScheduledAppointments();
}

class GetHistoryAppointmentsUseCase {
  final DoctorRepository repository;

  GetHistoryAppointmentsUseCase(this.repository);

  Future<List<DoctorAppointment>> call() =>
      repository.getHistoryAppointments();
}

class GetAppointmentDetailUseCase {
  final DoctorRepository repository;

  GetAppointmentDetailUseCase(this.repository);

  Future<DoctorAppointment> call(String appointmentId) =>
      repository.getAppointmentDetail(appointmentId);
}

class BookAppointmentUseCase {
  final DoctorRepository repository;

  BookAppointmentUseCase(this.repository);

  Future<void> call({
    required String doctorId,
    required String date,
    required String time,
    required String callType,
  }) =>
      repository.bookAppointment(
        doctorId: doctorId,
        date: date,
        time: time,
        callType: callType,
      );
}

class SubmitReviewUseCase {
  final DoctorRepository repository;

  SubmitReviewUseCase(this.repository);

  Future<void> call({
    required String doctorId,
    required double rating,
    required String body,
  }) =>
      repository.submitReview(doctorId: doctorId, rating: rating, body: body);
}

class SendMessageUseCase {
  final DoctorRepository repository;

  SendMessageUseCase(this.repository);

  Future<ChatMessage> call({
    required String appointmentId,
    required String text,
  }) =>
      repository.sendMessage(appointmentId: appointmentId, text: text);
}