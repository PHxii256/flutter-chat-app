import 'package:chat_app/features/conversations/models/conversations_data.dart';
import 'package:chat_app/features/conversations/models/message_preview_data.dart';
import 'package:chat_app/features/chat/models/user_model.dart';
import 'package:chat_app/features/auth/repositories/auth_repository.dart';
import 'package:chat_app/features/conversations/repositories/conversations_repo.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'conversations_notifier.g.dart';

@Riverpod(keepAlive: false)
class ConversationsNotifier extends _$ConversationsNotifier {
  @override
  Future<List<ConversationsData>> build() async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user != null) {
      final list = await ref.read(conversationsRepositoryProvider).getChatrooms(user.id);
      print(list);
      return list;
    }
    print("user is null");
    return [];
  }

  Future<User?> getCurrentUser() async {
    return await ref.read(authRepositoryProvider).getCurrentUser();
  }

  Future<List<User>> getConversationMembers(String roomCode) async {
    if (!state.hasValue) return [];
    final convo = state.asData!.value.firstWhereOrNull((c) => c.roomCode == roomCode);
    if (convo == null) return Future.error(Exception("couldn't get members"));
    return convo.memberList;
  }

  /// Refresh the conversations list by invalidating and rebuilding
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<String> getFormatedLastMessage(MessagePreviewData? lastMessage) async {
    if (lastMessage != null) {
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        if (currentUser.id == lastMessage.senderId) return "you sent: ${lastMessage.content}";
      }
      return "${lastMessage.username}: ${lastMessage.content}";
    }
    return "No Messages Yet, Say Hi!";
  }
}
