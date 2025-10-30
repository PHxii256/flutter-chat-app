import 'package:chat_app/features/localization/providers/locale_notifier.dart';
import 'package:chat_app/features/conversations/pages/conversations_page.dart';
import 'package:chat_app/shared/widgets/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';

void main() => runApp(
  ProviderScope(
    retry: (retryCount, error) {
      // Retry up to 3 times
      if (retryCount >= 3) return null;
      return Duration(milliseconds: 200 * (1 << retryCount)); // Exponential backoff
    },
    child: MyApp(),
  ),
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      locale: ref.watch(localeProvider),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: S.delegate.supportedLocales,
      home: const AuthGuard(child: ConversationsPage()),
    );
  }
}
