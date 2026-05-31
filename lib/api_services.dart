import 'package:dio/dio.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: 'https://antarctic-cost-ambulance.ngrok-free.dev/2222/api',
    headers: {
      'Content-Type': 'application/json',
    },
  ),
);