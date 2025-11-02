import 'package:chat_app/features/conversations/data/models/conversations_data.dart';
import 'package:chat_app/features/conversations/data/services/conversations_service.dart';

class ConversationsRepository {
  final ConversationsService _conversationsService;
  ConversationsRepository(this._conversationsService);

  Future<List<ConversationsData>> getChatrooms(String userId) async {
    try {
      final res = await _conversationsService.getChatrooms(userId);
      return res.map((convo) => ConversationsData.fromJson(convo)).toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
