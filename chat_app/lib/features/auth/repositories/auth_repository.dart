import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_api_service.dart';
import '../services/token_storage_service.dart';
import '../services/user_cache_service.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final TokenStorageService _tokenService;
  final UserCacheService _userCacheService;

  AuthRepository(this._apiService, this._tokenService, this._userCacheService);

  // Traditional MVVM: Repository orchestrates multiple services
  Future<AuthResponse> login(String email, String password) async {
    // 1. Call API service
    final response = await _apiService.login(email, password);

    // 2. Save tokens via storage service
    await _tokenService.saveTokens(response.accessToken, response.refreshToken);

    // 3. Cache user data
    await _userCacheService.saveUser(response.user);

    return response;
  }

  Future<AuthResponse> register(Map<String, dynamic> userData) async {
    // 1. Call API service
    final response = await _apiService.register(userData);

    // 2. Save tokens and user data
    await Future.wait([
      _tokenService.saveTokens(response.accessToken, response.refreshToken),
      _userCacheService.saveUser(response.user),
    ]);

    return response;
  }

  Future<void> logout() async {
    // Get tokens before clearing them
    final refreshToken = await _tokenService.getRefreshToken();
    final accessToken = await _tokenService.getAccessToken();

    // 1. Call API service with tokens (best effort)
    if (refreshToken != null) {
      await _apiService.logout(refreshToken, accessToken);
    }

    // 2. Clear all local data regardless of API call result
    await Future.wait([_tokenService.clearTokens(), _userCacheService.clearCachedUser()]);
  }

  Future<bool> isAuthenticated() async {
    // Check if we have valid tokens
    return await _tokenService.hasValidTokens();
  }

  Future<User?> getCurrentUser() async {
    // Get cached user data
    return await _userCacheService.getCachedUser();
  }

  Future<bool> refreshTokens() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.refreshToken(refreshToken);

      // Save new tokens and update user data
      await Future.wait([
        _tokenService.saveTokens(response.accessToken, response.refreshToken),
        _userCacheService.saveUser(response.user),
      ]);

      return true;
    } catch (e) {
      // Refresh failed, clear all tokens and user data
      await Future.wait([_tokenService.clearTokens(), _userCacheService.clearCachedUser()]);
      return false;
    }
  }

  Future<bool> validateAndRefreshTokens() async {
    try {
      // First check if we have tokens at all
      final accessToken = await _tokenService.getAccessToken();
      final refreshToken = await _tokenService.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        return false;
      }

      final isValid = await _apiService.validateToken(accessToken);

      if (isValid) {
        return true;
      }

      // If access token is expired, try refresh
      final refreshSuccess = await refreshTokens();
      return refreshSuccess;
    } catch (e) {
      return false;
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(authApiServiceProvider),
    ref.watch(tokenStorageServiceProvider),
    ref.watch(userCacheServiceProvider),
  );
}
