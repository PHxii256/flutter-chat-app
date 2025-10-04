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
    // Get refresh token before clearing it
    final refreshToken = await _tokenService.getRefreshToken();

    // 1. Call API service with refresh token (best effort)
    if (refreshToken != null) {
      await _apiService.logout(refreshToken);
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

  // New method for automatic login validation
  Future<bool> validateAndRefreshTokens() async {
    try {
      // First check if we have tokens at all
      final accessToken = await _tokenService.getAccessToken();
      final refreshToken = await _tokenService.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        return false;
      }

      // TODO: You can add JWT token expiration check here if needed
      // For now, we'll assume if we have tokens, they might be valid

      // Try to validate with a test API call (optional)
      // If your backend has a /auth/validate endpoint, use it here

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
