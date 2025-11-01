import 'package:chat_app/features/conversations/bloc/conversation_members_cubit.dart';
import 'package:chat_app/features/auth/bloc/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MembersDrawer extends StatelessWidget {
  const MembersDrawer({super.key, required this.roomCode});
  final String roomCode;

  @override
  Widget build(BuildContext context) {
    final username = context.read<AuthCubit>().getCurrentUser()?.username;

    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: BlocBuilder<ConversationMembersCubit, ConversationMembersState>(
        builder: (context, state) {
          if (state is ConversationMembersLoaded) {
            final members = state.members;
            return ListView.builder(
              itemCount: members.length + 1, // +1 for the header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 8, 8),
                    child: Row(
                      children: [
                        SizedBox(width: 8, child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7.0),
                          child: Text(
                            "Members (${members.length})",
                            style: TextStyle(fontSize: 17, fontStyle: FontStyle.italic),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  );
                }

                final memberIndex = index - 1;
                final member = members[memberIndex];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(25),
                    child: member.profilePic != null
                        ? ClipOval(child: Image.network(member.profilePic!, fit: BoxFit.cover))
                        : Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(
                    member.username,
                    style: TextStyle(
                      fontWeight: member.username == username ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: member.username == username
                      ? Text("You", style: TextStyle(fontStyle: FontStyle.italic))
                      : null,
                  onTap: () {
                    // You can add functionality here, like viewing user profile
                  },
                );
              },
            );
          } else if (state is ConversationMembersLoading) {
            return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 8, 8),
                  child: Row(
                    children: [
                      SizedBox(width: 8, child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0),
                        child: Text(
                          "Loading Members...",
                          style: TextStyle(fontSize: 17, fontStyle: FontStyle.italic),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                );
              },
            );
          } else if (state is ConversationMembersError) {
            return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 8, 8),
                  child: Row(
                    children: [
                      SizedBox(width: 8, child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0),
                        child: Text(
                          "Error loading members",
                          style: TextStyle(fontSize: 17, fontStyle: FontStyle.italic),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                );
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
