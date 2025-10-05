import 'package:chat_app/models/conversations_data.dart';
import 'package:chat_app/services/conversations_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversations_repo.g.dart';

class ConversationsRepository {
  final ConversationsService _conversationsService;
  ConversationsRepository(this._conversationsService);

  Future<List<ConversationsData>> getChatrooms(String userId) async {
    try {
      return _conversationsService.getChatrooms(userId);
    } catch (e) {
      print("Eeeeeeeeeeeeeee");
      rethrow;
    }
  }
}

@riverpod
ConversationsRepository conversationsRepository(Ref ref) {
  return ConversationsRepository(ref.watch(conversationsServiceProvider));
}
