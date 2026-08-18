import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mummymap/data/datasources/auth_remote_datasource.dart';
import 'package:mummymap/data/models/auth_model.dart';

class AuthStorageKeys {
  AuthStorageKeys._();
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const isLoggedIn = 'is_logged_in';
}

class AuthRepository {
  final AuthRemoteDatasource datasource;
  final FlutterSecureStorage storage;

  AuthRepository(this.datasource, this.storage);

  Future<void> _saveSession(AuthModel model) async {
    if (!model.hasTokens) return;
    await storage.write(
        key: AuthStorageKeys.accessToken, value: model.accessToken);
    await storage.write(
        key: AuthStorageKeys.refreshToken, value: model.refreshToken);
    await storage.write(key: AuthStorageKeys.isLoggedIn, value: 'true');
  }

  Future<void> _clearSession() async {
    await storage.delete(key: AuthStorageKeys.accessToken);
    await storage.delete(key: AuthStorageKeys.refreshToken);
    await storage.write(key: AuthStorageKeys.isLoggedIn, value: 'false');
  }

  Future<bool> get isLoggedIn async =>
      (await storage.read(key: AuthStorageKeys.isLoggedIn)) == 'true';

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final model = await datasource.register(email: email, password: password);
    if (model.hasTokens) {
      await _saveSession(model);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final model = await datasource.login(email: email, password: password);
    if (model.hasTokens) {
      await _saveSession(model);
    }
  }

  Future<AuthModel> verifyOtp({
    required String otp,
  }) async {
    final model = await datasource.verifyOtp(otp: otp);
    await _saveSession(model);
    return model;
  }

  Future<AuthModel> refreshToken() async {
    final stored = await storage.read(key: AuthStorageKeys.refreshToken);
    if (stored == null || stored.isEmpty) {
      throw StateError('No refresh token stored — user must log in again.');
    }
    final model = await datasource.refreshToken(refreshToken: stored);
    await _saveSession(model);
    return model;
  }

  Future<void> requestPasswordResetOtp({required String email}) {
    return datasource.requestPasswordResetOtp(email: email);
  }

  Future<String> verifyResetOtp({required String otp}) async {
    final model = await datasource.verifyOtp(otp: otp);
    if (!model.hasResetToken) {
      throw StateError('No resetToken returned from verify.');
    }
    return model.resetToken!;
  }

  Future<void> resetPassword({
    required String newPassword,
    required String resetToken,
  }) {
    return datasource.resetPassword(
      newPassword: newPassword,
      resetToken: resetToken,
    );
  }

  Future<void> logoutCurrentDevice() async {
    try {
      await datasource.logoutCurrentDevice();
    } finally {
      await _clearSession();
    }
  }

  Future<void> logoutAllDevices() async {
    try {
      await datasource.logoutAllDevices();
    } finally {
      await _clearSession();
    }
  }

  Future<void> deleteAccount() async {
    try {
      await datasource.deleteAccount();
    } finally {
      await _clearSession();
    }
  }
}