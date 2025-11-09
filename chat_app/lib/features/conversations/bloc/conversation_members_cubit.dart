import 'package:chat_app/features/chat/data/models/user_model.dart';
import 'package:chat_app/features/conversations/bloc/conversation_members_state.dart';
import 'package:bloc/bloc.dart';

class ConversationMembersCubit extends Cubit<ConversationMembersState> {
  final String roomCode;

  ConversationMembersCubit({required this.roomCode, List<User>? initialMembers})
    : super(ConversationMembersLoaded(members: initialMembers ?? []));

  User? getCurrentUser(String username) {
    final currentState = state;
    if (currentState is! ConversationMembersLoaded) return null;

    try {
      return currentState.members.firstWhere((member) => member.username == username);
    } catch (e) {
      return null;
    }
  }

  bool isMember(String username) {
    final currentState = state;
    if (currentState is! ConversationMembersLoaded) return false;
    return currentState.members.any((member) => member.username == username);
  }

  /// Get member count
  int get memberCount {
    final currentState = state;
    if (currentState is! ConversationMembersLoaded) return 0;
    return currentState.members.length;
  }
}
