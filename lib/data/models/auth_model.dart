class AuthModel {
  final String accessToken;
  final String refreshToken;
  final String? resetToken;
  final String? email;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    this.resetToken,
    this.email,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return AuthModel(
      accessToken:
          (root['accessToken'] ?? root['access_token'] ?? '') as String,
      refreshToken:
          (root['refreshToken'] ?? root['refresh_token'] ?? '') as String,
      resetToken: (root['resetToken'] ?? root['reset_token']) as String?,
      email: (root['user'] as Map?)?['email'] as String?,
    );
  }

  bool get hasTokens => accessToken.isNotEmpty && refreshToken.isNotEmpty;
  bool get hasResetToken => (resetToken ?? '').isNotEmpty;
}