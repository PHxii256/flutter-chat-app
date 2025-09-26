// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/models/message_data.dart';
import 'package:flutter/material.dart';

class ReactionsViewer extends StatefulWidget {
  final MessageData message;
  const ReactionsViewer({super.key, required this.message});

  @override
  State<ReactionsViewer> createState() => _ReactionsViewerState();
}

class _ReactionsViewerState extends State<ReactionsViewer> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, int> getUniqueReactions() {
    Map<String, int> unqiueReactions = {};

    //load data in map
    for (var react in widget.message.reactions) {
      if (unqiueReactions[react.emoji] == null) {
        unqiueReactions[react.emoji] = 1;
      } else {
        unqiueReactions[react.emoji] = unqiueReactions[react.emoji]! + 1;
      }
    }

    return unqiueReactions;
  }

  List<String> getEmojiUsernames(String emoji) {
    List<String> usrs = [];
    for (var react in widget.message.reactions) {
      if (react.emoji == emoji) {
        usrs.add(react.senderUsername);
      }
    }

    return usrs;
  }

  @override
  void initState() {
    super.initState();
    final uniqueEmojis = getUniqueReactions().keys.toList();
    _tabController = TabController(length: uniqueEmojis.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final uniqueReactions = getUniqueReactions();
    final uniqueEmojis = uniqueReactions.keys.toList();

    if (uniqueEmojis.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(height: 300, child: Center(child: Text(t.noReactionsYet))),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 300,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: uniqueEmojis.map((emoji) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(
                        uniqueReactions[emoji].toString(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                child: TabBarView(
                  controller: _tabController,
                  children: uniqueEmojis.map((emoji) {
                    final usernames = getEmojiUsernames(emoji);
                    return ListView.builder(
                      itemCount: usernames.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            usernames[index],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
