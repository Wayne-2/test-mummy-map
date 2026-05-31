import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/auth_remote_datasource.dart';
import 'package:mummymap/domain/repositories/auth_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://antarctic-cost-ambulance.ngrok-free.dev/2222/api',
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
});

final authDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    ref.read(dioProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(authDatasourceProvider),
  );
});