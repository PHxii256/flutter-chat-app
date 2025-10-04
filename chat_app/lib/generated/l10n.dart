// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Enter Chat Room`
  String get enterChatRoom {
    return Intl.message(
      'Enter Chat Room',
      name: 'enterChatRoom',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Room Code`
  String get roomCode {
    return Intl.message('Room Code', name: 'roomCode', desc: '', args: []);
  }

  /// `Start Chatting`
  String get startChatting {
    return Intl.message(
      'Start Chatting',
      name: 'startChatting',
      desc: '',
      args: [],
    );
  }

  /// `Chat Room #{roomCode}`
  String chatRoomTitle(String roomCode) {
    return Intl.message(
      'Chat Room #$roomCode',
      name: 'chatRoomTitle',
      desc: '',
      args: [roomCode],
    );
  }

  /// `Enter message`
  String get enterMessage {
    return Intl.message(
      'Enter message',
      name: 'enterMessage',
      desc: '',
      args: [],
    );
  }

  /// `React to Message`
  String get reactToMessage {
    return Intl.message(
      'React to Message',
      name: 'reactToMessage',
      desc: '',
      args: [],
    );
  }

  /// `Show Reactions`
  String get showReactions {
    return Intl.message(
      'Show Reactions',
      name: 'showReactions',
      desc: '',
      args: [],
    );
  }

  /// `Reply to Message`
  String get replyToMessage {
    return Intl.message(
      'Reply to Message',
      name: 'replyToMessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit Message`
  String get editMessage {
    return Intl.message(
      'Edit Message',
      name: 'editMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete Message`
  String get deleteMessage {
    return Intl.message(
      'Delete Message',
      name: 'deleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `No reactions yet`
  String get noReactionsYet {
    return Intl.message(
      'No reactions yet',
      name: 'noReactionsYet',
      desc: '',
      args: [],
    );
  }

  /// `No Recents`
  String get noRecents {
    return Intl.message('No Recents', name: 'noRecents', desc: '', args: []);
  }

  /// `Error: {error}`
  String errorMessage(String error) {
    return Intl.message(
      'Error: $error',
      name: 'errorMessage',
      desc: '',
      args: [error],
    );
  }

  /// `Reply to {username}`
  String replyTo(String username) {
    return Intl.message(
      'Reply to $username',
      name: 'replyTo',
      desc: '',
      args: [username],
    );
  }

  /// `Replying to {message}`
  String replyingTo(String message) {
    return Intl.message(
      'Replying to $message',
      name: 'replyingTo',
      desc: '',
      args: [message],
    );
  }

  /// `Editing Message`
  String get editingMessage {
    return Intl.message(
      'Editing Message',
      name: 'editingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar', countryCode: 'EG'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
