import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:mummymap/data/datasources/auth_remote_datasource.dart';
import 'package:mummymap/data/models/auth_model.dart';
import 'package:mummymap/domain/repositories/auth_repository.dart';
// import 'package:flutter/material.dart';
import 'package:mummymap/main.dart';
// import 'package:mummymap/presentation/pages/auth/signin.dart';

const String kBaseUrl = 'https://mummymap-be-staging.up.railway.app';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

const _baseHeaders = {
  'Content-Type': 'application/json',

};

const _noRefreshPaths = [
  '/api/v1/auth/refresh',
  '/api/v1/auth/login',
  '/api/v1/auth/register',
  '/api/v1/auth/user/verify',
];

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: Map<String, String>.from(_baseHeaders),
    ),
  );

  final storage = ref.watch(secureStorageProvider);

  final refreshClient = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: Map<String, String>.from(_baseHeaders),
    ),
  );

  if (kDebugMode) {
    refreshClient.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<String?>? pendingRefresh;

  Future<String?> refreshAccessToken() async {
    final refreshToken =
        await storage.read(key: AuthStorageKeys.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final res = await refreshClient.post(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) return null;
      final model = AuthModel.fromJson(data);
      if (!model.hasTokens) return null;
      await storage.write(
          key: AuthStorageKeys.accessToken, value: model.accessToken);
      await storage.write(
          key: AuthStorageKeys.refreshToken, value: model.refreshToken);
      return model.accessToken;
    } catch (_) {
      return null;
    }
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!options.headers.containsKey('Authorization')) {
          final accessToken =
              await storage.read(key: AuthStorageKeys.accessToken);
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final response = error.response;
        final requestOptions = error.requestOptions;

        if (kDebugMode) {
          debugPrint(
              'AUTH_DEBUG onError fired: status=${response?.statusCode} path=${requestOptions.path}');
        }

        final isAuthError = response?.statusCode == 401 ||
            response?.statusCode == 403 ||
            (response?.data is Map &&
                response?.data['message']?.toString().toLowerCase().contains('session has expired') == true);
        final isRefreshable =
            !_noRefreshPaths.any((p) => requestOptions.path.contains(p));
        final alreadyRetried = requestOptions.extra['retried'] == true;

        if (!isAuthError || !isRefreshable || alreadyRetried) {
          return handler.next(error);
        }

        if (kDebugMode) {
          debugPrint('AUTH_DEBUG attempting token refresh now...');
        }
        
        final currentToken = await storage.read(key: AuthStorageKeys.accessToken);
        final requestToken = requestOptions.headers['Authorization']?.replaceAll('Bearer ', '');
        
        String? newToken;
        
        if (currentToken != null && currentToken != requestToken && currentToken.isNotEmpty) {
          newToken = currentToken;
        } else {
          pendingRefresh ??= refreshAccessToken();
          newToken = await pendingRefresh;
          pendingRefresh = null;
        }
        
        if (kDebugMode) {
          debugPrint(
              'AUTH_DEBUG refresh result: ${newToken == null ? "FAILED (null)" : "SUCCESS"}');
        }

        if (newToken == null || newToken.isEmpty) {
          await storage.delete(key: AuthStorageKeys.accessToken);
          await storage.delete(key: AuthStorageKeys.refreshToken);
          await storage.write(
              key: AuthStorageKeys.isLoggedIn, value: 'false');
              
          if (navigatorKey.currentContext != null) {
            GoRouter.of(navigatorKey.currentContext!).go('/signin');
          }
              
          return handler.next(error);
        }

        try {
          final retried = await dio.fetch(
            requestOptions
              ..headers['Authorization'] = 'Bearer $newToken'
              ..extra['retried'] = true,
          );
          return handler.resolve(retried);
        } catch (e) {
          if (e is DioException) return handler.next(e);
          return handler.next(error);
        }
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  return dio;
});

final authDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authDatasourceProvider),
    ref.watch(secureStorageProvider),
  );
});