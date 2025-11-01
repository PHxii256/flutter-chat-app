import 'package:chat_app/features/conversations/models/conversations_data.dart';
import 'package:chat_app/features/conversations/services/conversations_service.dart';

class ConversationsRepository {
  final ConversationsService _conversationsService;
  ConversationsRepository(this._conversationsService);

  Future<List<ConversationsData>> getChatrooms(String userId) async {
    try {
      return _conversationsService.getChatrooms(userId);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
