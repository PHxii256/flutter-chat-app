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
      final res = await _dio.get("/chatrooms", queryParameters: {"userId": userId});

      List<ConversationsData> chats = [];
      for (var data in res.data) {
        chats.add(ConversationsData.fromJson(data));
      }
      return chats;
    } on DioException catch (e) {
      print('Error in getting conversations: ${e.message}');
      throw Exception(e);
    }
  }
}

@riverpod
ConversationsService conversationsService(Ref ref) {
  return ConversationsService(ref.watch(dioProvider));
}
