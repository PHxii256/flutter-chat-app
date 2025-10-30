import 'package:chat_app/features/chat/models/user_model.dart';
import 'package:chat_app/features/conversations/providers/conversations_notifier.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation_members_notifier.g.dart';

@riverpod
class ConversationMembers extends _$ConversationMembers {
  @override
  Future<List<User>> build(String roomCode) async {
    final conversations = await ref.watch(conversationsProvider.future);
    final currentConversation = conversations.firstWhereOrNull(
      (convo) => convo.roomCode == roomCode,
    );

    return currentConversation?.memberList ?? [];
  }

  User? getCurrentUser(String username) {
    if (!state.hasValue) return null;
    try {
      return state.value!.firstWhere((member) => member.username == username);
    } catch (e) {
      return null;
    }
  }

  bool isMember(String username) {
    if (!state.hasValue) return false;
    return state.value!.any((member) => member.username == username);
  }

  /// Get member count
  int get memberCount {
    if (!state.hasValue) return 0;
    return state.value!.length;
  }
}
