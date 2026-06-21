import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/doctor_remote_datasource.dart';
import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/data/repositories/doctor_repository_impl.dart';
import 'package:mummymap/domain/repositories/doctor_repository.dart';
import 'package:mummymap/domain/usecases/doctor_usecases.dart';

// ─── Providers ───────────────────────────────────────────────────────────────

final doctorRemoteDataSourceProvider = Provider.autoDispose(
  (_) => DoctorRemoteDataSourceImpl(),
);

final doctorRepositoryProvider = Provider.autoDispose<DoctorRepository>(
  (ref) => DoctorRepositoryImpl(ref.read(doctorRemoteDataSourceProvider)),
);

final getDoctorsUseCaseProvider = Provider.autoDispose(
  (ref) => GetDoctorsUseCase(ref.read(doctorRepositoryProvider)),
);

final getReviewsUseCaseProvider = Provider.autoDispose(
  (ref) => GetReviewsUseCase(ref.read(doctorRepositoryProvider)),
);

final getUpcomingAppointmentsUseCaseProvider = Provider.autoDispose(
  (ref) => GetUpcomingAppointmentsUseCase(ref.read(doctorRepositoryProvider)),
);

final getScheduledAppointmentsUseCaseProvider = Provider.autoDispose(
  (ref) => GetScheduledAppointmentsUseCase(ref.read(doctorRepositoryProvider)),
);

final getHistoryAppointmentsUseCaseProvider = Provider.autoDispose(
  (ref) => GetHistoryAppointmentsUseCase(ref.read(doctorRepositoryProvider)),
);

final getAppointmentDetailUseCaseProvider = Provider.autoDispose(
  (ref) => GetAppointmentDetailUseCase(ref.read(doctorRepositoryProvider)),
);

final bookAppointmentUseCaseProvider = Provider.autoDispose(
  (ref) => BookAppointmentUseCase(ref.read(doctorRepositoryProvider)),
);

final submitReviewUseCaseProvider = Provider.autoDispose(
  (ref) => SubmitReviewUseCase(ref.read(doctorRepositoryProvider)),
);

final sendMessageUseCaseProvider = Provider.autoDispose(
  (ref) => SendMessageUseCase(ref.read(doctorRepositoryProvider)),
);

final doctorsProvider = StateNotifierProvider.autoDispose<DoctorsNotifier, DoctorsState>(
  (ref) => DoctorsNotifier(
    getDoctors: ref.read(getDoctorsUseCaseProvider),
    getReviews: ref.read(getReviewsUseCaseProvider),
    getUpcoming: ref.read(getUpcomingAppointmentsUseCaseProvider),
    getScheduled: ref.read(getScheduledAppointmentsUseCaseProvider),
    getHistory: ref.read(getHistoryAppointmentsUseCaseProvider),
    getAppointmentDetail: ref.read(getAppointmentDetailUseCaseProvider),
    bookAppointment: ref.read(bookAppointmentUseCaseProvider),
    submitReview: ref.read(submitReviewUseCaseProvider),
    sendMessage: ref.read(sendMessageUseCaseProvider),
  ),
);

// ─── State ───────────────────────────────────────────────────────────────────

class DoctorsState {
  final List<Doctor> doctors;
  final List<DoctorAppointment> upcoming;
  final List<DoctorAppointment> scheduled;
  final List<DoctorAppointment> history;
  final bool isLoading;
  final String? errorMessage;
  final bool isBooking;
  final bool bookingSuccess;
  final bool isSubmittingReview;
  final bool reviewSuccess;

  const DoctorsState({
    this.doctors = const [],
    this.upcoming = const [],
    this.scheduled = const [],
    this.history = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isBooking = false,
    this.bookingSuccess = false,
    this.isSubmittingReview = false,
    this.reviewSuccess = false,
  });

  Doctor? doctorById(String id) {
    for (final doctor in doctors) {
      if (doctor.id == id) return doctor;
    }
    return null;
  }

  List<Doctor> get topDoctors => doctors.take(2).toList();

