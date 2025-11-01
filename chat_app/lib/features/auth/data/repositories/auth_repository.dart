import 'package:chat_app/features/chat/models/user_model.dart';
import 'package:chat_app/features/chat/services/user_cache_service.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';

import '../models/auth_response.dart';

class AuthRepository {
  final AuthService _apiService;
  final TokenStorageService _tokenService;
  final UserCacheService _userCacheService;

  AuthRepository(this._apiService, this._tokenService, this._userCacheService);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    if (response is AuthSuccessResponse) {
      await _tokenService.saveTokens(response.accessToken, response.refreshToken);
      await _userCacheService.saveUser(response.user);
    }
    return response;
  }

  Future<AuthResponse> register(Map<String, dynamic> userData) async {
    final response = await _apiService.register(userData);
    if (response is AuthSuccessResponse) {
      await Future.wait([
        _tokenService.saveTokens(response.accessToken, response.refreshToken),
        _userCacheService.saveUser(response.user),
      ]);
    }

    return response;
  }

  Future<void> logout() async {
    final refreshToken = await _tokenService.getRefreshToken();
    final accessToken = await _tokenService.getAccessToken();

    if (refreshToken != null) {
      await _apiService.logout(refreshToken, accessToken);
    }

    await Future.wait([_tokenService.clearTokens(), _userCacheService.clearCachedUser()]);
  }

  Future<bool> isAuthenticated() async {
    return await _tokenService.hasValidTokens();
  }

  Future<User?> getCurrentUser() async {
    return await _userCacheService.getCachedUser();
  }

  Future<bool> refreshTokens() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.refreshToken(refreshToken);

      if (response is AuthSuccessResponse) {
        await Future.wait([
          _tokenService.saveTokens(response.accessToken, response.refreshToken),
          _userCacheService.saveUser(response.user),
        ]);
        return true;
      }
      return false;
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
