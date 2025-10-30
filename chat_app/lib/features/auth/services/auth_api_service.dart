import 'package:chat_app/core/network/dio.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_models.dart';

part 'auth_api_service.g.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {'email': email, 'password': password});
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<AuthResponse> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/register', data: userData);
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Registration failed: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<void> logout(String refreshToken, [String? accessToken]) async {
    try {
      final options = accessToken != null
          ? Options(headers: {'Authorization': 'Bearer $accessToken'})
          : Options();

      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken}, options: options);
    } on DioException catch (e) {
      // Handle 401 specifically - user already logged out on server
      if (e.response?.statusCode == 401) {
        print('User already logged out on server (401)');
        return; // Treat as success
      }
      // Log other errors but don't throw - logout should always succeed locally
      print('Logout API call failed: ${e.message}');
    }
  }

  Future<bool> validateToken(String accessToken) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $accessToken'});
      await _dio.get('/auth/validate-token', options: options);
      return true;
    } on DioException catch (e) {
      print('Token validation failed: ${e.message}');
      return false;
    }
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post('/auth/refresh-token', data: {'refreshToken': refreshToken});
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Token refresh failed: ${e.response?.data['message'] ?? e.message}');
    }
  }
}

@riverpod
AuthApiService authApiService(Ref ref) {
  return AuthApiService(ref.watch(dioProvider));
}
