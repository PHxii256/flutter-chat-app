import 'package:chat_app/models/conversations_data.dart';
import 'package:chat_app/services/dio.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversations_service.g.dart';

class ConversationsService {
  final Dio _dio;
  ConversationsService(this._dio);

  Future<List<ConversationsData>> getChatrooms(String userId) async {
    try {
      final res = await _dio.get("/conversations");

      List<ConversationsData> chats = [];
      for (var data in res.data) {
        chats.add(ConversationsData.fromJson(data));
      }
      return chats;
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

@riverpod
ConversationsService conversationsService(Ref ref) {
  return ConversationsService(ref.watch(dioProvider));
}
