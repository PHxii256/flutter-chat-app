import 'package:chat_app/utils/server_url.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth for login, register, and refresh endpoints
    final skipAuthPaths = ['/auth/login', '/auth/register', '/auth/refresh-token'];
    if (!skipAuthPaths.any((path) => options.path.contains(path))) {
      try {
        final accessToken = await _storage.read(key: 'access_token');

        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
          // Show partial token for debugging (security safe)
          String tokenPreview = accessToken.length > 10
              ? "${accessToken.substring(0, 5)}...${accessToken.substring(accessToken.length - 5)}"
              : "Short token";
          print('🔐 Added auth token to request: ${options.path} ($tokenPreview)');
        } else {
          print('⚠️ No access token available for request: ${options.path}');
        }
      } catch (e) {
        print('❌ Error getting access token: $e');
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle both 401 (Unauthorized) and 403 (Forbidden) as potential auth token issues
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      print('🔄 ${err.response?.statusCode} error detected, handling authentication...');

      try {
        final refreshToken = await _storage.read(key: 'refresh_token');

        if (refreshToken != null && refreshToken.isNotEmpty) {
          // Attempt to refresh the token
          print('🔄 Attempting token refresh...');

          // Create a new Dio instance for the refresh request to avoid circular calls
          final refreshDio = Dio(BaseOptions(baseUrl: getServertUrl()));
          final refreshResponse = await refreshDio.post(
            '/auth/refresh-token',
            data: {'refreshToken': refreshToken},
          );

          if (refreshResponse.statusCode == 200) {
            final newAccessToken = refreshResponse.data['tokens']['accessToken'];
            final newRefreshToken = refreshResponse.data['tokens']['refreshToken'];

            // Save new tokens
            await Future.wait([
              _storage.write(key: 'access_token', value: newAccessToken),
              _storage.write(key: 'refresh_token', value: newRefreshToken),
            ]);
            print('✅ Token refreshed successfully');

            // Retry the original request with new token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            print('🔄 Retrying original request: ${opts.path}');

            // Create a new Dio instance to retry the request
            final retryDio = Dio(BaseOptions(baseUrl: getServertUrl()));
            retryDio.options.headers['Accept'] = 'application/json';
            retryDio.options.headers['Content-Type'] = 'application/json';

            try {
              final retryResponse = await retryDio.request(
                opts.path,
                options: Options(
                  method: opts.method,
                  headers: opts.headers,
                  responseType: opts.responseType,
                  contentType: opts.contentType,
                  validateStatus: opts.validateStatus,
                  receiveTimeout: opts.receiveTimeout,
                  sendTimeout: opts.sendTimeout,
                ),
                data: opts.data,
                queryParameters: opts.queryParameters,
              );
              return handler.resolve(retryResponse);
            } catch (retryError) {
              print('❌ Retry request failed: $retryError');
            }
          }
        } else {
          print('⚠️ No refresh token available');
        }
      } catch (refreshError) {
        if (refreshError is DioException && refreshError.response?.statusCode == 404) {
          print('❌ Token refresh failed: /auth/refresh-token endpoint not found (404)');
          print('🔧 Server issue: Make sure /auth/refresh-token route is properly configured');
        } else if (refreshError is DioException && refreshError.response?.statusCode == 403) {
          print('❌ Token refresh failed: Refresh token is invalid or expired (403)');
          print('🔄 User needs to login again');
        } else {
          print('❌ Token refresh failed: $refreshError');
        }
      }
    }

    handler.next(err);
  }

  /// Static helper method to refresh tokens from outside the interceptor
  static Future<String?> refreshAndGetToken(FlutterSecureStorage storage) async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        print('⚠️ No refresh token available for manual refresh');
        return null;
      }

      print('🔄 Attempting manual token refresh...');

      // Create a new Dio instance for the refresh request
      final refreshDio = Dio(BaseOptions(baseUrl: getServertUrl()));
      final refreshResponse = await refreshDio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (refreshResponse.statusCode == 200) {
        final newAccessToken = refreshResponse.data['tokens']['accessToken'];
        final newRefreshToken = refreshResponse.data['tokens']['refreshToken'];

        // Save new tokens
        await Future.wait([
          storage.write(key: 'access_token', value: newAccessToken),
          storage.write(key: 'refresh_token', value: newRefreshToken),
        ]);

        print('✅ Manual token refresh successful');
        return newAccessToken;
      } else {
        print('❌ Manual token refresh failed with status: ${refreshResponse.statusCode}');
        return null;
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        print('❌ Manual token refresh failed: /auth/refresh-token endpoint not found (404)');
        print('🔧 Server issue: Make sure /auth/refresh-token route is properly configured');
      } else {
        print('❌ Manual token refresh failed: $e');
      }
      return null;
    }
  }
}