  DoctorsState copyWith({
    List<Doctor>? doctors,
    List<DoctorAppointment>? upcoming,
    List<DoctorAppointment>? scheduled,
    List<DoctorAppointment>? history,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isBooking,
    bool? bookingSuccess,
    bool? isSubmittingReview,
    bool? reviewSuccess,
  }) {
    return DoctorsState(
      doctors: doctors ?? this.doctors,
      upcoming: upcoming ?? this.upcoming,
      scheduled: scheduled ?? this.scheduled,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isBooking: isBooking ?? this.isBooking,
      bookingSuccess: bookingSuccess ?? this.bookingSuccess,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      reviewSuccess: reviewSuccess ?? this.reviewSuccess,
    );
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class DoctorsNotifier extends StateNotifier<DoctorsState> {
  final GetDoctorsUseCase _getDoctors;
  final GetReviewsUseCase _getReviews;
  final GetUpcomingAppointmentsUseCase _getUpcoming;
  final GetScheduledAppointmentsUseCase _getScheduled;
  final GetHistoryAppointmentsUseCase _getHistory;
  final GetAppointmentDetailUseCase _getAppointmentDetail;
  final BookAppointmentUseCase _bookAppointment;
  final SubmitReviewUseCase _submitReview;
  final SendMessageUseCase _sendMessage;

  DoctorsNotifier({
    required GetDoctorsUseCase getDoctors,
    required GetReviewsUseCase getReviews,
    required GetUpcomingAppointmentsUseCase getUpcoming,
    required GetScheduledAppointmentsUseCase getScheduled,
    required GetHistoryAppointmentsUseCase getHistory,
    required GetAppointmentDetailUseCase getAppointmentDetail,
    required BookAppointmentUseCase bookAppointment,
    required SubmitReviewUseCase submitReview,
    required SendMessageUseCase sendMessage,
  })  : _getDoctors = getDoctors,
        _getReviews = getReviews,
        _getUpcoming = getUpcoming,
        _getScheduled = getScheduled,
        _getHistory = getHistory,
        _getAppointmentDetail = getAppointmentDetail,
        _bookAppointment = bookAppointment,
        _submitReview = submitReview,
        _sendMessage = sendMessage,
        super(const DoctorsState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _getDoctors().catchError((_) => <Doctor>[]),
        _getUpcoming().catchError((_) => <DoctorAppointment>[]),
        _getScheduled().catchError((_) => <DoctorAppointment>[]),
        _getHistory().catchError((_) => <DoctorAppointment>[]),
      ]);
      state = state.copyWith(
        doctors: results[0] as List<Doctor>,
        upcoming: results[1] as List<DoctorAppointment>,
        scheduled: results[2] as List<DoctorAppointment>,
        history: results[3] as List<DoctorAppointment>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load doctors. Please try again.',
      );
    }
  }

  Future<void> refresh() => _init();

  Future<List<DoctorReview>> loadReviews(String doctorId) async {
    try {
      return await _getReviews(doctorId);
    } catch (_) {
      return const [];
    }
  }

  Future<DoctorAppointment?> loadAppointmentDetail(String appointmentId) async {
    try {
      return await _getAppointmentDetail(appointmentId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> book({
    required String doctorId,
    required String date,
    required String time,
    required String callType,
  }) async {
    state = state.copyWith(isBooking: true, clearError: true);
    try {
      await _bookAppointment(
        doctorId: doctorId,
        date: date,
        time: time,
        callType: callType,
      );
      state = state.copyWith(isBooking: false, bookingSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isBooking: false,
        bookingSuccess: false,
        errorMessage: 'Failed to book appointment. Please try again.',
      );
      return false;
    }
  }

  Future<bool> review({
    required String doctorId,
    required double rating,
    required String body,
  }) async {
    state = state.copyWith(isSubmittingReview: true, clearError: true);
    try {
      await _submitReview(doctorId: doctorId, rating: rating, body: body);
      state = state.copyWith(isSubmittingReview: false, reviewSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmittingReview: false,
        reviewSuccess: false,
        errorMessage: 'Failed to submit review. Please try again.',
      );
      return false;
    }
  }

  Future<ChatMessage?> send({
    required String appointmentId,
    required String text,
  }) async {
    try {
      return await _sendMessage(appointmentId: appointmentId, text: text);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void resetBookingSuccess() {
    state = state.copyWith(bookingSuccess: false);
  }

  void resetReviewSuccess() {
    state = state.copyWith(reviewSuccess: false);
  }
}