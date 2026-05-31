class AuthModel {
  final String accessToken;
  final String refreshToken;
  final String? email;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    this.email,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      email: json['user']?['email'],
    );
  }
}