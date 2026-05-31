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
      '/register',
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthModel.fromJson(res.data);
  }

  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    final res = await dio.post(
      '/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthModel.fromJson(res.data);
  }

  Future<AuthModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await dio.post(
      '/verify-otp',
      data: {
        'email': email,
        'otp': otp,
      },
    );

    return AuthModel.fromJson(res.data);
  }

  Future<void> refreshToken({
    required String refreshToken,
  }) async {
    await dio.post(
      '/refresh-token',
      data: {'refreshToken': refreshToken},
    );
  }

  Future<void> requestPasswordResetOtp({
    required String email,
  }) async {
    await dio.post(
      '/request-password-reset-otp',
      data: {'email': email},
    );
  }

  Future<void> verifyResetPasswordOtp({
    required String email,
    required String otp,
  }) async {
    await dio.post(
      '/verify-reset-password-otp',
      data: {
        'email': email,
        'otp': otp,
      },
    );
  }

  Future<void> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await dio.post(
      '/reset-password',
      data: {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<void> logoutCurrentDevice() async {
    await dio.post('/logout');
  }

  Future<void> logoutAllDevices() async {
    await dio.post('/logout-all');
  }
}