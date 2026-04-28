class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final int reviewCount;
  final int patients;
  final String experience;
  final String fee;
  final bool isOnline;
  final String about;
  final String workingHours;
  final String imagePath;
  final List<String> callTypes;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.reviewCount,
    required this.patients,
    required this.experience,
    required this.fee,
    required this.isOnline,
    required this.about,
    required this.workingHours,
    required this.imagePath,
    this.callTypes = const ['Audio', 'Video'],
  });
}

class DoctorReview {
  final String author;
  final String avatarPath;
  final double rating;
  final String body;
  final String date;

  const DoctorReview({
    required this.author,
    required this.avatarPath,
    required this.rating,
    required this.body,
    required this.date,
  });
}

class DoctorAppointment {
  final String id;
  final Doctor doctor;
  final String date;
  final String time;
  final String callType;
  final AppointmentStatus status;

  const DoctorAppointment({
    required this.id,
    required this.doctor,
    required this.date,
    required this.time,
    required this.callType,
    required this.status,
  });
}

enum AppointmentStatus { scheduled, completed, declined }

const kDoctors = [
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
    hospital: 'Mediterian Hospital',
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
    name: 'Dr. Sharim Mohaammed',
    specialty: 'Gynecologist',
    hospital: 'South Haven Hospital',
    rating: 3.5,
    reviewCount: 210,
    patients: 920,
    experience: '6 yr+',
    fee: '₦5,900',
    isOnline: false,
    about:
        'Dr. Mohaammed brings years of gynecological expertise to South Haven Hospital, with a focus on preventive care.',
    workingHours: 'Mon - Fri  •  9:00AM - 6:00PM',
    imagePath: 'assets/doctors/sharim.png',
  ),
];

const kDoctorReviews = [
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
];

final kUpcomingAppointments = [
  DoctorAppointment(
    id: 'a1',
    doctor: kDoctors[0],
    date: 'Sep 29',
    time: '9:00PM',
    callType: 'Video',
    status: AppointmentStatus.scheduled,
  ),
];

final kScheduledAppointments = [
  DoctorAppointment(
    id: 's1',
    doctor: kDoctors[1],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Audio',
    status: AppointmentStatus.scheduled,
  ),
  DoctorAppointment(
    id: 's2',
    doctor: kDoctors[2],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Video',
    status: AppointmentStatus.scheduled,
  ),
  DoctorAppointment(
    id: 's3',
    doctor: kDoctors[3],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Audio',
    status: AppointmentStatus.scheduled,
  ),
  DoctorAppointment(
    id: 's4',
    doctor: kDoctors[4],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Message',
    status: AppointmentStatus.scheduled,
  ),
];

final kHistoryAppointments = [
  DoctorAppointment(
    id: 'h1',
    doctor: kDoctors[1],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Audio',
    status: AppointmentStatus.completed,
  ),
  DoctorAppointment(
    id: 'h2',
    doctor: kDoctors[3],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Audio',
    status: AppointmentStatus.declined,
  ),
  DoctorAppointment(
    id: 'h3',
    doctor: kDoctors[2],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Video',
    status: AppointmentStatus.completed,
  ),
  DoctorAppointment(
    id: 'h4',
    doctor: kDoctors[4],
    date: '16th July, 2025',
    time: '9:00AM',
    callType: 'Video',
    status: AppointmentStatus.completed,
  ),
];