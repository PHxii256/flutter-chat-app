import 'package:chat_app/core/network/dio.dart';
import 'package:chat_app/features/auth/bloc/auth_cubit.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository.dart';
import 'package:chat_app/features/auth/data/services/auth_service.dart';
import 'package:chat_app/features/auth/data/services/token_storage_service.dart';
import 'package:chat_app/features/chat/data/services/user_cache_service.dart';
import 'package:chat_app/features/localization/bloc/locale_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

List<RepositoryProvider> getRepositoryProviders() {
  return [
    RepositoryProvider<FlutterSecureStorage>(create: (context) => const FlutterSecureStorage()),
    RepositoryProvider<TokenStorageService>(
      create: (context) => TokenStorageService(context.read<FlutterSecureStorage>()),
    ),
    RepositoryProvider<UserCacheService>(
      create: (context) => UserCacheService(context.read<FlutterSecureStorage>()),
    ),
    RepositoryProvider<Dio>(create: (context) => getDioInstance()),
    RepositoryProvider<AuthService>(create: (context) => AuthService(context.read<Dio>())),

    RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepository(
        context.read<AuthService>(),
        context.read<TokenStorageService>(),
        context.read<UserCacheService>(),
      ),
    ),
  ];
}

List<BlocProvider> getBlocProviders() {
  return [
    BlocProvider<AuthCubit>(
      create: (context) {
        final cubit = AuthCubit(authRepository: context.read<AuthRepository>());
        cubit.initialize(); // Initialize on creation
        return cubit;
      },
    ),
    BlocProvider<LocaleCubit>(create: (context) => LocaleCubit()),
  ];
}
