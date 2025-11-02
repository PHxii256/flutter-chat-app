import 'package:dio/dio.dart';

class ConversationsService {
  final Dio _dio;
  ConversationsService(this._dio);

  Future<List<dynamic>> getChatrooms(String userId) async {
    try {
      final res = await _dio.get("/conversations");
      return res.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        print(
          'Authentication error in getting conversations (${e.response?.statusCode}): ${e.message}',
        );
        // The interceptor should have already tried to refresh the token
        // If we still get 401/403, it means the refresh failed or user needs to login again
        throw Exception('Authentication failed. Please login again.');
      } else {
        print('Error in getting conversations: ${e.message}');
        throw Exception(
          'Failed to load conversations: ${e.response?.data['message'] ?? e.message}',
        );
      }
    } catch (e) {
      print("Non-dio exception in getting conversations: ${e.toString()}");
      rethrow;
    }
  }
}
