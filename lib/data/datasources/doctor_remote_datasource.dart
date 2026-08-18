import 'package:dio/dio.dart';
import 'package:mummymap/data/models/doctor_model.dart';

// Replace the stub returns with real Dio calls when the backend is ready.
// This file is the only place that changes when connecting to the API.

abstract class DoctorRemoteDataSource {
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

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final Dio dio;

  DoctorRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Doctor>> getDoctors() async {
    final response = await dio.get('/api/v1/doctors');
    final data = response.data['data'] as List? ?? response.data as List;
    return data.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DoctorReview>> getReviews(String doctorId) async {
    final response = await dio.get('/api/v1/doctors/$doctorId/reviews');
    final data = response.data['data'] as List? ?? response.data as List;
    return data.map((e) => DoctorReview.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DoctorAppointment>> getUpcomingAppointments() async {
    final response = await dio.get('/api/v1/appointments', queryParameters: {'status': 'upcoming'});
    final data = response.data['data'] as List? ?? response.data as List;
    return data.map((e) => DoctorAppointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DoctorAppointment>> getScheduledAppointments() async {
    // Both upcoming and scheduled can map to the upcoming API status
    final response = await dio.get('/api/v1/appointments', queryParameters: {'status': 'upcoming'});
    final data = response.data['data'] as List? ?? response.data as List;
    return data.map((e) => DoctorAppointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DoctorAppointment>> getHistoryAppointments() async {
    final response = await dio.get('/api/v1/appointments', queryParameters: {'status': 'past'});
    final data = response.data['data'] as List? ?? response.data as List;
    return data.map((e) => DoctorAppointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<DoctorAppointment> getAppointmentDetail(String appointmentId) async {
    // If there is no specific get detail endpoint for appointments, we return mock or fetch from list.
    // Assuming backend returns it in the list, we can just return the mock for now since it wasn't provided,
    // or fetch the list and filter.
    return _kCompletedAppointmentDetail;
  }

  @override
  Future<void> bookAppointment({
    required String doctorId,
    required String date,
    required String time,
    required String callType,
  }) async {
    await dio.post('/api/v1/appointments', data: {
      'doctorId': doctorId,
      'slotId': 'dummy-slot-id', // The UI needs to be updated to select real slots
      'type': callType.toUpperCase(),
      'reason': 'Routine checkup',
      'notes': 'Requested time: $date $time',
    });
  }

  @override
  Future<void> submitReview({
    required String doctorId,
    required double rating,
    required String body,
  }) async {
    await dio.post(
      '/api/v1/doctors/$doctorId/reviews',
      data: {
        'rating': rating,
        'review': body,
      },
    );
  }

  @override
  Future<ChatMessage> sendMessage({
    required String appointmentId,
    required String text,
  }) async {
    return ChatMessage(
      sender: ChatSender.user,
      authorName: 'You',
      avatarPath: 'assets/avatars/me.png',
      timeLabel: 'now',
      text: text,
    );
  }
}

// ─── Static seed data ────────────────────────────────────────────────────────


const _kDoctors = [
  Doctor(
    id: '1',
    name: 'Dr. Adewale Tunde',
    specialty: 'Obstetrician & Gynecologist',
    hospital: 'Mediterian Hospital',
    rating: 4.5,
    reviewCount: 412,
    patients: 1200,
    experience: '8 yr+',
    fee: '₦5,900',
    isOnline: true,
    about:
        'Dr. Tunde is a top specialist at Mediterian Hospital based in Lagos. He has achieved several awards and recognition in HCSS, NCEE...',
    workingHours: 'Mon - Sat  •  8:30AM - 9:00PM',
    imagePath: 'assets/doctors/adewale.png',
  ),
  Doctor(
    id: '2',
    name: 'Dr. Kim-Taeung Shawn',
    specialty: 'Obstetrician',
    hospital: 'Fediteriano Hospital',
    rating: 4.5,
    reviewCount: 332,
    patients: 1000,
    experience: '5 yr+',
    fee: '₦5,900',
    isOnline: true,
    about:
        'Doctor Kim is a top specialist at Fediteriano Hospital based in London. He has achieved several awards and recognition in HCSS, NCEE...',
    workingHours: 'Mon - Sat  •  8:30AM - 9:00PM',
    imagePath: 'assets/doctors/kim.png',
  ),
  Doctor(
    id: '3',
    name: 'Dr. Sharim Mohaammed',
    specialty: 'Gynecologist',
    hospital: 'South Haven Hospital',
    rating: 3.5,
    reviewCount: 198,
    patients: 870,
    experience: '6 yr+',
    fee: '₦5,900',
    isOnline: false,
    about:
        'Dr. Mohaammed is a specialist in gynecology at South Haven Hospital. Known for compassionate care and thorough consultations.',
    workingHours: 'Mon - Fri  •  9:00AM - 6:00PM',
    imagePath: 'assets/doctors/sharim.png',
  ),
  Doctor(
    id: '4',
    name: 'Dr. Kassandra Han',
    specialty: 'Obstetrician',
    hospital: 'Fediteriano Hospital',
    rating: 4.5,
    reviewCount: 147,
    patients: 640,
    experience: '4 yr+',
    fee: '₦5,900',
    isOnline: true,
    about:
        'Dr. Han is an experienced obstetrician at Fediteriano Hospital with a focus on high-risk pregnancies and maternal health.',
    workingHours: 'Mon - Sat  •  8:00AM - 8:00PM',
    imagePath: 'assets/doctors/kassandra.png',
  ),
  Doctor(
    id: '5',
    name: 'Dr. David Utong-Abion',
    specialty: 'Obstetrician',
    hospital: 'Saving Lives Hospital',
    rating: 5.0,
    reviewCount: 289,
    patients: 1100,
    experience: '10 yr+',
    fee: '₦5,900',
    isOnline: true,
    about:
        'Dr. David is one of the most experienced obstetricians at Saving Lives Hospital, known for exceptional patient outcomes.',
    workingHours: 'Mon - Sat  •  7:30AM - 7:00PM',
    imagePath: 'assets/doctors/david.png',
  ),
  Doctor(
    id: '6',
    name: 'Dr. Jayden Luis Von-Dam',
    specialty: 'Gynecologist',
    hospital: 'South Haven Hospital',
    rating: 3.5,
    reviewCount: 210,
    patients: 920,
    experience: '6 yr+',
    fee: '₦5,900',
    isOnline: false,
    about:
        'Dr. Von-Dam brings years of gynecological expertise to South Haven Hospital, with a focus on preventive care.',
    workingHours: 'Mon - Fri  •  9:00AM - 6:00PM',
    imagePath: 'assets/doctors/jayden.png',
  ),
];

const _kDoctorReviews = [
  DoctorReview(
    author: 'Anita Raine',
    avatarPath: 'assets/avatars/anita.png',
    rating: 3.5,
    body:
        'I had a wonderful session with Dr. Kim. He was really honest, gave me insightful ideas on how to care of mys...',
    date: '31 mins ago',
  ),
  DoctorReview(
    author: 'Gracie James',
    avatarPath: 'assets/avatars/gracie.png',
    rating: 4.5,
    body:
        'This was truly a great experience. He gave me time to find perspective in things that mattered, to be prepared to ta...',
    date: 'Aug 15',
  ),
  DoctorReview(
    author: 'Stacie Flein Grace',
    avatarPath: 'assets/avatars/stacie.png',
    rating: 3.5,
    body:
        'I had a wonderful session with Dr. Kim. He was really honest, gave me insightful ideas on how to care of mys...',
    date: 'Aug 18',
  ),
  DoctorReview(
    author: 'Johanna Layina Ohioana',
    avatarPath: 'assets/avatars/johanna.png',
    rating: 4.5,
    body:
        'This was truly a great experience. He gave me time to find perspective in things that mattered, to be prepared to ta...',
    date: 'Aug 15',
  ),
  DoctorReview(
    author: 'Allyiah Shaine',
    avatarPath: 'assets/avatars/allyiah.png',
    rating: 4.5,
    body:
        'This was truly a great experience. He gave me time to find perspective in things that mattered, to be prepared to ta...',
    date: 'Aug 15',
  ),
];

final _kUpcomingAppointments = [
  DoctorAppointment(
    id: 'a1',
    doctor: _kDoctors[0],
    date: 'Sep 29',
    time: '9:00PM',
    callType: 'Video',
    status: AppointmentStatus.scheduled,
  ),
];

final _kScheduledAppointments = [
  DoctorAppointment(
    id: 's1',
    doctor: _kDoctors[1],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Audio',
    status: AppointmentStatus.scheduled,
  ),
  DoctorAppointment(
    id: 's2',
    doctor: _kDoctors[2],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Video',
    status: AppointmentStatus.scheduled,
  ),
  DoctorAppointment(
    id: 's3',
    doctor: _kDoctors[3],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Message',
    status: AppointmentStatus.scheduled,
  ),
  DoctorAppointment(
    id: 's4',
    doctor: _kDoctors[4],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Message',
    status: AppointmentStatus.scheduled,
  ),
];

final _kHistoryAppointments = [
  DoctorAppointment(
    id: 'h1',
    doctor: _kDoctors[1],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Audio',
    status: AppointmentStatus.completed,
  ),
  DoctorAppointment(
    id: 'h2',
    doctor: _kDoctors[3],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Audio',
    status: AppointmentStatus.declined,
  ),
  DoctorAppointment(
    id: 'h3',
    doctor: _kDoctors[2],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Video',
    status: AppointmentStatus.completed,
  ),
  DoctorAppointment(
    id: 'h4',
    doctor: _kDoctors[4],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Video',
    status: AppointmentStatus.completed,
  ),
];

final _kCompletedAppointmentDetail = DoctorAppointment(
  id: 'h1',
  doctor: _kDoctors[1],
  date: '16th July, 2025',
  time: '8:30AM - 09:45 PM',
  callType: 'Audio',
  status: AppointmentStatus.completed,
  hoursSpent: '2 Hours',
  bookingFee: '₦5,000',
  chatWindowLabel: '48 Hours Left',
  messages: const [
    ChatMessage(
      sender: ChatSender.user,
      authorName: 'You',
      avatarPath: 'assets/avatars/me.png',
      timeLabel: '10 min ago',
      text:
          'Good question, we\'ll discuss the timeline today and decide on the first few milestone together. For now, we\'ll stick with the same tools unless anyone has suggestions. We can definitely improve our workflow if needed.',
    ),
    ChatMessage(
      sender: ChatSender.doctor,
      authorName: 'Patricia James',
      avatarPath: 'assets/avatars/patricia.png',
      timeLabel: '9 min ago',
      text: 'I sincerely agree with you, so what next steps should I take',
    ),
    ChatMessage(
      sender: ChatSender.user,
      authorName: 'You',
      avatarPath: 'assets/avatars/me.png',
      timeLabel: '5 min ago',
      attachmentName: 'Health Tips for Pregnant Women',
      attachmentSize: '2.4 MB',
    ),
    ChatMessage(
      sender: ChatSender.user,
      authorName: 'You',
      avatarPath: 'assets/avatars/me.png',
      timeLabel: '5 min ago',
      text:
          'I attached a document for you to go through, please read through it and it\'ll help you out',
    ),
    ChatMessage(
      sender: ChatSender.doctor,
      authorName: 'Patricia James',
      avatarPath: 'assets/avatars/patricia.png',
      timeLabel: '4 min ago',
      text: 'Thank you very much sir. This would really help me a lot.',
    ),
  ],
);