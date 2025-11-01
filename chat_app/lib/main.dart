import 'package:chat_app/core/network/dio.dart';
import 'package:chat_app/features/auth/bloc/auth_cubit.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository.dart';
import 'package:chat_app/features/auth/data/services/auth_service.dart';
import 'package:chat_app/features/auth/data/services/token_storage_service.dart';
import 'package:chat_app/features/chat/services/user_cache_service.dart';
import 'package:chat_app/features/localization/bloc/locale_cubit.dart';
import 'package:chat_app/features/conversations/pages/conversations_page.dart';
import 'package:chat_app/features/auth/presentation/widgets/auth_guard.dart';
import 'package:chat_app/features/conversations/bloc/conversations_cubit.dart';
import 'package:chat_app/features/conversations/repositories/conversations_repo.dart';
import 'package:chat_app/features/conversations/services/conversations_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'generated/l10n.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = const FlutterSecureStorage();
    final authRepository = AuthRepository(
      AuthService(getDioInstance()),
      TokenStorageService(storageService),
      UserCacheService(storageService),
    );
    final conversationsRepository = ConversationsRepository(ConversationsService(getDioInstance()));

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(authRepository: authRepository)),
        BlocProvider(create: (context) => LocaleCubit()),
        BlocProvider(
          create: (context) => ConversationsCubit(
            authRepository: authRepository,
            conversationsRepository: conversationsRepository,
          ),
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            locale: locale,
            localizationsDelegates: [
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
    );
  }
}
