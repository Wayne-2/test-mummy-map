import 'package:mummymap/data/datasources/auth_remote_datasource.dart';
import 'package:mummymap/data/models/auth_model.dart';

class AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepository(this.datasource);

  Future<AuthModel> register({
    required String email,
    required String password,
  }) {
    return datasource.register(
      email: email,
      password: password,
    );
  }

  Future<AuthModel> login({
    required String email,
    required String password,
  }) {
    return datasource.login(
      email: email,
      password: password,
    );
  }

  Future<AuthModel> verifyOtp({
    required String email,
    required String otp,
  }) {
    return datasource.verifyOtp(
      email: email,
      otp: otp,
    );
  }

  Future<void> refreshToken({
    required String refreshToken,
  }) {
    return datasource.refreshToken(
      refreshToken: refreshToken,
    );
  }

  Future<void> requestPasswordResetOtp({
    required String email,
  }) {
    return datasource.requestPasswordResetOtp(email: email);
  }

  Future<void> verifyResetPasswordOtp({
    required String email,
    required String otp,
  }) {
    return datasource.verifyResetPasswordOtp(
      email: email,
      otp: otp,
    );
  }

  Future<void> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return datasource.resetPassword(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  Future<void> logoutCurrentDevice() {
    return datasource.logoutCurrentDevice();
  }

  Future<void> logoutAllDevices() {
    return datasource.logoutAllDevices();
  }
}