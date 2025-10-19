import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/view_models/conversations_notifier.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation_members_notifier.g.dart';

@riverpod
class ConversationMembers extends _$ConversationMembers {
  @override
  Future<List<User>> build(String roomCode) async {
    // Watch the conversations provider
    final conversations = await ref.watch(conversationsProvider.future);

    // Find the current conversation
    final currentConversation = conversations.firstWhereOrNull(
      (convo) => convo.roomCode == roomCode,
    );

    // Return the member list or empty list if conversation not found
    return currentConversation?.memberList ?? [];
  }

  /// Get the current user from the member list
  User? getCurrentUser(String username) {
    if (!state.hasValue) return null;

    try {
      return state.value!.firstWhere((member) => member.username == username);
    } catch (e) {
      return null;
    }
  }

  /// Check if a user is a member of this conversation
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
