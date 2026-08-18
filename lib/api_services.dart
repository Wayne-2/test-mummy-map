import 'package:dio/dio.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: 'https://mummymap-be-staging.up.railway.app/api/v1/',
    headers: {
      'Content-Type': 'application/json',
      
    },
  ),
);