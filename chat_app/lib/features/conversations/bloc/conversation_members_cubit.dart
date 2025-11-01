import 'package:chat_app/features/chat/models/user_model.dart';
import 'package:chat_app/features/conversations/bloc/conversations_cubit.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';

// States
sealed class ConversationMembersState {
  const ConversationMembersState();
}

class ConversationMembersInitial extends ConversationMembersState {
  const ConversationMembersInitial();
}

class ConversationMembersLoading extends ConversationMembersState {
  const ConversationMembersLoading();
}

class ConversationMembersLoaded extends ConversationMembersState {
  final List<User> members;
  const ConversationMembersLoaded({required this.members});
}

class ConversationMembersError extends ConversationMembersState {
  final String message;
  const ConversationMembersError({required this.message});
}

// Cubit
class ConversationMembersCubit extends Cubit<ConversationMembersState> {
  final String roomCode;
  final ConversationsCubit _conversationsCubit;

  ConversationMembersCubit({required this.roomCode, required ConversationsCubit conversationsCubit})
    : _conversationsCubit = conversationsCubit,
      super(const ConversationMembersInitial());

  Future<void> loadMembers() async {
    emit(const ConversationMembersLoading());

    try {
      final conversationsState = _conversationsCubit.state;
      if (conversationsState is ConversationsLoaded) {
        final currentConversation = conversationsState.conversations.firstWhereOrNull(
          (convo) => convo.roomCode == roomCode,
        );

        emit(ConversationMembersLoaded(members: currentConversation?.memberList ?? []));
      } else {
        emit(const ConversationMembersLoaded(members: []));
      }
    } catch (e) {
      emit(ConversationMembersError(message: e.toString()));
    }
  }

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
