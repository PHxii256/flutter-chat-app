// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(roomCode) => "Chat Room #${roomCode}";

  static String m1(error) => "Error: ${error}";

  static String m2(username) => "Reply to ${username}";

  static String m3(message) => "Replying to ${message}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "chatRoomTitle": m0,
    "deleteMessage": MessageLookupByLibrary.simpleMessage("Delete Message"),
    "editMessage": MessageLookupByLibrary.simpleMessage("Edit Message"),
    "editingMessage": MessageLookupByLibrary.simpleMessage("Editing Message"),
    "enterChatRoom": MessageLookupByLibrary.simpleMessage("Enter Chat Room"),
    "enterMessage": MessageLookupByLibrary.simpleMessage("Enter message"),
    "errorMessage": m1,
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "noReactionsYet": MessageLookupByLibrary.simpleMessage("No reactions yet"),
    "noRecents": MessageLookupByLibrary.simpleMessage("No Recents"),
    "reactToMessage": MessageLookupByLibrary.simpleMessage("React to Message"),
    "replyTo": m2,
    "replyToMessage": MessageLookupByLibrary.simpleMessage("Reply to Message"),
    "replyingTo": m3,
    "roomCode": MessageLookupByLibrary.simpleMessage("Room Code"),
    "showReactions": MessageLookupByLibrary.simpleMessage("Show Reactions"),
    "startChatting": MessageLookupByLibrary.simpleMessage("Start Chatting"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
  };
}
