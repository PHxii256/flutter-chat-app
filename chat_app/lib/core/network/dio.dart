import 'package:chat_app/core/network/auth_interceptor.dart';
import 'package:chat_app/core/config/server_url.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Dio getDioInstance() {
  final dio = Dio(
    BaseOptions(
      baseUrl: getServertUrl(),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
    ),
  );

  dio.options.headers['Accept'] = 'application/json';
  dio.options.headers['Content-Type'] = 'application/json';

  // Add authentication interceptor
  dio.interceptors.add(AuthInterceptor(const FlutterSecureStorage()));

  return dio;
}

extension ResponseExtension on Response {
  bool get ok {
    return switch (statusCode) {
      200 || // OK
      201 || // Created
      202 || // Accepted
      203 || // Non-Authoritative Information
      204 || // No Content
      205 || // Reset Content
      206 // Partial Content
      => true,
      _ => false,
    };
  }
}
