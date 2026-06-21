enum AppointmentStatus { scheduled, completed, declined }

enum ChatSender { user, doctor }

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

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      hospital: json['hospital'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      patients: json['patients'] as int,
      experience: json['experience'] as String,
      fee: json['fee'] as String,
      isOnline: json['is_online'] as bool,
      about: json['about'] as String,
      workingHours: json['working_hours'] as String,
      imagePath: json['image_path'] as String,
      callTypes: json['call_types'] == null
          ? const ['Audio', 'Video']
          : List<String>.from(json['call_types'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'hospital': hospital,
      'rating': rating,
      'review_count': reviewCount,
      'patients': patients,
      'experience': experience,
      'fee': fee,
      'is_online': isOnline,
      'about': about,
      'working_hours': workingHours,
      'image_path': imagePath,
      'call_types': callTypes,
    };
  }
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

  factory DoctorReview.fromJson(Map<String, dynamic> json) {
    return DoctorReview(
      author: json['author'] as String,
      avatarPath: json['avatar_path'] as String,
      rating: (json['rating'] as num).toDouble(),
      body: json['body'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'avatar_path': avatarPath,
      'rating': rating,
      'body': body,
      'date': date,
    };
  }
}

class ChatMessage {
  final ChatSender sender;
  final String authorName;
  final String avatarPath;
  final String timeLabel;
  final String? text;
  final String? attachmentName;
  final String? attachmentSize;

  const ChatMessage({
    required this.sender,
    required this.authorName,
    required this.avatarPath,
    required this.timeLabel,
    this.text,
    this.attachmentName,
    this.attachmentSize,
  });

  bool get hasAttachment => attachmentName != null;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: ChatSender.values.byName(json['sender'] as String),
      authorName: json['author_name'] as String,
      avatarPath: json['avatar_path'] as String,
      timeLabel: json['time_label'] as String,
      text: json['text'] as String?,
      attachmentName: json['attachment_name'] as String?,
      attachmentSize: json['attachment_size'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender.name,
      'author_name': authorName,
      'avatar_path': avatarPath,
      'time_label': timeLabel,
      'text': text,
      'attachment_name': attachmentName,
      'attachment_size': attachmentSize,
    };
  }
}

class DoctorAppointment {
  final String id;
  final Doctor doctor;
  final String date;
  final String time;
  final String callType;
  final AppointmentStatus status;
  final String hoursSpent;
  final String bookingFee;
  final String chatWindowLabel;
  final List<ChatMessage> messages;

  const DoctorAppointment({
    required this.id,
    required this.doctor,
    required this.date,
    required this.time,
    required this.callType,
    required this.status,
    this.hoursSpent = '',
    this.bookingFee = '',
    this.chatWindowLabel = '',
    this.messages = const [],
  });

  DoctorAppointment copyWith({
    String? date,
    String? time,
    String? callType,
    AppointmentStatus? status,
    String? hoursSpent,
    String? bookingFee,
    String? chatWindowLabel,
    List<ChatMessage>? messages,
  }) {
    return DoctorAppointment(
      id: id,
      doctor: doctor,
      date: date ?? this.date,
      time: time ?? this.time,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      hoursSpent: hoursSpent ?? this.hoursSpent,
      bookingFee: bookingFee ?? this.bookingFee,
      chatWindowLabel: chatWindowLabel ?? this.chatWindowLabel,
      messages: messages ?? this.messages,
    );
  }

  factory DoctorAppointment.fromJson(Map<String, dynamic> json) {
    return DoctorAppointment(
      id: json['id'] as String,
      doctor: Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
      date: json['date'] as String,
      time: json['time'] as String,
      callType: json['call_type'] as String,
      status: AppointmentStatus.values.byName(json['status'] as String),
      hoursSpent: json['hours_spent'] as String? ?? '',
      bookingFee: json['booking_fee'] as String? ?? '',
      chatWindowLabel: json['chat_window_label'] as String? ?? '',
      messages: json['messages'] == null
          ? const []
          : (json['messages'] as List)
              .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor': doctor.toJson(),
      'date': date,
      'time': time,
      'call_type': callType,
      'status': status.name,
      'hours_spent': hoursSpent,
      'booking_fee': bookingFee,
      'chat_window_label': chatWindowLabel,
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }
}