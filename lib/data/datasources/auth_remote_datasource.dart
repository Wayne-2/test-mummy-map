import 'package:dio/dio.dart';
import 'package:mummymap/data/models/auth_model.dart';

class AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasource(this.dio);

  Future<AuthModel> register({
    required String email,
    required String password,
  }) async {
    final res = await dio.post(
      '/api/v1/auth/register',
      data: {'email': email, 'password': password},
    );
    return AuthModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    final res = await dio.post(
      '/api/v1/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthModel> verifyOtp({
    required String otp,
  }) async {
    final cleaned = otp.trim();
    if (cleaned.length != 6 || int.tryParse(cleaned) == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/user/verify'),
        error: 'Please enter the 6-digit code from your email.',
        type: DioExceptionType.unknown,
      );
    }
    final res = await dio.post(
      '/api/v1/auth/user/verify',
      data: {'otpToken': cleaned},
    );
    return AuthModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> resendOtp({required String email}) async {
    await dio.post(
      '/api/v1/auth/resend-otp',
      data: {'email': email},
    );
  }

  Future<AuthModel> refreshToken({
    required String refreshToken,
  }) async {
    final res = await dio.post(
      '/api/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return AuthModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> requestPasswordResetOtp({
    required String email,
  }) async {
    await dio.post(
      '/api/v1/auth/password/forgot',
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String newPassword,
    required String resetToken,
  }) async {
    await dio.post(
      '/api/v1/users/password/reset',
      data: {'newPassword': newPassword},
      options: Options(
        headers: {'Authorization': 'Bearer $resetToken'},
      ),
    );
  }

  Future<void> logoutCurrentDevice() async {
    await dio.post('/api/v1/auth/logout');
  }

  Future<void> logoutAllDevices() async {
    await dio.post('/api/v1/auth/logout/all');
  }

  Future<void> deleteAccount() async {
    await dio.delete('/api/v1/users/me');
  }
}