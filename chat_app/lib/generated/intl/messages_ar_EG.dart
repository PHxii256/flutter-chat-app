// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar_EG locale. All the
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
  String get localeName => 'ar_EG';

  static String m0(roomCode) => "غرفة الشات #${roomCode}";

  static String m1(error) => "خطأ: ${error}";

  static String m2(username) => "الرد على ${username}";

  static String m3(message) => "رداً على ${message}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "chatRoomTitle": m0,
    "deleteMessage": MessageLookupByLibrary.simpleMessage("حذف الرسالة"),
    "editMessage": MessageLookupByLibrary.simpleMessage("تعديل الرسالة"),
    "editingMessage": MessageLookupByLibrary.simpleMessage("تعديل الرسالة"),
    "enterChatRoom": MessageLookupByLibrary.simpleMessage("أدخل غرفة الشات"),
    "enterMessage": MessageLookupByLibrary.simpleMessage("اكتب رسالة"),
    "errorMessage": m1,
    "noReactionsYet": MessageLookupByLibrary.simpleMessage(
      "لا توجد تفاعلات بعد",
    ),
    "noRecents": MessageLookupByLibrary.simpleMessage("لا توجد حديثة"),
    "reactToMessage": MessageLookupByLibrary.simpleMessage("تفاعل مع الرسالة"),
    "replyTo": m2,
    "replyToMessage": MessageLookupByLibrary.simpleMessage("الرد على الرسالة"),
    "replyingTo": m3,
    "roomCode": MessageLookupByLibrary.simpleMessage("رمز الغرفة"),
    "showReactions": MessageLookupByLibrary.simpleMessage("إظهار التفاعلات"),
    "startChatting": MessageLookupByLibrary.simpleMessage("ابدأ الدردشة"),
    "username": MessageLookupByLibrary.simpleMessage("اسم المستخدم"),
  };
}
