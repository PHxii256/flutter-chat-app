import 'package:chat_app/core/config/main_di.dart';
import 'package:chat_app/features/localization/bloc/locale_cubit.dart';
import 'package:chat_app/features/conversations/presentation/pages/conversations_page.dart';
import 'package:chat_app/features/auth/presentation/widgets/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: getRepositoryProviders(),
      child: MultiBlocProvider(
        providers: getBlocProviders(),
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: const AuthGuard(child: ConversationsPage()),
            );
          },
        ),
      ),
    );
  }
}
