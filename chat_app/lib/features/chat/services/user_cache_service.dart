import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class UserCacheService {
  final FlutterSecureStorage _storage;

  UserCacheService(this._storage);

  Future<void> saveUser(User user) async {
    await _storage.write(key: 'cached_user', value: jsonEncode(user.toJson()));
  }

  Future<User?> getCachedUser() async {
    try {
      final userString = await _storage.read(key: 'cached_user');
      if (userString != null) {
        final userJson = jsonDecode(userString) as Map<String, dynamic>;
        return User.fromJson(userJson);
      }
    } catch (e) {
      print('Error reading cached user: $e');
    }
    return null;
  }

  Future<void> clearCachedUser() async {
    await _storage.delete(key: 'cached_user');
  }

  Future<bool> hasUserCached() async {
    final userString = await _storage.read(key: 'cached_user');
    return userString != null;
  }
}
